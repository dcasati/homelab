# Use python base image - update this SHA when base image changes
FROM ghcr.io/dcasati/python-base:sha-abc123

# Set working directory (already set in base image)
WORKDIR /app

# Copy application code (dependencies already installed in base image)
COPY forecast.py .

# User is already set in base image (appuser)

# Run the forecasting script
CMD ["python", "forecast.py"]
