# Familien Kochbuch App
## Kurze Beschreibung
Eine iOS / Android App, die Rezept Vorschläge für die Familie liefern kann. Die App kann Folgendes:
- Eine Suche nach allen eingetragenen Rezepten
- Kategorisierung der Rezepte
- Anzeigen einer Rezept-Übersicht mit allen Koch-spezifischen Daten sowie Zutaten, Nährstoffe, Benutzer Notizen und Bewertungen eines jeweiligen Nutzers
- Rezepte selber erstellen, bearbeiten und löschen
- Rezepte nach übrigen Zutaten filtern (TODO)
- ... und vieles mehr
## Aktueller Fortschritt
### App
- Entdecken Seite: Suchleiste und Kategorie-Auswahl
- Meine Rezepte: Anzeigen aller gespeichterer Rezepte von der Datenbank
- Rezept-Übersicht: Alle Informationen nötig fürs Kochen
- Planer: nix
- Verlauf: nix
- Einstellungen: nix
### Backend
- PostgresDB auf Port 5432
- PostgreSQL Modele
- Pydantic Schemen
- Verschiedene API-Routen: [OpenAPI Docs](http://localhost:8000/docs)

-> Informationen, zu was neu ist / was sich geändert hat kann man ab diesen Commit immer in den jeweiligen `TODO.md` Dateien in den Ordnern `frontend/` und `backend/` sehen!

<br>
<br>
<br>

# Häufige Fehler
## Docker Compose
Wenn man den Befehl `docker compose up` ausführt, werden die Container **nicht neu gebaut**, wodurch es scheint, als ob sich nichts geändert hat. Bitte immer den Befehl `docker compose up --build` nutzen! \
Damit die erstellen Container nach dem Testen auch wieder entfernt werden, muss man `docker compose down` ausführen. Dadurch wird die Liste nicht endlos lang.
## PostgreSQL
Wenn man in den Container der PostgreSQL-Datenbank zu dem Reiter "Exec" wechselt, dann kann man dort Befehle eingeben. Das ist nützlich, falls man z.B. Werte manuell in der Datenbank ändern muss. \
Durch den Befehl `psql -U cookbook` kann man eine Session starten und normale SQL Befehle ausführen.
## ref.watch()
`ref.watch(<provider>)` sollte man nur in einer `build()` Methode verwenden!
## Flutter
Durch den Befehl `flutter build apk --dart-define=BASE_URL=http://192.168.xx.xx:8000` kann man die App für Android bauen lassen. Die URL zum Schluss ist die IP und Port zum Server (also hier: Mein Heim-PC).