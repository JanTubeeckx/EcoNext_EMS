# This script predicts future PV power output by using the XGBoost algorithm

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

import pandas as pd
import numpy as np
import xgboost as xgb
import matplotlib.pyplot as plt
from sklearn.metrics import mean_absolute_error, mean_absolute_percentage_error, mean_squared_error
from sklearn.model_selection import GridSearchCV, TimeSeriesSplit
from sklearn.preprocessing import MinMaxScaler
from solar_irradiance_data import solar_irradiance_df
from pv_production_data import hourly_production_df
from datetime import datetime, time, timedelta

# Inner join solar irradiance dataframe with PV production dataframe
hourly_production_df = hourly_production_df.set_index('time')
hourly_production_df.index = pd.to_datetime(hourly_production_df.index).tz_localize('Europe/Berlin')
hourly_production_df['current_power'] = hourly_production_df['current_power'].multiply(1000)
irradiance_and_power_df = pd.concat([hourly_production_df, solar_irradiance_df])
irradiance_and_power_df = solar_irradiance_df.join(hourly_production_df)
# irradiance_and_power_df[['ghi', 'current_power']].plot(figsize=(15,5), title='Dataset PV power prediction')
# solar_irradiance_df['ghi'].plot(figsize=(15,5), title='Dataset PV power prediction')

solar_irradiation = 'dhi'

print(irradiance_and_power_df.tail(48))

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

solar_irradiance_df = create_features(solar_irradiance_df)

# Create lag features
def add_lag_features(df):
    target_map = df[solar_irradiation].to_dict()
    df['lag1'] = (df.index - pd.Timedelta('10 days')).map(target_map)
    df['lag2'] = (df.index - pd.Timedelta('20 days')).map(target_map)
    df['lag3'] = (df.index - pd.Timedelta('30 days')).map(target_map)
    return df

solar_irradiance_df = add_lag_features(solar_irradiance_df)

# Create train model
tss = TimeSeriesSplit(n_splits=5, test_size=24*30, gap=0)
df = solar_irradiance_df.sort_index()

# fig, axs = plt.subplots(5, 1, figsize = (15,15), sharex=True)

# fold = 0
# predictions = []
# scores = []
# for train_index, val_index in tss.split(df):
#     train = df.iloc[train_index]
#     test = df.iloc[val_index]
#     # # Visualize training and test split
#     # train['ghi'].plot(ax = axs[fold],
#     #                     label = 'Training Set',
#     #                     title = f'Data Train/Test split Fold {fold}')
#     # test['ghi'].plot(ax = axs[fold], label = 'Test Set')
#     # axs[fold].axvline(test.index.min(), color = 'black', ls = '--')

#     train = create_features(train)
#     test = create_features(test)

#     FEATURES = ['hour', 'dayofweek', 'quarter', 'month', 'year', 'dayofyear', 'dayofmonth',
#                 'lag1', 'lag2', 'lag3']
#     TARGET = ['ghi']

#     X_train = train[FEATURES]
#     y_train = train[TARGET]

#     X_test = test[FEATURES]
#     y_test = test[TARGET]

#     xgb_model = xgb.XGBRegressor(base_score=0.5,
#                                 booster='gbtree',
#                                 learning_rate=0.01,
#                                 n_estimators=500,
#                                 objective='reg:squarederror',
#                                 subsample=0.8,
#                                 max_depth=15)
#     xgb_model.fit(X_train, y_train,
#                 eval_set=[(X_train, y_train), (X_test, y_test)],
#                 verbose=100)
    
#     y_prediction = xgb_model.predict(X_test)
#     predictions.append(y_prediction)
#     score = np.sqrt(mean_squared_error(y_test, y_prediction))
#     scores.append(score)

#     fold += 1
# # plt.show()
# print(f'Score across folds {np.mean(scores):0.4f}')
# print(scores)

## Make predictions
# Retrain data
df = create_features(solar_irradiance_df)

FEATURES = ['hour', 'dayofweek', 'quarter', 'month', 'year', 'dayofyear', 'dayofmonth',
            'lag1', 'lag2', 'lag3']
TARGET = [solar_irradiation]

X_all = df[FEATURES]
y_all = df[TARGET]

xgb_model = xgb.XGBRegressor(base_score=0.5,
                                booster='gbtree',
                                learning_rate=0.01,
                                n_estimators=1000,
                                objective='reg:squarederror',
                                subsample=0.8,
                                max_depth=0)
xgb_model.fit(X_all, y_all,
            eval_set=[(X_all, y_all)],
            verbose=100)

current_date = solar_irradiance_df.index.max().date()
future_date = current_date+timedelta(5)
future = pd.date_range(str(current_date), str(future_date), freq='1h')
future_df = pd.DataFrame(index=future)
future_df.index = future_df.index.tz_localize('Europe/Berlin')
future_df['isFuture'] = True
df['isFuture'] = False
df_and_future = pd.concat([df, future_df])
df_and_future = create_features(df_and_future)
df_and_future = add_lag_features(df_and_future)
future_with_features = df_and_future.query('isFuture').copy()

# Predict future ghi
future_with_features[solar_irradiation] = xgb_model.predict(future_with_features[FEATURES])

print(future_with_features.head(48))
hourly_production_df.plot(color='green')
future_with_features[solar_irradiation].plot(figsize = (15,5), title='Solar irradiance prediction')
plt.show()
