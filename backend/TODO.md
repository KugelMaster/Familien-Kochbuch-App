# Offene Aufgaben:
- Testen was passiert, wenn Datenbank-Verbindung während der App unterbrochen wird (-> Client fehlende DB-Verbindung mitteilen (z.B. ERR_DB_UNAVAILABLE))
- Bilder Upload Dateiname besser generieren, sodass Datei leichter zuzuordnen ist
- Backups für Bearbeitung / Löschung
- Dokumentation übersichtlicher machen (OpenAPI)
 -> starlette.status Codes

# Aufgaben abgeschlossen:
- Adding status and error codes to 'Message' scheme
- Updating ServiceException for more generic use (and registering it in 'main.py')
- Log (and send) error when connection to database failed
- Bugfix: Creating a tag now responds with status code 201

# Andere Hinweise
Windows Subsystem for Linux (WSL, Windows 11): \
`\\wsl.localhost\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes`
<br>
<br>
Zufälligen Hex-String generieren (Zahl steht für Bytes):
```powershell
python -c "import secrets; print(secrets.token_hex(32))"
```