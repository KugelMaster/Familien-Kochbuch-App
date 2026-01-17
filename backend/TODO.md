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
- Benutzer können ihr Passwort ändern
- Bilder müssen nun Kategorien haben ("avatar" oder "recipe")

# Andere Hinweise
Windows Subsystem for Linux (WSL, Windows 11): \
`\\wsl.localhost\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes`
<br>
<br>
Zufälligen Hex-String generieren (Zahl steht für Bytes):
```powershell
python -c "import secrets; print(secrets.token_hex(32))"
```