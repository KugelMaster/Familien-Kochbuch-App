# Aufgaben von RecipeOverviewPage
- Tags (add, edit, delete)
- user_notes: Außen
- ratings: Außen
- Haken (✓)

# Aufgaben (sortiert nach Priorität)
1. RecipeOverviewPage Aufgaben
1. RecipeEditPage Image Hero bearbeiten Funktion sichtbarer machen
1. RecipeOverviewPage Design:
    - Tags Farbe
    - Reviews nicht klickbar
    - Info Overflow rechts
    - Zutaten null Werte
    - FAB zu tief
    - Gradient zu groß
    - Transition AppBar schlecht
1. API-Calls reduzieren
1. HTTP-Fehler handeln
1. Testen, ob man Links für Koch Apps wie bspw. Cookido einfügen kann

# Weitere Aufgaben (noch keine Priorität):
- Task Leiste unten sieht schlecht aus
- App Icon & Name ändern
- Einzelne TODOs bearbeiten
- Dokumentation schreiben
- Neues Attribut: Wann wurde das Rezept das letzte mal gekocht?
- Offline-Modus (gecached Rezepte verwenden)

# Aufgaben abgeschlossen:
- RecipeOverviewPage AppBar wird nun sofort geladen
- Bugfix: RecipeOverviewPage gibt nun Update-Signale über `Navigator.pop` zurück, wenn das Rezept bearbeitet oder gelöscht wurde
- Einführung von der Datenklasse Tag mit id und name

# Hilfreiche Befehle:
- JSON Modell Konvertierer (automatisch Code generieren): `dart run build_runner watch --delete-conflicting-outputs`
