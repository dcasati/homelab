# Use python base image - update this SHA when base image changes
FROM ghcr.io/dcasati/python-base:sha-abc123

# Set working directory (already set in base image)
WORKDIR /app

# Copy application code (all dependencies already installed in base image)
COPY sunrise_to_influx.py .

# User is already set in base image (appuser)

# Run the sunrise script
CMD ["python", "sunrise_to_influx.py"]

