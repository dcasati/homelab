# Use homelab base image
FROM ghcr.io/dcasati/homelab-base:latest

# Set working directory (already set in base image)
WORKDIR /app

# Copy application code (dependencies already installed in base image)
COPY forecast.py .

# User is already set in base image (appuser)

# Run the forecasting script
CMD ["python", "forecast.py"]
