"""Dates et fenêtres de dates manipulées par l'ingestion."""

from dataclasses import dataclass
from datetime import date


def parse_date(value: str) -> date:
    """Convertit une date ``AAAA-MM-JJ`` ; lève ``ValueError`` si le format est invalide."""
    try:
        return date.fromisoformat(value)
    except (TypeError, ValueError) as exc:
        raise ValueError(f"date invalide (AAAA-MM-JJ attendu) : {value!r}") from exc


@dataclass(frozen=True, slots=True)
class DateWindow:
    """Période de dates, bornes incluses."""

    start: date
    end: date

    def __post_init__(self) -> None:
        """Refuse une fenêtre dont le début est après la fin."""
        if self.end < self.start:
            raise ValueError(f"fenêtre inversée : {self.start} > {self.end}")

    def __contains__(self, day: object) -> bool:
        """Indique si ``day`` est une date comprise dans la fenêtre."""
        return isinstance(day, date) and self.start <= day <= self.end

    def __str__(self) -> str:
        """Affiche la fenêtre sous la forme ``début..fin``."""
        return f"{self.start}..{self.end}"
