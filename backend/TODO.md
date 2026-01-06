# Offene Aufgaben:
- Bilder upload planen (URL-Erstellung / ID?)
- Backups für Bearbeitung / Löschung
- Dokumentation übersichtlicher machen (OpenAPI)
 -> starlette.status Codes

# Aufgaben abgeschlossen:
- Fremdschlüssel bei Löschung aktualisiert
- `user_dependency` verwenden, wo man Benutzer-ID braucht
- Berechtigung-System (User, Admin)
- Umstieg auf .env Dateien mit Standart Werten in Settings zum Testen

# Andere Hinweise
Windows Subsystem for Linux (WSL, Windows 11): \
`\\wsl.localhost\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes`
<br>
<br>
Zufälligen Hex-String generieren (Zahl steht für Bytes):
```powershell
python -c "import secrets; print(secrets.token_hex(32))"
```