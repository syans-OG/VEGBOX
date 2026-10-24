# VegBox

VegBox is a Flutter grocery app for fresh vegetables from local farms. This project was built for the DNCC mobile development assignment and covers the complete shopping flow: sign in, browse, search, add to cart, apply a promo, check out, and review orders.

The interface is in English, while vegetable names, categories, and descriptions remain in Bahasa Indonesia, matching the provided dataset.

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
- Offline-friendly product data: if the remote catalog is unavailable, the app loads the bundled JSON and local photos.

## Project structure

```text
lib/
├── core/
│   ├── constants/      # app constants
│   ├── di/             # get_it setup
│   ├── network/        # Dio client
│   └── utils/          # currency and form validation
├── models/             # Vegetable, cart item, order, notification
├── services/           # catalog, cart, favorites, orders, notifications, user session
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
