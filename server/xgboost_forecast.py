# This script predicts future solar irradiance by using the XGBoost algorithm

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

import time
import pandas as pd
import numpy as np
import xgboost as xgb
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.metrics import mean_absolute_error, mean_squared_error
from sklearn.model_selection import TimeSeriesSplit
from solar_irradiance_data import create_irradiance_dataframe
from pv_production_data import hourly_production_df
from weather_api import get_historical_weather_data, get_weather_forecast
from datetime import timedelta, datetime

# Define variables
solar_irradiation = 'ghi'

# Enable visualizing
visualize = True

# Run on Raspberry Pi instead of Azure server
RPi = False

def preparedata(solar_irradiance_df):
    solar_irradiation = 'ghi'
    # print(solar_irradiance_df.tail(60))
    historical_weather_data = get_historical_weather_data()
    # Inner join solar irradiance dataframe with PV production dataframe
    hourly_production_df['current_power'] = hourly_production_df['current_power'].multiply(1000).round(2)
    hourly_production_df['temperature'] = hourly_production_df['temperature'].multiply(10)
    # Add historical weatherdata to historical irradiance data
    historical_data = solar_irradiance_df.join(historical_weather_data, how='left')
    historical_data.index = pd.to_datetime(historical_data.index)
    historical_data = historical_data.ffill()
    # Add measured power output PV system
    irradiance_and_power_df = historical_data.join(hourly_production_df, how='right')
    # Remove parameters with low correlation
    historical_data.drop(columns=['dauwpunt', 'neerslag', 'luchtdruk'], inplace=True)
    # Remove negative values
    historical_data = historical_data[historical_data[solar_irradiation]>=0]
    return historical_data

def investigatecorrelations(historical_data):
    plt.figure(figsize=(15, 5))
    corrmat = historical_data.corr()
    corr_heatmap = sns.heatmap(corrmat, vmin=-1, vmax=1, square=True, annot=True)
    corr_heatmap.set_title('Correlatie heatmap', fontdict={'fontsize': 12}, pad=12)

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
    df['lag_1'] = (df.index - pd.Timedelta('1 day')).map(target_map)
    df['lag_2'] = (df.index - pd.Timedelta('2 days')).map(target_map)
    df['lag_3'] = (df.index - pd.Timedelta('3 days')).map(target_map)
    df['lag_4'] = (df.index - pd.Timedelta('7 days')).map(target_map)
    df['lag_5'] = (df.index - pd.Timedelta('30 days')).map(target_map)
    df['lag_6'] = (df.index - pd.Timedelta('364 days')).map(target_map)
    return df

# Create train model
def createtrainmodel():
    historical_data = preparedata()
    tss = TimeSeriesSplit(n_splits=5, test_size=24*365*1, gap=24)
    df = historical_data.sort_index()

    fig, axs = plt.subplots(5, 1, figsize = (15,15), sharex=True)

    fold = 0
    predictions = []
    scores_mae = []
    scores_mse = []
    scores_rmse = []
    for train_index, val_index in tss.split(df):
        train = df.iloc[train_index]
        test = df.iloc[val_index]
        # Visualize training and test split
        train['ghi'].plot(ax = axs[fold],
                            label = 'Training Set',
                            title = f'Data Train/Test split Fold {fold}')
        test['ghi'].plot(ax = axs[fold], label = 'Test Set')
        axs[fold].axvline(test.index.min(), color = 'black', ls = '--')

        train = create_features(train)
        test = create_features(test)

        FEATURES = ['hour', 'dayofweek', 'quarter', 'month', 'year', 'dayofyear', 
                    'dayofmonth', 'dhi', 'bhi', 'temperatuur', 'luchtvochtigheid',
                    'lag_1', 'lag_2', 'lag_3', 'lag_4', 'lag_5', 'lag_6']
        TARGET = [solar_irradiation]

        X_train = train[FEATURES]
        y_train = train[TARGET]

        X_test = test[FEATURES]
        y_test = test[TARGET]

        xgb_model = xgb.XGBRegressor(device='gpu',
                                    learning_rate=0.1,
                                    n_estimators=1500,
                                    objective='reg:squarederror',
                                    max_depth=5)
        
        xgb_model.fit(X_train, y_train,
                    eval_set=[(X_train, y_train), (X_test, y_test)],
                    verbose=100)
        
        y_prediction = xgb_model.predict(X_test)
        predictions.append(y_prediction)
        mae = mean_absolute_error(y_test, y_prediction)
        mse = mean_squared_error(y_test, y_prediction)
        rmse = np.sqrt(mean_squared_error(y_test, y_prediction))
        scores_mae.append(mae)
        scores_mse.append(mse)
        scores_rmse.append(rmse)

        fold += 1
    plt.show()
    print(f'Mae score across folds {np.mean(mae):0.4f}')
    print(mae)
    print(f'Mse score across folds {np.mean(mse):0.4f}')
    print(mse)
    print(f'Rmse score across folds {np.mean(rmse):0.4f}')
    print(rmse)

## Make predictions
def predictpvpower(solar_irradiance_df):
    # Define variables
    solar_irradiation = 'ghi'
    nr_of_days_to_predict = 3
    next_day = datetime.now().day + 1
    # Get data
    weather_forecast = get_weather_forecast()
    historical_data = preparedata(solar_irradiance_df)
    #print("collected")
    historical_data = create_features(historical_data)
    historical_data = add_lag_features(historical_data)
    # Visualize correlations between features of the dataset
    if visualize:
        investigatecorrelations(historical_data)
    # Retrain data
    df = create_features(historical_data)
    df = add_lag_features(historical_data)
    # Split data in features and value to predict
    FEATURES = ['hour', 'dayofweek', 'quarter', 'month', 'year', 'dayofyear', 
                'dayofmonth', 'temperatuur', 'luchtvochtigheid', 'lag_1', 'lag_2', 
                'lag_3', 'lag_4', 'lag_5', 'lag_6']
    TARGET = [solar_irradiation]
    # Create the prediction model
    X_all = df[FEATURES]
    y_all = df[TARGET]
    xgb_model = xgb.XGBRegressor(booster="gbtree", 
                                 learning_rate=0.1,
                                 n_estimators=5000,
                                 max_depth=5,
                                 min_child_weight=1,
                                 gamma=0,
                                 subsample=0.8,
                                 colsample_bytree=0.8,
                                 reg_alpha=0.005,
                                 nthread=4,
                                 scale_pos_weight=1,
                                 seed=27)
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
    # Adjust prediction with hours in shade
    # future_with_features.loc[future_with_features.index.hour > 14,
    #                         'solar_irr_prediction'] = future_with_features['solar_irr_prediction'] * 0.9
    future_with_features.loc[future_with_features.index.hour < 7,'solar_irr_prediction'] = 0
    future_with_features.loc[future_with_features.index.hour > 21, 'solar_irr_prediction'] = 0
    future_with_features.loc[future_with_features['solar_irr_prediction'] < 0, 'solar_irr_prediction'] = 0
    future_with_features.drop(columns=['hour', 'dayofweek', 'quarter', 'month', 'year', 'dayofyear', 
                                    'dayofmonth', 'temperatuur', 'luchtvochtigheid', 'lag_1', 'lag_2',
                                    'lag_3', 'lag_4', 'lag_5', 'lag_6', 'ghi', 'dhi', 'bhi'], inplace=True)
    # Combine time series forecast with weather forecast for most important parameters
    prediction = future_with_features.join(weather_forecast)
    prediction.index = prediction.index - timedelta(hours=1)
    prediction['final_prediction'] = (prediction['solar_irr_prediction'] *
                                    (prediction['temperature_2m'].div(10)) /
                                    (prediction['relative_humidity_2m'].div(100))) * 0.7
    # Give prediction dataframe final format to display in iOS app
    prediction.drop(columns=['isFuture', 'solar_irr_prediction', 'temperature_2m', 'relative_humidity_2m', 
                            'dew_point_2m', 'rain'], inplace=True)
    prediction = prediction.loc[prediction.index.day == next_day]
    prediction['time'] = prediction.index
    prediction['time'] = pd.to_datetime(prediction['time'])
    prediction['time'] = prediction['time'].dt.strftime("%Y-%m-%d %H:%M") 
    return prediction

def main():
    if RPi:
        while True:
            time.sleep(14400)
            prediction = predictpvpower()
            prediction.to_feather("./prediction.feather")
    else:
        solar_irradiance_df = create_irradiance_dataframe()
        prediction = predictpvpower(solar_irradiance_df)
        print("test")
        prediction.to_feather("./prediction.feather")
       
if __name__ == '__main__':
    main()
