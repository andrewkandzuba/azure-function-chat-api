# Use the official Azure Functions Python 3.11 base image
FROM mcr.microsoft.com/azure-functions/python:4-python3.11

# Set environment variables
ENV AzureWebJobsScriptRoot=/home/site/wwwroot \
    AzureFunctionsJobHost__Logging__Console__IsEnabled=true \
    FUNCTIONS_WORKER_RUNTIME=python

# Copy function app files
COPY requirements.txt /home/site/wwwroot/
COPY function_app.py /home/site/wwwroot/
COPY host.json /home/site/wwwroot/

# Install dependencies
RUN cd /home/site/wwwroot && \
    pip install --no-cache-dir -r requirements.txt

# Set working directory
WORKDIR /home/site/wwwroot

# Expose port 80
EXPOSE 80

# The base image already has the Azure Functions runtime configured
# and will start automatically
