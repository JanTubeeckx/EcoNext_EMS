import pandas as pd
import numpy as np
import pickle
import xgboost as xgb
import matplotlib.pyplot as plt
from sklearn.metrics import mean_absolute_error, mean_squared_error
from sklearn.model_selection import TimeSeriesSplit
from solar_irradiance_data import create_irradiance_dataframe
from pv_production_data import hourly_production_df
from weather_api import get_historical_weather_data

def prepare_data():
    solar_irradiance_df = create_irradiance_dataframe()
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
    irradiance_and_power_df = historical_data.join(hourly_production_df, how='right')
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
    return df

# Create and train model
def create_and_train_model():
    historical_data = prepare_data()
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
        train = add_lag_features(train)
        test = create_features(test)
        test = add_lag_features(test)

        FEATURES = ['hour', 'dayofweek', 'quarter', 'month', 'year', 'dayofyear', 
                    'dayofmonth', 'dhi', 'bhi', 'temperatuur', 'luchtvochtigheid',
                    'lag_1', 'lag_2', 'lag_3', 'lag_4']
        TARGET = ['ghi']

        X_train = train[FEATURES]
        y_train = train[TARGET]

        X_test = test[FEATURES]
        y_test = test[TARGET]

        xgb_model = xgb.XGBRegressor(device='gpu',
                                    learning_rate=0.15,
                                    n_estimators=2800,
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

    modelfile = open('./xgboost_model.pkl', 'ab')
    # xgb_model.save_model("model.json")
    pickle.dump(xgb_model, modelfile)
    modelfile.close()

def main():
    create_and_train_model()

if __name__ == '__main__':
    main()