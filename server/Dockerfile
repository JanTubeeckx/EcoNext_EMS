# For more information, please refer to https://aka.ms/vscode-docker-python
FROM python:3.12

ENV ACCESS_TOKEN="upOfvyQI3R9TuALeNfGvnWO8nISU4xwISpZV1RsH0uFBRoaKXD1CM5N-K1UYV_GIHq8JLQIBXBtG8vYNroTeiQ=="
ENV DB_NAME="meter_readings"
ENV DB_NAME_PROD="solar_inverter_readings"
ENV DB_HOST="https://eu-central-1-1.aws.cloud2.influxdata.com/"

EXPOSE 5000

# Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1

# Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y git && pip install --upgrade pip

# Install HDF5 using apt
RUN apt-get update && apt-get install -y libhdf5-dev

# Install pip requirements
COPY requirements.txt .
RUN python -m pip install -r requirements.txt

WORKDIR /app
COPY . /app

# Install h5py with no-binary flag
RUN pip install --no-binary h5py h5py

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-python-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

# Define the FLASK_APP environment variable
ENV FLASK_APP=flask_server.py

# During debugging, this entry point will be overridden. For more information, please refer to https://aka.ms/vscode-docker-python-debug
CMD ["flask", "run", "--host", "0.0.0.0"]
