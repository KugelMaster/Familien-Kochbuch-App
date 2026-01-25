# Aufgaben (sortiert nach Priorität)
1. ApiClient und Services richtig für Fehler konfigurieren
1. RecipeEditPage Image Hero bearbeiten Funktion sichtbarer machen
1. Tag Verwaltungs Seite
1. RecipeOverviewPage Design:
    - Tags Farbe
    - Reviews nicht klickbar
    - Info Overflow rechts
    - Zutaten null Werte
    - FAB zu tief
    - Gradient zu groß
    - Transition AppBar schlecht
1. API-Calls reduzieren

# Weitere Aufgaben (noch keine Priorität):
- Registieren Seite schließt sich wenn man von Login Seite kommt
- Fehler, wenn Benutzer Namen wählt den es schon gibt
- Löschen-Knopf in Suchleiste erscheint auch verspätet (mit Debounce)
- Rezept Suche mit Filter (z.B. Tags)
- RatingsDialog schöner gestalten
- CircularProgressIndicator bei Rezept laden korrigieren
- Reload on Pull MyRecipesPage
- Rückgängig nach Löschen oder Bearbeiten
- Task Leiste unten sieht schlecht aus
- App Icon & Name ändern
- Einzelne TODOs bearbeiten
- Dokumentation schreiben
- Neues Attribut: Wann wurde das Rezept das letzte mal gekocht?
- Offline-Modus (gecached Rezepte verwenden)
- Testen, ob man Links für Koch Apps wie bspw. Cookido einfügen kann
- Websocket; Wenn zwei Nutzer gleichzeitig ein Rezept bearbeiten, werden die Daten zwischen Server und Client gewechselt
- Für mehr Benutzer Sicherheit: Passwort und Benutzername (oder generell sensible Daten) in einem gesichertem Browser Fenster abfragen (z.B. flutter_appauth)

# Aufgaben abgeschlossen:
- Prototyp, um die "baseUrl" von "ApiClient" zu ändern

# Hilfreiche Befehle:
- JSON Modell Konvertierer (automatisch Code generieren): `dart run build_runner watch --delete-conflicting-outputs`
- App bauen: `flutter build apk --dart-define=BASE_URL=http://192.168.xx.xx:8000`
