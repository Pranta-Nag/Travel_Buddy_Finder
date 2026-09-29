# Travel Buddy Finder

**Travel Buddy Finder** is a mobile application built with Flutter that helps travelers find companions for their journeys. Users can browse trips posted by other travelers, join trips as companions, create their own trips, and connect with like-minded adventurers.

---

## Features

### Authentication
- **Onboarding Flow** – Splash screen, Login, Signup, and Forgot Password screens
- Form validation with real-time input checking

### Explore Trips
- Browse a list of trips shared by the community
- **Search** trips by title, location, description, or host name
- **Filter** trips by:
  - Budget (price cap slider)
  - Gender preference
  - Category (Adventure, Beach, Cultural, Family, Romantic, Wildlife)
  - Transportation methods (multi-select chips)
  - Sort by: Recommended, Price (low–high / high–low), Highest-rated
- **Grid & List** view layouts
- Active filter indicators with quick removal
- Pull-to-refresh

### Trip Details
- Full-screen trip view with collapsible image header and Hero animations
- Host profile card with avatar and verification badge
- Trip overview: price, availability, gender preference, category
- Transportation method icons
- **Community discussion** section with comments
- Post comments and ask the host questions
- "Join Trip Now" action that creates a trip request

### Creating & Managing Trips
- **Add New Trip** form with:
  - Trip title & destination
  - Date picker (start & end dates)
  - Budget input
  - Category dropdown
  - Description field
  - Multi-select transportation methods
  - Seats counter
  - Cover photo picker (from gallery)
- **Edit Trip** screen for modifying existing trips
- **Delete** trips with confirmation dialog
- **My Trips** screen showing trips created by the current user

### User Profile
- Personal profile with avatar, name, and level
- Stats display (completed trips, followers, avg rating)
- Travel interests and achievement badges
- Quick actions: Bookmarks, Trip Approvals, My Trips
- Edit profile & manage account settings
- Follow other travelers

### Trip Requests & Approvals
- Send join requests to trip hosts
- Host approval workflow via a slide-out **Approvals Drawer**
- Pending / approved / rejected status tracking

### Ratings
- **Rating screen** with 1–5 star selection
- Quick-select tags (Friendly Host, Safe & Reliable, etc.)
- Free-text review box with recommendation toggle
- Success confirmation dialog

### Bookmarks
- Save interesting trips to a personal bookmarks list
- Bookmark list persists across the session (in-memory store)

### Notifications
- List of user notifications with read/unread states
- Mark all as read
- Dismissible notifications (swipe to delete)

### Navigation
- Bottom navigation bar (Home, Explore, Chat, Profile)
- Floating Action Button to create a new trip
- Responsive layout adapting to mobile, tablet, and web

---

## Technology Stack

| Layer        | Tech                        |
|--------------|-----------------------------|
| Framework    | [Flutter](https://flutter.dev) 3.44.9 (Dart SDK ^3.5.3) |
| State        | `ValueNotifier` + `ValueListenableBuilder` |
| Image Picker | `image_picker` `^1.1.2`     |
| SVG Rendering| `flutter_svg` `^2.1.0`      |
| Intl         | `intl` `^0.20.2`            |
| Icons        | `cupertino_icons` `^1.0.8`  |
| Testing      | `flutter_lints` `^4.0.0`, `flutter_test` |

### Target Platforms
- **Mobile** – Android & iOS (native project templates included)
- **Web** – Standalone PWA manifest with maskable icons
- **Desktop** – macOS runner included

---

## Project Structure

```
lib/
├── app.dart                      # Root MaterialApp widget
├── main.dart                     # App entry point
├── config/
│   ├── app_colors.dart           # Centralized color palette
│   ├── app_lists.dart            # Static option lists (genders, countries, categories)
│   ├── asset_path.dart           # Asset path constants
│   └── validators.dart           # Form input validators
├── models/
│   ├── trip.dart                 # Trip data model (with copyWith)
│   ├── trip_data.dart            # In-memory seed trip list
│   ├── trip_request.dart         # Join-request model & status enum
│   └── app_notification.dart     # Notification model
├── stores/
│   ├── current_user.dart         # Current user constants
│   ├── trip_store.dart           # Global trip state (add/update/remove)
│   ├── trip_request_store.dart   # Trip request state management
│   ├── notification_store.dart   # Notifications state
│   └── bookmark_store.dart       # Bookmark/saved-trips state
├── screens/
│   ├── splash_screen.dart        # 3-second splash → Login
│   ├── login_screen.dart         # Login form
│   ├── sign_up_screen.dart       # Registration form
│   ├── forgot_pass_screen.dart   # Password reset
│   ├── main_nav_screen.dart      # Bottom-nav scaffolding
│   ├── explore_screen.dart       # Trip browsing & filtering
│   ├── home_tab.dart             # Home feed with categories
│   ├── view_screen.dart          # Trip detail page
│   ├── add_new_trip_screen.dart  # Trip creation form
│   ├── edit_trip_screen.dart     # Trip editing form
│   ├── my_trip_screen.dart       # User's created trips
│   ├── bookmarks_screen.dart     # Saved/bookmarked trips
│   ├── notifications_screen.dart # Notifications list
│   ├── rating_screen.dart        # Submit a trip review
│   ├── user_profile_screen.dart  # User profile page
│   ├── manage_account_settings_screen.dart  # Account settings
│   └── comment_screen.dart       # Comments view
└── widgets/
    ├── screen_background.dart    # Shared background widget
    ├── bottom_nav_item.dart      # Nav bar item component
    ├── main_bottom_nav_bar.dart  # Bottom navigation bar
    ├── main_fab.dart             # Floating action button
    ├── trip_card.dart            # Reusable trip card
    ├── chat_tab.dart             # Chat placeholder tab
    ├── input_decoration.dart     # Shared InputDecoration helper
    ├── add_trip/                 # Add-trip section widgets
    ├── explore/                  # Explore-screen sub-widgets
    ├── home/                     # Home-tab sub-widgets
    ├── rating/                   # Rating-screen sub-widgets
    └── trip_request/             # Approval drawer widgets
```

---

## Getting Started

### Prerequisites

- **Flutter** SDK 3.44.9 (specified in `.fvmrc`)
- **Dart** SDK ^3.5.3
- Android Studio / Xcode (for mobile device emulation)
- A code editor (VS Code recommended – `.vscode/settings.json` is preconfigured)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd Travel_Buddy_Finder
   ```

2. **(Recommended) Use FVM** — Flutter Version Management
   ```bash
   fvm use 3.44.9
   fvm flutter pub get
   ```

   Or, if not using FVM:
   ```bash
   flutter pub get
   ```

3. **Run the app**

   **Mobile (Android/iOS):**
   ```bash
   flutter run
   ```

   **Web:**
   ```bash
   flutter run -d chrome
   ```

   **macOS:**
   ```bash
   flutter run -d macos
   ```

4. **Hot reload** during development:
   ```bash
   flutter run  # then press 'r' in the terminal
   ```

### Building for Release

| Platform  | Command |
|-----------|---------|
| Android   | `flutter build apk --release` |
| iOS       | `flutter build ios --release` |
| Web       | `flutter build web --release` |
| macOS     | `flutter build macos --release` |

---

## Testing

The project includes a default widget test. Run it with:

```bash
flutter test
```

Or for a specific file:

```bash
flutter test test/widget_test.dart
```

---

## Key Packages

| Package           | Version  | Purpose                          |
|-------------------|----------|----------------------------------|
| `image_picker`    | `^1.1.2` | Pick images from camera/gallery  |
| `intl`            | `^0.20.2`| Date formatting & i18n           |
| `flutter_svg`     | `^2.1.0` | Render SVG assets                |
| `cupertino_icons` | `^1.0.8` | iOS-style icon set               |
| `flutter_lints`   | `^4.0.0` | Recommended lint rules           |
| `flutter_test`    | —        | Testing framework                |

---

## State Management

State is managed using Flutter's built-in `ValueNotifier` / `ValueListenableBuilder` pattern with static store classes:

| Store                 | Responsibility                          |
|-----------------------|-----------------------------------------|
| `TripStore`           | CRUD operations on trips                |
| `BookmarkStore`       | Save/unsave bookmarked trips            |
| `TripRequestStore`    | Trip join-request lifecycle             |
| `NotificationStore`   | Notification CRUD & read status         |
| `CurrentUser`         | Current user constants (name/username)  |

---

## Design

- **Color palette**: Primary green (`#1BC721`), indigo accents, neutral greys
- **Responsive layout**: Grid columns adjust based on screen width (<600px: 1–2 cols, ≥1000px: 3–4 cols)
- **Assets**: Logo and background SVG in `assets/images/`
- **Web**: PWA manifest with standalone display and maskable icons

---

## Contributors

1. Pranta Nag
2. Yeasin Khan
3. galib

Thank you!
