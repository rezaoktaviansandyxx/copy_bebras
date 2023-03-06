# Flux

Flux project

## Building

- Install the latest flutter sdk, follow official guide here [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
- Install [https://github.com/leoafarias/fvm](https://github.com/leoafarias/fvm) with the following command: ```flutter pub global activate fvm```
- Open project root directory in terminal and install spesific flutter version with: ```fvm install```
- Check if everything is good: ```fvm flutter doctor```
- Install dependencies ```fvm flutter pub get```
- Open terminal on current project ```fvm flutter packages pub run build_runner watch --delete-conflicting-outputs``` and wait until it's completed usually shows 'Succeeded ...'
- Try run flutter with F5 or ```fvm flutter run```

To make sure everything consistent, use [https://github.com/leoafarias/fvm](https://github.com/leoafarias/fvm) instead, unless the global path also uses the **same** version