def validate_event(flight_event):

    required_fields = [
        "flight_number",
        "origin",
        "destination",
        "delay_minutes"
    ]

    for field in required_fields:
        if field not in flight_event:
            raise ValueError(
                f"Missing required field: {field}"
            )

    try:
        delay_minutes = int(flight_event["delay_minutes"])
    except (ValueError, TypeError):
        raise ValueError(
            "delay_minutes must be numeric"
        )

    if delay_minutes < 0:
        raise ValueError(
            "delay_minutes cannot be negative"
        )

    return {
        **flight_event,
        "delay_minutes": delay_minutes
    }