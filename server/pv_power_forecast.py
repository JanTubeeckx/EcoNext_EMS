# This script predicts future solar irradiance by using the XGBoost algorithm

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

import pickle
import pandas as pd
import numpy as np
import xgboost as xgb
import seaborn as sns
import matplotlib.pyplot as plt
from solar_irradiance_data import create_irradiance_dataframe
from pv_production_data import hourly_production_df
from weather_api import get_historical_weather_data, get_weather_forecast
from datetime import timedelta, datetime

# Define variables
solar_irradiation = 'ghi'

# Enable visualizing
visualize = False

def prepare_data(solar_irradiance_df):
    solar_irradiation = 'ghi'
    historical_weather_data = get_historical_weather_data()
    # Inner join solar irradiance dataframe with PV production dataframe
    hourly_production_df['current_power'] = hourly_production_df['current_power'].multiply(1000).round(2)
    hourly_production_df['temperature'] = hourly_production_df['temperature'].multiply(10)
    # Add historical weatherdata to historical irradiance data
    historical_data = solar_irradiance_df.join(historical_weather_data, how='left')
    historical_data.index = pd.to_datetime(historical_data.index)
    historical_data = historical_data.ffill()
    # Add measured power output PV system
    # irradiance_and_power_df = historical_data.join(hourly_production_df, how='right')
    # Remove parameters with low correlation
    historical_data.drop(columns=['dauwpunt', 'neerslag', 'luchtdruk'], inplace=True)
    # Remove negative values
    historical_data = historical_data[historical_data[solar_irradiation]>=0]
    return historical_data

## Apply feature engineering
# Create time series features based on time series index
def create_features(df):
    df = df.copy()
    df['hour'] = df.index.hour
    df['dayofweek'] = df.index.dayofweek
    df['quarter'] = df.index.quarter
    df['month'] = df.index.month
    df['year'] = df.index.year
    df['dayofyear'] = df.index.dayofyear
    df['dayofmonth'] = df.index.day
    return df

# Create lag features
def add_lag_features(df):
    solar_irradiation = 'ghi'
    target_map = df[solar_irradiation].to_dict()
    df['lag_1'] = (df.index - pd.Timedelta('12 hours')).map(target_map)
    df['lag_2'] = (df.index - pd.Timedelta('24 hours')).map(target_map)
    df['lag_3'] = (df.index - pd.Timedelta('48 hours')).map(target_map)
    df['lag_4'] = (df.index - pd.Timedelta('72 hours')).map(target_map)
    # df['lag_1'] = (df.index - pd.Timedelta('364 days')).map(target_map)
    # df['lag_2'] = (df.index - pd.Timedelta('728 days')).map(target_map)
    # df['lag_3'] = (df.index - pd.Timedelta('1092 days')).map(target_map)
    # df['lag_4'] = (df.index - pd.Timedelta('1456 days')).map(target_map)
    return df

def investigate_correlations(historical_data):
    plt.figure(figsize=(15, 5))
    corrmat = historical_data.corr()
    corr_heatmap = sns.heatmap(corrmat, vmin=-1, vmax=1, square=True, annot=True)
    corr_heatmap.set_title('Correlatie heatmap', fontdict={'fontsize': 12}, pad=12)

def convert_predicted_solar_radiation_to_pv_power(prediction):
    # User input for PV installation
    number_of_pv_panels = 10
    peak_power_pv_panel = 215
    surrounding_factor = 0.85
    total_pv_peak_power = number_of_pv_panels * peak_power_pv_panel * surrounding_factor
    # Standard test conditions manufacturer
    standard_solar_radiation = 1000
    standard_temperature = 25
    # Calculate solar cell temperature
    prediction['solar_cell_temperature'] = ((standard_temperature/800) * 
                                            prediction['solar_irr_prediction'] 
                                            + prediction['temperature_2m']) 
    # Calculate power production of PV installation
    prediction['pv_power_prediction'] = ((total_pv_peak_power * 
                                        (prediction['solar_irr_prediction']/standard_solar_radiation)) - 
                                        (0.35 * (prediction['solar_cell_temperature'] - standard_temperature)))
    return prediction

## Make predictions
def predict_pv_power(solar_irradiance_df, isProduction):
    # Define variables
    solar_irradiation = 'ghi'
    nr_of_days_to_predict = 3
    next_day = datetime.now().day + 1
    # Get saved xgboost model
    modelfile = open('xgboost_model.pkl', 'rb')
    # xgb_model = xgb.XGBRegressor()
    # xgb_model.load_model("model.json")
    xgb_model = pickle.load(modelfile)
    modelfile.close()
    # Get data
    weather_forecast = get_weather_forecast()
    historical_data = prepare_data(solar_irradiance_df)
    # Visualize correlations between features of the dataset
    if visualize:
        investigate_correlations(historical_data)
    # Retrain data
    df = create_features(historical_data)
    df = add_lag_features(df)
    # Split data in features and value to predict
    FEATURES = ['hour', 'dayofweek', 'quarter', 'month', 'year', 'dayofyear', 
                'dayofmonth', 'temperatuur', 'luchtvochtigheid', 'lag_1', 'lag_2', 
                'lag_3', 'lag_4']
    TARGET = [solar_irradiation]
    # Apply the forecast model 
    X_all = df[FEATURES]
    y_all = df[TARGET]
    xgb_model.fit(X_all, y_all,
                eval_set=[(X_all, y_all)],
                verbose=0)
    if visualize:
        xgb.plot_importance(xgb_model)
    # Create dataframe to write future values of solar irradiation
    current_date = solar_irradiance_df.index.max().date()
    future_date = current_date+timedelta(nr_of_days_to_predict)
    future = pd.date_range(str(current_date), str(future_date), freq='15min')
    future_df = pd.DataFrame(index=future)
    future_df['isFuture'] = True
    df['isFuture'] = False
    # Add dataframe with future values to dataframe with historical values
    df_and_future = pd.concat([df, future_df])
    df_and_future = create_features(df_and_future)
    df_and_future = add_lag_features(df_and_future)
    future_with_features = df_and_future.query('isFuture').copy()
    # Predict future global solar irradiance (GHI)
    future_with_features[solar_irradiation] = xgb_model.predict(future_with_features[FEATURES])
    future_with_features['solar_irr_prediction'] = future_with_features[solar_irradiation]

    # Add correct zero values (night hours and negative values) and remove unnecessary columns
    # future_with_features.loc[future_with_features.index.hour < 6,'solar_irr_prediction'] = 0
    # future_with_features.loc[future_with_features.index.hour > 21, 'solar_irr_prediction'] = 0
    future_with_features.loc[future_with_features['solar_irr_prediction'] < 0, 'solar_irr_prediction'] = 0
    future_with_features.drop(columns=['hour', 'dayofweek', 'quarter', 'month', 'year', 'dayofyear', 
                                    'dayofmonth', 'temperatuur', 'luchtvochtigheid', 'windsnelheid', 'lag_1',
                                    'lag_2', 'lag_3', 'lag_4', 'ghi', 'dhi', 'bhi'], inplace=True)
    # Adjust prediction with hours in shade
    future_with_features.loc[future_with_features.index.hour > 13,
                            'solar_irr_prediction'] = future_with_features['solar_irr_prediction'] * 0.6
    # future_with_features['solar_irr_prediction'].plot(figsize=(15,5))
    # Combine time series forecast with weather forecast for most important parameters
    prediction = future_with_features.join(weather_forecast)
    prediction.index = prediction.index - timedelta(hours=1)
    # Convert predicted solar irradiance to PV power
    convert_predicted_solar_radiation_to_pv_power(prediction)
    # Give prediction dataframe final format to display in iOS app
    prediction.drop(columns=['isFuture', 'solar_irr_prediction', 'temperature_2m', 'relative_humidity_2m', 
                            'dew_point_2m', 'rain', 'solar_cell_temperature'], inplace=True)
    if isProduction:
        prediction = prediction.loc[prediction.index.day == next_day]
    prediction['time'] = prediction.index
    prediction['time'] = pd.to_datetime(prediction['time'])
    prediction['time'] = prediction['time'].dt.strftime("%Y-%m-%d %H:%M") 
    prediction.loc[(prediction.index.hour < 6), 'pv_power_prediction'] = 0
    prediction.loc[(prediction.index.hour > 21), 'pv_power_prediction'] = 0
    print(prediction.tail(60))
    return prediction

def main():
    solar_irradiance_df = create_irradiance_dataframe()
    prediction = predict_pv_power(solar_irradiance_df, True)
    prediction.to_feather("prediction.feather")
       
if __name__ == '__main__':
    main()
