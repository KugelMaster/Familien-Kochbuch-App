# Offene Aufgaben:
- Benutzerdefinierte Fehlermeldungen, z.B.:
```json
{
  "status": "error",
  "code": "WRONG_PASSWORD",
  "message": "Das eingegebene aktuelle Passwort ist nicht korrekt."
}
```
- Profil Bilder hinzufügen (mit IDs)
- Bilder upload planen (URL-Erstellung / ID?)
- Backups für Bearbeitung / Löschung
- Dokumentation übersichtlicher machen (OpenAPI)
 -> starlette.status Codes

# Aufgaben abgeschlossen:
- Optional user authentication
- Using new pydantic syntax
- Users can change their profile data
- Users can change their password
- Tagging images (currently useless)
- Made the "routers" folder a python package

# Andere Hinweise
Windows Subsystem for Linux (WSL, Windows 11): \
`\\wsl.localhost\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes`
<br>
<br>
Zufälligen Hex-String generieren (Zahl steht für Bytes):
```powershell
python -c "import secrets; print(secrets.token_hex(32))"
```