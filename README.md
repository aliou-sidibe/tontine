# Ma Tontine

Application Android hors ligne pour suivre une tontine : qui a payé, ce qui reste dû, qui ramasse
à quel tour et ce que l'organisateur a avancé. Le plan et les décisions sont dans
[docs/plan.md](docs/plan.md), la maquette validée est
[ici](https://claude.ai/artifact/Ke5yYbUMEtzGqQ5SgH9htd).

## Prérequis

- Flutter 3.47 et le SDK Android.
- Le fichier `android/key.properties`, qui n'est pas dans Git (voir [Signature](#signature)).

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Vérifier avant une version

```bash
dart format .
flutter analyze
flutter test
```

## Générer l'APK

```bash
tool/build_apk.sh
```

Le script lance `flutter build apk --release --split-per-abi` (toujours avec `--split-per-abi`,
comme pour IP Caisse) puis copie les APK dans `build/release/` avec le nom de l'appli et la
version. Les options passées au script sont transmises à `flutter build apk`.

La version vient de `pubspec.yaml` (`version: 1.0.0+2` : version 1.0.0, build 2).
**Augmentez le numéro après le `+` à chaque nouvelle version**, sans jamais revenir en arrière :
Android refuse d'installer une version dont le numéro est plus petit que celui déjà installé.
Pour la changer sans modifier le fichier : `tool/build_apk.sh --build-name=1.1.0 --build-number=3`.

Les fichiers produits dans `build/release/` :

| Fichier | Pour |
|---|---|
| `MaTontine-1.0.0+2-arm64-v8a.apk` | La plupart des téléphones récents : c'est celui à envoyer |
| `MaTontine-1.0.0+2-armeabi-v7a.apk` | Les anciens téléphones 32 bits |
| `MaTontine-1.0.0+2-x86_64.apk` | L'émulateur |

L'APK s'envoie par WhatsApp, Drive ou câble USB. Sur le téléphone, il faut autoriser
l'installation d'applis inconnues. Faites une sauvegarde dans l'appli avant chaque mise à jour.

## Signature

Une seule clé pour toute la vie de l'appli : sans elle, impossible de mettre à jour sans
désinstaller, donc sans perdre les données.

```bash
keytool -genkeypair -v -keystore /chemin/hors/du/depot/ma-tontine.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias ma-tontine
cp android/key.properties.example android/key.properties   # puis remplir
```

Gardez le `.jks` et son mot de passe hors du dépôt, avec au moins deux copies.

## Polices

Inter et Space Grotesk sont embarquées dans `assets/fonts/` (licence SIL Open Font License,
fichiers `*-OFL.txt`), car l'appli fonctionne sans internet.
