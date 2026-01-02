# Familien Kochbuch App

## Kurze Beschreibung

Eine iOS / Android App, die Rezepte nicht nur anzeigt, sondern durch Zusammenarbeit der Nutzer erweitert wird und dabei hilfreiche Vorschläge für Rezepte geben kann.
Das sind die genauen Fähigkeiten der App (im Laufe der Entwicklung des Projekts wird diese Liste noch ergänzt):

-   Rezepte eigenständig eintragen und verwalten
-   Benutzer können Notizen hinzufügen oder die Rezepte bewerten
-   Kategorisierung der Rezepte
-   Suche nach allen eingetragenen Rezepten
-   ... und vieles mehr

## Installation

Wichtig: Du musst vorher Flutter und Docker installiert haben, sonst lässt sich die App nicht bauen! Installations-Guides sind hier:

-   Flutter: https://docs.flutter.dev/install
-   Docker: https://www.docker.com/get-started/

```bash
git clone https://github.com/KugelMaster/Familien-Kochbuch-App.git

cd Familien-Kochbuch-App
docker compose up -d --build

cd frontend
flutter build apk --dart-define=BASE_URL=http://192.168.xx.xx:8000 # Deine Lokale IP-Adresse hier
```

## Funktionen

### App

Die App wird mit Flutter Dart entwickelt.

-   Entdecken Seite: Suchleiste und Kategorie-Auswahl
-   Meine Rezepte: Anzeigen aller gespeicherten Rezepte von der Datenbank
-   Rezept-Übersicht: Alle Informationen spezifisch zum Rezept

### Backend

Im Backend läuft ein FastAPI Server sowie ein PostreSQL-Container mit Docker.

-   PostgresDB auf Port 5432
-   API-Routen: [OpenAPI Docs](http://localhost:8000/docs)

## Hinweise

Informationen, zu was neu ist / was sich im Commit geändert hat kann man in den jeweiligen `TODO.md` Dateien in den Ordnern `frontend/` und `backend/` sehen!

<br>
<br>
<br>

# Häufige Anwendungen während der Entwicklung

## PostgreSQL

Wenn man in den Container der PostgreSQL-Datenbank zu dem Reiter "Exec" wechselt, dann kann man dort Befehle eingeben. Das ist nützlich, falls man z.B. Werte manuell in der Datenbank ändern muss. \
Durch den Befehl `psql -U cookbook` kann man eine Session starten und normale SQL Befehle ausführen.

## Flutter

Durch den Befehl `flutter build apk --dart-define=BASE_URL=http://192.168.xx.xx:8000` kann man die App für Android bauen lassen. Die URL zum Schluss ist die IP und Port zum Server (also hier: Mein Heim-PC).

## Easteregg

<img src="./Felix PFP.jpg" alt="Meine Katze heißt Felix :-)" width="200">
<p>Developed by Felix Software™</p>
<small>Die Firma gibt es nicht in echt 😉</small>
