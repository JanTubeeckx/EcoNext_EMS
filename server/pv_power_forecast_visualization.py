import matplotlib.pyplot as plt
from solar_irradiance_data import create_irradiance_dataframe
from pv_production_data import hourly_production_df
from pv_power_forecast import predict_pv_power

# Visualize results
def visualizeprediction():
    solar_irradiance_df=create_irradiance_dataframe()
    prediction = predict_pv_power(solar_irradiance_df, False)
    hourly_production_df.plot()
    prediction['pv_power_prediction'].plot(figsize = (15,5), title='PV power prediction')
    plt.legend()
    plt.show()

def main():
    visualizeprediction()

if __name__ == '__main__':
    main()