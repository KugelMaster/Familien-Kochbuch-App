# Kochen-Vorschläge App
## Kurze Beschreibung
Eine iOS / Andriod App, die Essens-Vorschläge für die Familie liefern kann. Z.B:
- Rezepte anzeigen für übrige Zutaten
- Filtern von Rezepten je nach Jahreszeit
- ... (ich schreibe später noch mehr wenn ich Zeit und Lust habe)
## Aktueller Fortschritt
### App
- Entdecken Seite: Suchleiste und Kategorie-Auswahl
- Meine Rezepte: Anzeigen aller gespeichterer Rezepte von der Datenbank & Anzeigen der Informationen eines ausgewählten Rezepts (z.B. auch Überleitung von der Suche) 
- Planer: nix
- Verlauf: nix
- Einstellungen: nix
### Backend
- PostgresDB auf Port 5432
- PostgreSQL Modele
- Pydantic Schemen
- API Routen:
    - [Recipes](http://localhost:8000/recipes)
    - [UserNotes](http://localhost:8000/usernotes)
    - [Ratings](http://localhost:8000/ratings)
    - [Images](http://localhost:8000/images)
    - [Tags](http://localhost:8000/tags)

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