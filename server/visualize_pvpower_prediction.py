import matplotlib.pyplot as plt
from solar_irradiance_data import create_irradiance_dataframe
from pv_production_data import hourly_production_df
from xgboost_forecast import predictpvpower

# Visualize results 
def visualizeprediction():
    solar_irradiance_df=create_irradiance_dataframe()
    prediction = predictpvpower(solar_irradiance_df)
    hourly_production_df.plot()
    prediction['final_prediction'].plot(figsize = (15,5), title='Solar irradiance prediction')
    # irradiance_and_power_df[solar_irradiation].plot(figsize = (15,5), title='Solar irradiance prediction')
    plt.legend()
    plt.show()

def main():
    visualizeprediction()

if __name__ == '__main__':
    main()