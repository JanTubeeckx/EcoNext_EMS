# This script predicts future PV power output by using the XGBoost algorithm

# Created by Jan Tubeeckx
# https://github.com/JanTubeeckx

import pandas as pd
import numpy as np
import xgboost as xgb
import matplotlib.pyplot as plt
from sklearn.metrics import mean_squared_error
from sklearn.model_selection import TimeSeriesSplit
from sklearn.preprocessing import MinMaxScaler
from solar_irradiance_data import solar_irradiance_df
from pv_production_data import hourly_production_df
from time import time

# Inner join solar irradiance dataframe with PV production dataframe
hourly_production_df = hourly_production_df.set_index('time')
hourly_production_df.index = pd.to_datetime(hourly_production_df.index).tz_localize('Etc/UCT')
hourly_production_df['current_power'] = hourly_production_df['current_power'].multiply(1000)
# irradiance_and_power_df = pd.concat([hourly_production_df, solar_irradiance_df])
# irradiance_and_power_df = solar_irradiance_df.join(hourly_production_df)
# irradiance_and_power_df.plot(figsize=(15,5),
#                              title='Dataset PV power prediction')
# solar_irradiance_df['ghi'].plot(figsize=(15,5),
#                          title='Dataset PV power prediction')

def train_test_split(df):
  fold = 0
  # Execute time series split to maintain chronological order during splitting process
  tss = TimeSeriesSplit(max_train_size=None, n_splits=5, test_size=None, gap=0)
  fig, axs = plt.subplots(5, 1, figsize = (15,15), sharex=True)
  df = df.sort_index()

  for train_index, val_index in tss.split(df):
    train =df.iloc[train_index]
    test = df.iloc[val_index]

    # Visualize training and test split
    train['ghi'].plot(ax = axs[fold],
                         label = 'Training Set',
                         title = f'Data Train/Test split Fold {fold}')
    test['ghi'].plot(ax = axs[fold], label = 'Test Set')
    axs[fold].axvline(test.index.min(), color = 'black', ls = '--')
    fold += 1
  return train, test

def filter_data_to_predict(df, shift_by=1, target_value='ghi'):
    target = df[target_value][shift_by:].values
    dep = df.drop(target_value, axis=1).shift(-shift_by).dropna().values
    data = np.column_stack((dep, target))
    return data

def create_xgboost_model(train, x_test):
   x_train, y_train = train[:,:-1], train[:,-1]
  #  xgb_model = xgb.XGBRegressor(learning_rate=0.01, n_estimators=1500, subsample=0.8,
  #                                colsample_bytree=1, colsample_bylevel=1,
  #                                min_child_weight=20, max_depth=14, objective='reg:squarederror')
   xgb_model = xgb.XGBRegressor(base_score = 0.5, booster = 'gbtree',
                           n_estimators = 1200, 
                           objective = 'reg:squarederror',
                           max_depth = 2,
                           learning_rate = 0.1)
   xgb_model.fit(x_train, y_train)
   prediction = xgb_model.predict([x_test])
   return prediction[0], xgb_model

def forecast_future_solar_irradiance(df):
   preds = []
   train, test = train_test_split(df)
   train, test = filter_data_to_predict(train), filter_data_to_predict(test)
   history = np.array([x for x in train])

   for i in range(len(test)):
      test_x, test_y = test[i][:-1], test[i][-1]
      prediction, xgb_model = create_xgboost_model(history, test_x)
      preds.append(prediction)
      np.append(history, [test[i]], axis=0)

   error = mean_squared_error(test[:,-1], preds)

   return error, preds, test[:,-1], xgb_model

  #  scaler = MinMaxScaler(feature_range=(0,1))
  #  train_scaled = scaler.fit_transform(train)
  #  test_scaled = scaler.transform(test)

  #  train_scaled_df = pd.DataFrame(train_scaled, columns=train.columns, index=train.index)
  #  test_scaled_df = pd.DataFrame(test_scaled, columns=test.columns, index=test.index)

  #  train_scaled_sup, test_scaled_sup = filter_data_to_predict(train_scaled_df), filter_data_to_predict(test_scaled_df)
  #  history = np.array([x for x in train_scaled_sup])

  #  for i in range(len(test_scaled_sup)):
  #     test_x, test_y = test_scaled_sup[i][:-1], test_scaled_sup[i][-1]
  #     prediction, xgb_model = create_xgboost_model(history, test_x)
  #     preds.append(prediction)
  #     np.append(history, [test_scaled_sup[i]], axis=0)

  #  pred_array = test_scaled_df.drop('ghi', axis=1).to_numpy()
  #  pred_num = np.array([pred_array])
  #  pred_array = np.concatenate((pred_array, pred_num.T), axis=1)
  #  result = scaler.inverse_transform(pred_array)

  #  return result, test, xgb_model

error, xgb_pred, actual, xgb_model = forecast_future_solar_irradiance(solar_irradiance_df)

train, test = train_test_split(solar_irradiance_df)
solar_irradiance_test_xgb = test[['ghi']][:-1]
solar_irradiance_test_xgb['GHI prediction'] = xgb_pred[0:]

print(error)

solar_irradiance_test_xgb.plot(legend=True, color=['b','g'], fontsize=17)
fig = plt.gcf()
fig.set_size_inches(20,10)
plt.legend(loc=0,prop={'size': 20})
plt.title("XGBOOST Prediction", fontsize=20)
plt.ylabel("GHI (W/m²)", fontsize=20)
plt.xlabel("DateTime", fontsize=20)
plt.show()

# future = pd.date_range('2024-04-10','2024-04-12', freq = '1h')
# future_df = pd.DataFrame(index=future)
# future_df.index = pd.to_datetime(future_df.index)
# future_df = create_features(future_df)

# future_df['isFuture'] = True
# solar_irradiance_df['isFuture'] = False

# df_and_future = pd.concat([solar_irradiance_df, future_df])

# # add the features
# # df_and_future = create_features(df_and_future)
# df_and_future = add_lags(df_and_future)

# future_with_features = df_and_future.query('isFuture').copy()
# future_with_features['prediction'] = reg.predict(future_with_features[FEATURES])
# print(future_with_features['prediction'])
# # # future_with_features.plot(figsize = (10,5))
# # future_with_features.plot(style='r', label = 'prediction')
# # plt.title('PV power prediction')
# # plt.legend()
