#!/bin/bash

case "$1" in
    up)
        echo "Starting the container..."
        powershell.exe -Command "docker compose up -d --build"
        ;;
    down)
        echo "Stopping the container..."
        powershell.exe -Command "docker compose down"
        ;;
    rs)
        echo "Restarting the container..."
        powershell.exe -Command "docker compose down"
        powershell.exe -Command "docker compose up -d --build"
        ;;
    app)
        echo "Starting the emulator application..."
        cd frontend || exit 1
        powershell.exe -Command "flutter emulators --launch Pixel_7_Pro"
        ;;
    open-project)
        echo "Opening the project in VS Code..."
        powershell.exe -Command "code -n ./backend/"
        powershell.exe -Command "code -n ./frontend/"
        echo "Opening Docker Desktop..."
        powershell.exe -Command "docker desktop start"
        echo "Starting containers in new terminal..."
        powershell.exe -Command "Start-Process powershell -ArgumentList 'docker compose up -d --build'"
        echo "Finished setup."
        ;;
    test-cmd)
        echo "This is a test command"
        ;;
    *)
        echo "Usage: $0 {up|down|rs|app|open-project|test-cmd}"
        exit 1
        ;;
esac