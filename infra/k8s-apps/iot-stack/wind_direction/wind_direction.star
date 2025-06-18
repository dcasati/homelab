def apply(metric):
    deg = metric.fields.get("wind_dir_deg")
    if deg is None:
        return metric

    directions = [
        "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
        "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"
    ]

    index = int((deg + 11.25) % 360 / 22.5)
    metric.tags["wind_dir_cardinal"] = directions[index]
    return metric
