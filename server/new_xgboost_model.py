import pandas as pd
import numpy as np
import seaborn as sns
import pickle
import xgboost as xgb
import matplotlib.pyplot as plt

from sklearn.metrics import mean_absolute_error, mean_squared_error
from sklearn.model_selection import TimeSeriesSplit
from solar_irradiance_data import create_irradiance_dataframe
from weather_api import get_historical_weather_data
from datetime import timedelta, datetime

def prepare_data():
  solar_irradiance_df = create_irradiance_dataframe()

# solar_irradiance_df = create_irradiance_dataframe()
historical_weather_df = get_historical_weather_data()
historical_weather_df.to_csv('historical_weather_data.csv')

# Get historical solar irradiance from 01/01/2019 until 06/12/2024
solar_irradiance_df = pd.read_csv('datasets/solar_irradiance_data.csv').drop(['Unnamed: 0'], axis=1)
solar_irradiance_df = solar_irradiance_df.set_index('Datetime')
solar_irradiance_df.index = pd.to_datetime(solar_irradiance_df.index).tz_convert(None)
# Get historical solar irradiance from 01/01/2019 until 06/14/2024
historical_weather_df = pd.read_csv('datasets/historical_weather_data.csv')
historical_weather_df = historical_weather_df.set_index('time')
historical_weather_df.index = pd.to_datetime(historical_weather_df.index)

solar_irr_weather_df = solar_irradiance_df.join(historical_weather_df, how='left')
solar_irr_weather_df.index = pd.to_datetime(solar_irr_weather_df.index)
solar_irr_weather_df = solar_irr_weather_df.ffill()

# # solar_irradiance_df['ghi'].plot(figsize=(15,5))
# # plt.show()

def create_features(df):
    df = df.copy()
    df['hour'] = df.index.hour
    df['quarter'] = df.index.quarter
    df['month'] = df.index.month
    df['dayofyear'] = df.index.dayofyear
    return df

# Create lag features
def add_lags(df):
    target_map = df['ghi'].to_dict()
    df['lag_1'] = (df.index - pd.Timedelta('12 hours')).map(target_map)
    df['lag_2'] = (df.index - pd.Timedelta('24 hours')).map(target_map)
    df['lag_3'] = (df.index - pd.Timedelta('48 hours')).map(target_map)
    df['lag_4'] = (df.index - pd.Timedelta('72 hours')).map(target_map)
    return df

df_with_lags = add_lags(solar_irr_weather_df)

# Normal train test split
train = df_with_lags.loc[df_with_lags.index < '01-01-2023']
test = df_with_lags.loc[df_with_lags.index >= '01-01-2023']

train = create_features(train)
test = create_features(test)

FEATURES = ['dayofyear', 'hour', 'quarter', 'month',
            # 'dhi', 'bhi',
            # 'lag_1','lag_2','lag_3', 'lag_4'
            ]
TARGET = 'ghi'

X_train = train[FEATURES]
y_train = train[TARGET]

X_test = test[FEATURES]
y_test = test[TARGET]

reg = xgb.XGBRegressor(n_estimators=2800,
                       objective='reg:squarederror',
                       max_depth=5,
                       learning_rate=0.15)
reg.fit(X_train, y_train,
        eval_set=[(X_train, y_train), (X_test, y_test)],
        verbose=100)

y_prediction = reg.predict(X_test)
mae = mean_absolute_error(y_test, y_prediction)
mse = mean_squared_error(y_test, y_prediction)
rmse = np.sqrt(mean_squared_error(y_test, y_prediction))

print(f'Mae score is {np.mean(mae):0.4f}')
print(f'Mse score is {np.mean(mse):0.4f}')
print(f'Rmse score is {np.mean(rmse):0.4f}')

# Retrain on all data
df = create_features(solar_irr_weather_df)

FEATURES = ['dayofyear', 'hour', 'quarter', 'month',
            # 'dhi', 'bhi',
            # 'lag_1','lag_2','lag_3', 'lag_4'
            ]
TARGET = 'ghi'

X_all = df[FEATURES]
y_all = df[TARGET]

reg = xgb.XGBRegressor(n_estimators=2800,
                       objective='reg:squarederror',
                       max_depth=5,
                       learning_rate=0.15)
reg.fit(X_all, y_all,
        eval_set=[(X_all, y_all)],
        verbose=100)

current_date = solar_irradiance_df.index.max().date()
future_date = current_date+timedelta(3)
future = pd.date_range(str(current_date), str(future_date), freq='15min')
future_df = pd.DataFrame(index=future)
future_df['isFuture'] = True
df['isFuture'] = False
df_and_future = pd.concat([df, future_df])
df_and_future = create_features(df_and_future)
future_with_features = df_and_future.query('isFuture').copy()
future_with_features['prediction'] = reg.predict(future_with_features[FEATURES])

future_with_features['prediction'].plot(figsize=(15,5))


# # Cross validation
# tss = TimeSeriesSplit(n_splits=5, test_size=24*365*1, gap=24)
# df = solar_irr_weather_df.sort_index()

# fold = 0
# predictions = []
# scores_mae = []
# scores_mse = []
# scores_rmse = []
# for train_idx, val_idx in tss.split(df):
#    train = df.iloc[train_idx]
#    test = df.iloc[val_idx]

#    train = create_features(train)
#    test = create_features(test)

#    FEATURES = ['dayofyear', 'hour', 'quarter', 'month',
#             'dhi', 'bhi',
#             # 'lag_1','lag_2','lag_3', 'lag_4'
#             ]
#    TARGET = 'ghi'

#    X_train = train[FEATURES]
#    y_train = train[TARGET]

#    X_test = test[FEATURES]
#    y_test = test[TARGET]

#    xgb_model = xgb.XGBRegressor(device='gpu',
#                                 learning_rate=0.15,
#                                 n_estimators=2800,
#                                 objective='reg:squarederror',
#                                 max_depth=5)
  
#    xgb_model.fit(X_train, y_train,
#                  eval_set=[(X_train, y_train), (X_test, y_test)],
#                  verbose=100)
  
#    y_prediction = xgb_model.predict(X_test)
#    predictions.append(y_prediction)
#    mae = mean_absolute_error(y_test, y_prediction)
#    mse = mean_squared_error(y_test, y_prediction)
#    rmse = np.sqrt(mean_squared_error(y_test, y_prediction))
#    scores_mae.append(mae)
#    scores_mse.append(mse)
#    scores_rmse.append(rmse)

# print(f'Mae score across folds {np.mean(mae):0.4f}')
# print(mae)
# print(f'Mse score across folds {np.mean(mse):0.4f}')
# print(mse)
# print(f'Rmse score across folds {np.mean(rmse):0.4f}')
# print(rmse)

# fig, ax = plt.subplots(figsize=(15,5))
# train['ghi'].plot(ax=ax, label='Training set', title='Data train/test split')
# test['ghi'].plot(ax=ax, label='Test set')
# ax.axvline('01-01-2023', color='black', ls='--')
# plt.show()

# solar_irradiance_df.loc[(solar_irradiance_df.index > '06-01-2023') &
#                                (solar_irradiance_df.index < '06-08-2023')]['ghi'].plot()
# plt.show()



# df_with_features = create_features(df_with_lags)
# print(df_with_features.tail())

# # fig, ax = plt.subplots(figsize=(10, 8))
# # sns.boxplot(data=df_with_features, x='hour', y='ghi')
# # ax.set_title('Ghi by Hour')
# # plt.show()

