import requests
from astral import LocationInfo
from astral.sun import sun
from datetime import datetime
import pytz
import os

LAT = float(os.getenv("LAT", "51.0447"))
LON = float(os.getenv("LON", "-114.0719"))
TZ  = os.getenv("TZ", "America/Edmonton")
INFLUX_HOST = os.getenv("INFLUX_HOST", "http://172.16.5.241:8086")
INFLUX_DB   = os.getenv("INFLUX_DB", "iot")

city = LocationInfo("OfflineSun", "Earth", TZ, LAT, LON)
s = sun(city.observer, date=datetime.now(), tzinfo=pytz.timezone(TZ))

sunrise_ts = int(s['sunrise'].timestamp() * 1e9)
sunset_ts  = int(s['sunset'].timestamp()  * 1e9)
print(f"[INFO] Sunrise: {s['sunrise']} (ts: {sunrise_ts})") 
print(f"[INFO] Sunset:  {s['sunset']} (ts: {sunset_ts})")

# Calculate daylight duration
daylight = s['sunset'] - s['sunrise']
daylight_hours = daylight.total_seconds() / 3600
hours = int(daylight_hours)
minutes = int((daylight_hours - hours) * 60)
readable = f"{hours}h{minutes}m"

# Current time for daylight metric
now_ts = int(datetime.now().timestamp() * 1e9)

payload = f"""
sunrise value=1 {sunrise_ts}
sunset value=1 {sunset_ts}
daylight_hours value={daylight_hours:.2f},{readable}=1i {now_ts}
"""

daylight_str = f'daylight_string value="{readable}" {now_ts}'
payload += f"\n{daylight_str}"

resp = requests.post(
    f"{INFLUX_HOST}/write?db={INFLUX_DB}",
    data=payload.strip(),
    headers={"Content-Type": "text/plain"}
)

print(f"[INFO] Influx write status: {resp.status_code}")

