# Offene Aufgaben:
- /users und /me gleich implementieren; /me ist ein Alias für /users/{id}
- Bilder Upload Dateiname besser generieren, sodass Datei leichter zuzuordnen ist
- Backups für Bearbeitung / Löschung
- Dokumentation übersichtlicher machen (OpenAPI)
 -> starlette.status Codes

# Aufgaben abgeschlossen:
- Get or create default entries in database
- Breaking down DB models in different files
- Implemented recipe chooser function (WIP!)

- Added new example recipes :-)

# Andere Hinweise
Windows Subsystem for Linux (WSL, Windows 11): \
`\\wsl.localhost\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes`
<br>
<br>
Zufälligen Hex-String generieren (Zahl steht für Bytes):
```powershell
python -c "import secrets; print(secrets.token_hex(32))"
```