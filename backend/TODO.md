# Offene Aufgaben:
- Profil Bilder hinzufügen (mit IDs)
- Bilder upload planen (URL-Erstellung / ID?)
- Backups für Bearbeitung / Löschung
- Dokumentation übersichtlicher machen (OpenAPI)
 -> starlette.status Codes

# Aufgaben abgeschlossen:
- In Pydantic Schemen wird nun ConfigDict zur Konfiguration verwendet, da alte Variante veraltet war

# Andere Hinweise
Windows Subsystem for Linux (WSL, Windows 11): \
`\\wsl.localhost\docker-desktop\mnt\docker-desktop-disk\data\docker\volumes`
<br>
<br>
Zufälligen Hex-String generieren (Zahl steht für Bytes):
```powershell
python -c "import secrets; print(secrets.token_hex(32))"
```