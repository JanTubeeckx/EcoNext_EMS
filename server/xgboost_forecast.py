# This script predicts future solar irradiance by using the XGBoost algorithm

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

import pandas as pd
import numpy as np
import xgboost as xgb
import seaborn as sns
import matplotlib.pyplot as plt
from sklearn.metrics import mean_absolute_error, mean_squared_error
from sklearn.model_selection import GridSearchCV, TimeSeriesSplit
from sklearn.preprocessing import StandardScaler
from solar_irradiance_data import solar_irradiance_df
from pv_production_data import hourly_production_df
from weather_api import weather_data, weather_forecast
from datetime import timedelta

# Define variables
solar_irradiation = 'ghi'
nr_of_days_to_predict = 2

# Inner join solar irradiance dataframe with PV production dataframe
hourly_production_df['current_power'] = hourly_production_df['current_power'].multiply(1000).round(2)
hourly_production_df['temperature'] = hourly_production_df['temperature'].multiply(10)

# Add historical weatherdata to historical irradiance data
historical_data = solar_irradiance_df.join(weather_data, how='right')
historical_data.index = pd.to_datetime(historical_data.index)

# Add measured power output PV system
irradiance_and_power_df = historical_data.join(hourly_production_df, how='right')

# Investigate correlations
plt.figure(figsize=(15, 5))
corrmat = historical_data.corr()
corr_heatmap = sns.heatmap(corrmat, vmin=-1, vmax=1, square=True, annot=True)
corr_heatmap.set_title('Correlatie heatmap', fontdict={'fontsize': 12}, pad=12)

# Remove parameters with low correlation
historical_data.drop(columns=['dauwpunt', 'neerslag', 'luchtdruk'], inplace=True)

# Remove negative values
historical_data = historical_data[historical_data[solar_irradiation]>=0]

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

historical_data = create_features(historical_data)

# Create lag features
def add_lag_features(df):
    target_map = df[solar_irradiation].to_dict()
    df['lag_1'] = (df.index - pd.Timedelta('6 days')).map(target_map)
    # df['lag_2'] = (df.index - pd.Timedelta('2 days')).map(target_map)
    # df['lag_3'] = (df.index - pd.Timedelta('4 days')).map(target_map)
    # df['lag_4'] = (df.index - pd.Timedelta('728 days')).map(target_map)
    # df['lag_5'] = (df.index - pd.Timedelta('1456 days')).map(target_map)
    # df['lag_6'] = (df.index - pd.Timedelta('728 days')).map(target_map)
    return df

historical_data = add_lag_features(historical_data)

# Scale data to balance the impact of the variables
y = historical_data[solar_irradiation]
X = historical_data.drop([solar_irradiation], axis=1)
scaler = StandardScaler()
X = pd.DataFrame(scaler.fit_transform(X), columns = X.columns)

# # Create train model
# tss = TimeSeriesSplit(n_splits=5, test_size=24*30, gap=0)
# df = historical_data.sort_index()

# fig, axs = plt.subplots(5, 1, figsize = (15,15), sharex=True)

# fold = 0
# predictions = []
# scores_mae = []
# scores_mse = []
# scores_rmse = []
# for train_index, val_index in tss.split(df):
#     train = df.iloc[train_index]
#     test = df.iloc[val_index]
#     # Visualize training and test split
#     # train['ghi'].plot(ax = axs[fold],
#     #                     label = 'Training Set',
#     #                     title = f'Data Train/Test split Fold {fold}')
#     # test['ghi'].plot(ax = axs[fold], label = 'Test Set')
#     # axs[fold].axvline(test.index.min(), color = 'black', ls = '--')

#     train = create_features(train)
#     test = create_features(test)

#     FEATURES = ['hour', 'dayofweek', 'quarter', 'month', 'year', 'dayofyear', 
#                 'dayofmonth', 'dhi', 'bhi', 'temperatuur', 'luchtvochtigheid', 'lag1']
#     TARGET = [solar_irradiation]

#     X_train = train[FEATURES]
#     y_train = train[TARGET]

#     X_test = test[FEATURES]
#     y_test = test[TARGET]

#     xgb_model = xgb.XGBRegressor(device='gpu',
#                                  learning_rate=0.1,
#                                  n_estimators=1500,
#                                  objective='reg:squarederror',
#                                  max_depth=5)
    
#     xgb_model.fit(X_train, y_train,
#                 eval_set=[(X_train, y_train), (X_test, y_test)],
#                 verbose=100)
    
#     y_prediction = xgb_model.predict(X_test)
#     predictions.append(y_prediction)
#     mae = mean_absolute_error(y_test, y_prediction)
#     mse = mean_squared_error(y_test, y_prediction)
#     rmse = np.sqrt(mean_squared_error(y_test, y_prediction))
#     scores_mae.append(mae)
#     scores_mse.append(mse)
#     scores_rmse.append(rmse)

#     fold += 1
# # plt.show()
# print(f'Mae score across folds {np.mean(mae):0.4f}')
# print(mae)
# print(f'Mse score across folds {np.mean(mse):0.4f}')
# print(mse)
# print(f'Rmse score across folds {np.mean(rmse):0.4f}')
# print(rmse)

## Make predictions
# Retrain data
df = create_features(historical_data)
df = add_lag_features(historical_data)

print(df)

FEATURES = ['hour', 'dayofweek', 'quarter', 'month', 'year', 'dayofyear', 'dayofmonth',
            'temperatuur', 'luchtvochtigheid', 'lag_1']
TARGET = [solar_irradiation]

X_all = df[FEATURES]
y_all = df[TARGET]

xgb_model = xgb.XGBRegressor(device='gpu',
                             learning_rate=0.1,
                             n_estimators=1500,
                             objective='reg:squarederror',
                             max_depth=5)

xgb_model.fit(X_all, y_all,
            eval_set=[(X_all, y_all)],
            verbose=100)

xgb.plot_importance(xgb_model)

current_date = solar_irradiance_df.index.max().date()
future_date = current_date+timedelta(nr_of_days_to_predict)
future = pd.date_range(str(current_date), str(future_date), freq='1h')
future_df = pd.DataFrame(index=future)
future_df['isFuture'] = True
df['isFuture'] = False
df_and_future = pd.concat([df, future_df])
df_and_future = create_features(df_and_future)
df_and_future = add_lag_features(df_and_future)
future_with_features = df_and_future.query('isFuture').copy()

# Predict future ghi
future_with_features[solar_irradiation] = xgb_model.predict(future_with_features[FEATURES])
future_with_features['solar_irr_prediction'] = future_with_features[solar_irradiation]
# future_with_features['solar_irr_prediction'] = np.where(future_with_features.index.hour < 8, 0, 
#                                                         (np.where(future_with_features.index.hour > 20), 0,
#                                                          future_with_features['solar_irr_prediction']))
future_with_features.loc[future_with_features.index.hour < 7,'solar_irr_prediction'] = 0
future_with_features.loc[future_with_features.index.hour > 20, 'solar_irr_prediction'] = 0
future_with_features.drop(columns=['hour', 'dayofweek', 'quarter', 'month', 'year', 'dayofyear', 
                                   'dayofmonth', 'temperatuur', 'luchtvochtigheid', 'lag_1', 'ghi', 
                                   'dhi', 'bhi'], inplace=True)
print(weather_forecast)
# Combine time series forecast with weather forecast for most important parameters
prediction = future_with_features.join(weather_forecast)
prediction['final_prediction'] = (prediction['solar_irr_prediction'] *
                                 (prediction['temperature_2m'].div(10)) /
                                 (prediction['relative_humidity_2m'] / 100)) 
print(prediction.tail(60))

# Visualize results 
hourly_production_df.plot()
prediction['final_prediction'].plot(figsize = (15,5), title='Solar irradiance prediction')
irradiance_and_power_df[solar_irradiation].plot(figsize = (15,5), title='Solar irradiance prediction')
plt.legend()
plt.show()
