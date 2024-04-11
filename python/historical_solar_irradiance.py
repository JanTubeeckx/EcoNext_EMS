import pandas as pd

solar_irradiance_2022 = pd.read_csv('./data/459177_51.05_3.74_2022.csv')
solar_irradiance_2021 = pd.read_csv('./data/459177_51.05_3.74_2021.csv')
solar_irradiance_2020 = pd.read_csv('./data/459177_51.05_3.74_2020.csv')
solar_irradiance_2019 = pd.read_csv('./data/459177_51.05_3.74_2019.csv')
solar_irradiance_2018 = pd.read_csv('./data/459177_51.05_3.74_2018.csv')
solar_irradiance_2017 = pd.read_csv('./data/459177_51.05_3.74_2017.csv')
solar_irradiance_2016 = pd.read_csv('./data/459177_51.05_3.74_2016.csv')
historical_solar_2015 = pd.read_csv('./data/459177_51.05_3.74_2015.csv')

solar_irradiance_frames = [historical_solar_2015,
                           solar_irradiance_2016,
                           solar_irradiance_2017,
                           solar_irradiance_2018,
                           solar_irradiance_2019,
                           solar_irradiance_2020,
                           solar_irradiance_2021,
                           solar_irradiance_2022]

historical_solar_irradiance = pd.concat(solar_irradiance_frames)

historical_solar_irradiance['Datetime'] = pd.to_datetime(historical_solar_irradiance[['Year', 'Month', 'Day', 'Hour']])
historical_solar_irradiance = historical_solar_irradiance.drop(['Year', 'Month', 'Day', 'Hour', 'Minute'], axis=1)

# df = solar_irradiance_2022.loc[(solar_irradiance_2022['Datetime'] >= '2022-01-01') & (solar_irradiance_2022['Datetime'] < '2022-01-31')]

historical_solar_irradiance.plot(x='Datetime', y='DHI')
historical_solar_irradiance.plot(x='Datetime', y='GHI')
historical_solar_irradiance.plot(x='Datetime', y='DNI')
historical_solar_irradiance.plot(x='Datetime', y='Temperature')

print(historical_solar_irradiance)