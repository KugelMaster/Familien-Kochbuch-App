# Kochen-Vorschläge App
## Kurze Beschreibung
Eine iOS / Andriod App, die Essens-Vorschläge für die Familie liefern kann. Z.B:
- Rezepte anzeigen für übrige Zutaten
- Filtern von Rezepten je nach Jahreszeit
- ... (ich schreibe später noch mehr wenn ich Zeit und Lust habe)
## Aktueller Fortschritt
### App
- Eine Navigations-Leiste unten mit Material 3 Design
- Fünf Seiten: Entdecken, Meine Rezepte, Planer, Verlauf und Einstellungen
### Backend
- PostgresDB auf Port 5432
- PostgreSQL Modele
- Pydantic Schemen
- API Routen:
    - [Recipe erstellen und abrufen](http://localhost:8000/recipes)

<br>
<br>
<br>

# Häufige Fehler
## Docker Compose
Wenn man den Befehl `docker compose up` ausführt, werden die Container **nicht neu gebaut**, wodurch es scheint, als ob sich nichts geändert hat. Bitte immer den Befehl `docker compose up --build` nutzen! \
Damit die erstellen Container nach dem Testen auch wieder entfernt werden, muss man `docker compose down` ausführen. Dadurch wird die Liste nicht endlos lang.
