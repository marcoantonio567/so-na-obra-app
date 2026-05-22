# So na Obra

Flutter app for connecting people who have materials available at a
construction site with people looking for products, services, or negotiation
opportunities.

The project currently runs as a local demo: ads and requests are persisted on
the device, while login, registration, wallet, purchases, and chats use
simulated flows to validate the app experience.

## Features

- Login and registration forms with validation for the demo flow.
- Main navigation with requests, ads, create, wallet, and profile tabs.
- Creation of ads and requests with title, description, and value.
- Ads with gallery photos, local pickup or delivery, ZIP code, price per
  kilometer, and an option to accept offers.
- Text search and date range filters for ad and request lists.
- Publication detail screens and automatically loaded seed data for manual
  testing.
- Profile editing for name and photo, user publication lists, and receipt PIN
  management.
- Demo wallet with balance, simulated withdrawals, purchase history, and
  receipt confirmation by PIN.
- Seeded chat list and conversations available from the top chat button.

## Technologies

- Flutter and Dart.
- `sqflite` and `path` for the local SQLite database.
- `image_picker` for product and profile image selection.
- `shared_preferences` for simple preferences, including receipt PIN support.

## Running the app

### Requirements

- Flutter installed and available in the `PATH`.
- Dart compatible with the project SDK constraint: `^3.11.5`.
- An emulator, physical device, or Flutter-enabled desktop platform.

### Commands

```bash
flutter pub get
flutter run
```

To choose a target device:

```bash
flutter devices
flutter run -d windows
flutter run -d chrome
```

## Demo walkthrough

1. On the login screen, enter any name and a password with at least four
   characters.
2. Open the `Criar` tab to publish an ad or a request.
3. Use `Home Page` to browse ads and `Solicitacoes` to browse requests with
   search and date filters.
4. In `Perfil`, change the name or photo, review your publications, and
   generate the receipt PIN.
5. In `Carteira`, use that PIN to confirm receipt of a demo purchase.

## Local data

The local database uses the SQLite file `so_na_obra.db`.

| Table | Purpose |
| --- | --- |
| `publicacoes` | Ads, requests, serialized images, and delivery data. |
| `user_settings` | Local user settings such as `pin_recebimento`. |

When the app starts without enough publications, it inserts seed data to fill
the lists. If the local database becomes unavailable during loading, the main
flow shows seeded publications as a fallback.

## Project structure

```text
lib/
  app.dart                 app configuration
  data/                    local database and publication seeds
  models/                  publication and purchase models
  screens/                 login, tabs, details, chat, profile, and wallet
  services/                publication loading and saving
  theme/                   colors and visual theme
  utils/                   value and date formatting
  widgets/                 reusable components
```

## Notes

- The project does not include a backend, real authentication, real payments,
  or cross-device synchronization at this stage.
- In the browser, `sqflite` does not provide the same local SQLite support used
  on mobile and desktop. The app may fall back to seeded data, and some
  persistence behavior may be limited when running with `-d chrome`.

## Quality checks

```bash
flutter analyze
flutter test
```
