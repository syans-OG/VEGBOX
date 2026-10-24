# VegBox

VegBox is a Flutter grocery app for fresh vegetables from local farms. This project was built for the DNCC mobile development assignment and covers the complete shopping flow: sign in, browse, search, add to cart, apply a promo, check out, and review orders.

The interface is in English, while vegetable names, categories, and descriptions remain in Bahasa Indonesia, matching the supplied API data.

## Features

- Demo login and registration with form validation.
- Home page with search, category filters, a "Popular this week" discovery row, saved address picker, and a floating cart.
- Save vegetables to favorites with a heart button, then revisit them from the Favorites page.
- Product detail with quantity selection, favorite toggle, and delivery information.
- Cart with quantity controls, item removal, and promo code support.
- Checkout with the saved address, payment method selection, order summary, delivery fee, and simulated order placement.
- Order history with statuses, order details, a status timeline, cancellation, and "Buy again".
- Notifications with unread state and "Mark all as read".
- Profile editing, notification preferences, FAQ, and logout.
- Responsive layout with wider sheets and navigation on tablets and desktop.
- Offline-friendly product data: if the API is unavailable, the app loads the bundled JSON and local photos.

## Demo account

| Field | Value |
| --- | --- |
| Phone | `085191039930` |
| Password | `password123` |

The login screen also accepts any phone number with at least 9 digits and a password of at least 6 characters.

## Promo and delivery rules

- Promo code `PAYDAY` gives a 10% discount.
- Delivery costs Rp 12.000.
- Delivery is free for orders of Rp 100.000 or more.

## Tech stack

- Flutter 3.38 / Dart 3.10
- `dio` for HTTP requests
- `get_it` for dependency injection
- `ChangeNotifier` and `AnimatedBuilder` for app state
- Local JSON and image assets for offline fallback

## Project structure

```text
lib/
├── core/
│   ├── constants/      # API endpoint, promo, delivery, category labels
│   ├── di/             # get_it setup
│   ├── network/        # Dio client
│   └── utils/          # currency and form validation
├── models/             # Vegetable, cart item, order, notification
├── services/           # API, cart, favorites, orders, notifications, user session
├── ui/
│   ├── colors.dart
│   ├── theme.dart
│   ├── typography.dart
│   └── widgets/        # buttons, fields, cards, stepper, empty state
├── auth_page.dart
├── home_page.dart
├── detail_page.dart
├── cart_page.dart
├── favorites_page.dart
├── history_page.dart
├── order_detail_page.dart
├── notifications_page.dart
├── profile_page.dart
└── root_shell.dart
```

## Run the app

```bash
flutter pub get
flutter run
```

Choose a device when prompted. For the web build:

```bash
flutter run -d chrome
```

Do not open `web/index.html` directly; run the app through Flutter so the generated bootstrap files are available.

## API and data

The app requests:

```text
GET https://api-mobile.dnccudinus.org/api/vegetables
```

If the request fails, it falls back to `asset/data/vegetables.json` and shows a "Showing saved picks" banner with a retry action. Product photos are stored locally in `asset/image/vegetables/`, so the main screens still render without a network connection.

API provided by DNCC UDINUS for learning purposes.

## Verification

The project passes:

```bash
flutter analyze
flutter test
```

The suite covers order placement, unique order IDs, status progression and cancellation rules, favorites, snackbar auto-hide and queueing, the cart-to-checkout flow, order detail actions, favorites access from Profile, and semantics for key controls.

## Credits

- Vegetable data and image references: DNCC mobile vegetables API (`api-mobile.dnccudinus.org`).
- Cached product photos: image URLs from the API, which reference Unsplash and Wikimedia Commons.
- Fonts: Poppins and DM Serif Display, licensed under the SIL Open Font License.
