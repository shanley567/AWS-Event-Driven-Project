import pytest
from validator import validate_event


def test_valid_event():

    event = {
        "flight_number": "BA123",
        "origin": "LHR",
        "destination": "AMS",
        "delay_minutes": 30
    }

    result = validate_event(event)

    assert result["delay_minutes"] == 30


def test_string_delay_converted():

    event = {
        "flight_number": "BA123",
        "origin": "LHR",
        "destination": "AMS",
        "delay_minutes": "30"
    }

    result = validate_event(event)

    assert result["delay_minutes"] == 30


def test_non_numeric_delay_fails():

    with pytest.raises(ValueError):

        validate_event({
            "flight_number": "BA123",
            "origin": "LHR",
            "destination": "AMS",
            "delay_minutes": "ABC"
        })


def test_negative_delay_fails():

    with pytest.raises(ValueError):

        validate_event({
            "flight_number": "BA123",
            "origin": "LHR",
            "destination": "AMS",
            "delay_minutes": -5
        })


def test_missing_required_field():

    with pytest.raises(ValueError):

        validate_event({
            "flight_number": "BA123",
            "destination": "AMS",
            "delay_minutes": 30
        })