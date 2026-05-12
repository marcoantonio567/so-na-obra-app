# Only at the Construction Site

Flutter application focused on announcements and requests, with local persistence via SQLite (`sqflite`).

## Features

- Login and registration (local flow for demonstration)
- Tabbed navigation: Requests, Home (Ads), Create, Wallet, Profile
- Creation of ads and requests
- Upload of multiple images for ads (gallery)
- Search by text and filter by period (today / last 7 / last 30 days)
- Wallet (balance, purchase history and receipt confirmation via PIN)
- Profile (change name and photo, generate/copy receipt PIN)
- Local persistence (SQLite) and automatic seeds on first run

## Technologies

- Flutter / Dart
- `sqflite` + `path` (local database)
- `image_picker` (image selection)
- `shared_preferences` (simple preferences, e.g., PIN on the web)

## How to run

Prerequisites:

- Flutter installed and configured in the PATH
- Compatible Dart SDK (the project uses SDK: ^3.11.5

Commands:

```bash
flutter pub get
flutter run

```

Device tips:

```bash
flutter devices
flutter run -d chrome
flutter run -d windows

```

## How to use (demo)

- On the Login screen, enter any name and a password with at least 4 characters
- After logging in, use the Create tab to publish an ad (with images) or a request
- The Profile tab allows you to change your name and photo (location)

## Data and persistence

- Local database: `so_na_obra.db` (SQLite via `sqflite`)
- Main tables:

- `publicacoes`: ads and requests

- `user_settings`: user settings (e.g., `pin_recebimento`)
- Seeds: on the first run, the app automatically populates dummy posts (including examples with images).

## Project Structure

- `lib/app.dart`: app configuration and initial route
- `lib/screens/`: screens (login, main navigation, announcements, requests, create, profile, etc.)
- `lib/models/`: models (e.g., `Publicacao`)
- `lib/data/`: local database (`LocalDatabase`) and seeds
- `lib/services/`: rules for loading/saving publications
- `lib/widgets/`: reusable components (e.g., publication card)

## Notes

- Web: `sqflite` is not supported in the browser; some persistence functionalities may not work correctly in `-d chrome`.

## Testing and Analysis

```bash
flutter test
flutter analyze
```
