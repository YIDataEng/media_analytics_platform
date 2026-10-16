from datetime import date

import pytest

from adsdata.ingestion.dates import DateWindow, parse_date


def test_parse_date_accepts_iso_format():
    assert parse_date("2026-10-01") == date(2026, 10, 1)


@pytest.mark.parametrize("value", ["01/10/2026", "2026-13-01", "", None, 20261001])
def test_parse_date_rejects_anything_else(value):
    with pytest.raises(ValueError, match="date invalide"):
        parse_date(value)


def test_window_bounds_are_inclusive():
    window = DateWindow(date(2026, 10, 1), date(2026, 10, 7))

    assert date(2026, 10, 1) in window
    assert date(2026, 10, 7) in window
    assert date(2026, 9, 30) not in window
    assert date(2026, 10, 8) not in window


def test_window_only_contains_dates():
    assert "2026-10-01" not in DateWindow(date(2026, 10, 1), date(2026, 10, 1))


def test_single_day_window_is_allowed():
    assert str(DateWindow(date(2026, 10, 1), date(2026, 10, 1))) == "2026-10-01..2026-10-01"


def test_inverted_window_is_rejected():
    with pytest.raises(ValueError, match="inversée"):
        DateWindow(date(2026, 10, 7), date(2026, 10, 1))
