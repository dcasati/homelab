# Use homelab base image
FROM ghcr.io/dcasati/homelab-base:latest

# Set working directory (already set in base image)
WORKDIR /app

# Copy application code (all dependencies already installed in base image)
COPY sunrise_to_influx.py .

# User is already set in base image (appuser)

# Run the sunrise script
CMD ["python", "sunrise_to_influx.py"]

