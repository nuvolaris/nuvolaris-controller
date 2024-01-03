#!/bin/bash

# Interrompi lo script in caso di errori
set -e

# Rimozione delle cartelle build e server se esistono
echo "Pulizia delle cartelle build e server..."
rm -rf build/

# Pulizia del progetto Flutter
echo "Esecuzione di flutter clean..."
flutter clean

# Installazione delle dipendenze
echo "Installazione delle dipendenze con flutter pub get..."
dart pub get
dart pub upgrade

# Verifica delle dipendenze aggiornate
echo "Controllo delle dipendenze aggiornate con flutter pub outdated..."
dart pub outdated

# Creazione delle cartelle build e server
echo "Creazione delle cartelle build e server..."
mkdir -p build
chmod 755 build

# Compilazione del file main.dart situato nella cartella lib
echo "Compilazione del progetto..."
dart compile exe lib/main.dart -o build/server.exe

echo "Compilazione completata: il server è pronto in build/server.exe"

# generazione della macchina docker
echo "Generazione della macchina docker..."
docker build -t nuvolaris-swagger -f docker/Dockerfile .
