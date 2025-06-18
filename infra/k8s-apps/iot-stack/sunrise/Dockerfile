FROM python:3.11-slim

RUN pip install astral pytz requests

COPY sunrise_to_influx.py /app/sunrise_to_influx.py
WORKDIR /app

CMD ["python", "sunrise_to_influx.py"]

