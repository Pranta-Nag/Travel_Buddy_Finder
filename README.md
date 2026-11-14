# Travel Buddy Finder ✈️🌍

**Travel Buddy Finder** is a modern, cross-platform mobile & web application built with **Flutter** that empowers travelers to connect, explore, and find trusted companions for their adventures. Users can browse community-posted trips, search and filter destinations, launch interactive maps with live GPS routing, send join requests, initiate real-time chats, and manage their travel profiles and account settings seamlessly.

---

## 📱 Highlights & Recent Enhancements

- 🏝️ **Modern Floating Capsule / Island Navigation Bar** – A floating, capsule-shaped dock with ambient dual-layer drop shadows, integrated center gradient action button (`+` Add Trip), active micro-dot indicators, tactile haptic feedback, and a smart Android **Double-Back-to-Exit** safety flow (`PopScope`).
- 🛰️ **Live Geolocation & Universal Maps (`geolocator` & `url_launcher`)** – One-tap location search and turn-by-turn routing directly from the user's live GPS coordinates to the trip's destination on Google Maps, Apple Maps, or web browsers, plus an interactive **Location & Navigation Sheet**.
- 🎨 **Unified Design System & Professional Palette** – Premium indigo primary (`#4F46E5`), deep slate contrast typography (`#0F172A`), rounded 14–16px card squircles, and refined input styling.
- ⚙️ **Airbnb/iOS-Style Account Settings** – Grouped card architecture (Account & Security, Preferences, Support & Legal, Session), semantic tinted squircles, and interactive bottom sheets for Notifications, Privacy, Language, and FAQs.
- 💬 **Live Chat with Real-Time In-App Banners** – Non-blocking live chat polling, unread badges, and an animated slide-down in-app notification banner (`InAppNotificationService`) for incoming messages.

---

## ✨ Features Overview

### 1. Authentication & Security
- **Onboarding Flow** – Splash screen, Login, Signup, Forgot Password with OTP verification, and Password Reset screens.
- **JWT Authentication** – Stateless JWT tokens persisted in `SharedPreferences` with automated Bearer Token injection via `ApiClient`.
- **Form Validation** – Centralized real-time validation for email, passwords, and user handles.
- **Multipart Registration** – Profile photo & National ID (NID) document upload support.

### 2. Home Feed & Explore Trips
- **Dual Layouts** – Browse trips in responsive **Grid** and **List** views with pull-to-refresh.
- **Smart Search** – Search trips dynamically by destination, title, host name, or keywords.
- **Multi-Parameter Filter Engine**:
  - Budget cap slider
  - Gender preference (Any, Female Only, Male Only)
  - Travel categories (Adventure, Beach, Cultural, Family, Romantic, Wildlife)
  - Transportation method filters (Flight, Train, Bus, Road Trip, Boat)
  - Sorting (Recommended, Price: Low–High / High–Low, Rating)
- **Active Filter Chips** – One-tap removable filter chips with reset capability.

### 3. Trip Details & Interactive Community Discussion
- Full-screen trip view with collapsible cover image header and smooth `Hero` animations.
- Host profile card with avatar, verified badge, and direct host profile access.
- Trip specifications: budget (`৳`), seat availability counter, gender preferences, and transportation badges.
- **Interactive Location Pill** – Tap any trip location badge to open the location on Google Maps; long-press to view live GPS coordinates and turn-by-turn routing.
- **Community Discussion & Comments** – API-backed discussion threads (`get_comments`, `add_comment`, `reply_comment`) with nested reply modal sheets.
- **"Join Trip Now"** – One-tap join request submission with host notification.

### 4. Interactive Geolocation & Navigation Engine
- **Live Device Location (`geolocator`)**:
  - Automatically queries device GPS state and handles runtime location permissions gracefully.
  - Fetches high-accuracy latitude & longitude to calculate proximity and routing.
- **Universal Map Opening (`url_launcher`)**:
  - Triple-tier launch cascade (`LaunchMode.externalApplication` ➔ `LaunchMode.platformDefault` ➔ `LaunchMode.inAppBrowserView`).
  - Automatically opens native Google Maps app on Android/iOS; falls back seamlessly to browser if no dedicated app is installed.
  - Generates turn-by-turn navigation routes with user's current GPS position as origin and trip destination as target.
- **Interactive Location Options Sheet**:
  - Displays destination details and live GPS status.
  - One-tap "Open in Google Maps", "Get Directions from My Location", and "Copy Location Name".

### 5. Creating & Managing Trips
- **Add New Trip Screen**:
  - Title, destination, and multi-date range picker.
  - Estimated budget, category selection, and detailed itinerary description.
  - Multi-select transportation tags and available seats counter.
  - Cover photo gallery picker with image preview.
- **Owner Controls** – Post hosts (`CurrentUser.isCurrentUser`) can access `EditTripScreen` and delete trips with confirmation dialogs.
- **My Trips Screen** – Clean portfolio of trips hosted by the authenticated user with live API synchronization.

### 6. Real-Time Messenger, Chat & In-App Notifications
- **Chat Inbox** – Active conversations list with last message snippet, timestamp, and unread counters.
- **Direct Messaging** – Instant 1-on-1 chat initiation from user profiles or trip cards.
- **Smart Live Polling** – Lightweight 2-second chat room polling with `last_id` delta updates (efficient real-time messaging without WebSocket complexity).
- **In-App Notification Banner** – Floating slide-down overlay banner (`InAppNotificationService`) when a new message arrives, allowing 1-tap room opening with auto-dismiss.
- **Live Badge Sync** – Real-time unread message counter badge on the Floating Island Chat tab.

### 7. User Profile & Account Settings
- Public & personal traveler profiles bound to `ProfileProvider`.
- Dual-ring avatar, verified traveler badge, and custom profile photo upload.
- Stats card with color accents: hosted trips, completed trips, followers, and average rating.
- Travel interests & achievement badges (`🏅 Wanderlust`, `🔥 5-Streak`, `🛡️ ID Verified`).
- Quick actions: Bookmarks, Approvals Drawer, and My Trips.
- **Manage Account Settings**:
  - Update email address with dialog validation.
  - Change password & Two-Factor Authentication (2FA) toggle.
  - Notification preferences (Push, Email, Trip Requests, Promos).
  - Privacy controls (Profile visibility, location display, direct messages).
  - Multi-language & preferred currency selectors.
  - Help & FAQs accordion with direct support mailer.
  - Secure, confirmation-gated logout flow.

### 8. Trip Requests & Host Approvals
- Send join requests (`join_trip`) with optional traveler notes.
- Host approval management via slide-out **Approvals Drawer** (`pending_requests`, `accept_request`, `reject_request`).
- Live pending counter badge on user profile.

---

## 🛠️ Technology Stack

| Layer | Technology / Package | Purpose |
|---|---|---|
| **Framework** | [Flutter](https://flutter.dev) (Dart SDK `^3.5.3`) | Cross-platform client framework (Android, iOS, Web, Desktop) |
| **Architecture** | **Feature-First + Centralized Service/API Layer** | Modular, scalable separation of concerns (`core/`, `api/`, `features/`) |
| **State Management** | `provider` (`^6.1.2`) | Reactive multi-provider state management (`AuthProvider`, `ProfileProvider`, `TripProvider`, `ChatProvider`, etc.) |
| **Location & GPS** | `geolocator` (`^13.0.4`) | Device location permissions, GPS coordinate retrieval, and accuracy tracking |
| **URL & Map Launching** | `url_launcher` (`^6.3.1`) | Universal map opening (Google Maps, Apple Maps, Web browsers, and In-App views) |
| **Networking** | `http` (`^1.2.2`) & `http_parser` (`^4.1.0`) | REST API client with Bearer Token auth and multipart file uploads |
| **Local Storage** | `shared_preferences` (`^2.3.2`) | Persistent storage for authentication tokens and user preferences |
| **Media & Images** | `image_picker` (`^1.1.2`), `flutter_svg` (`^2.1.0`) | Camera & gallery photo selection and SVG vector rendering |
| **Formatting & Icons** | `intl` (`^0.20.2`), `cupertino_icons` (`^1.0.8`) | Date/currency formatting and iconography |

---

## 📁 Project Directory Structure

```text
lib/
├── app.dart                                  # Root MaterialApp configuration & global navigator key
├── main.dart                                 # App entrypoint & MultiProvider registrations
├── core/                                     # Shared utilities, constants, network & services
│   ├── constants/
│   │   ├── api_constants.dart                # Base URL helpers & image resolution utilities
│   │   ├── app_colors.dart                   # Centralized design system color palette
│   │   ├── app_lists.dart                    # Static selection lists (categories, genders, currencies)
│   │   ├── asset_path.dart                   # Asset path constants
│   │   └── url.dart                          # AppUrl containing all backend REST endpoints
│   ├── network/
│   │   └── api_client.dart                   # Central HTTP client with Bearer token & multipart support
│   ├── services/
│   │   ├── in_app_notification_service.dart  # Animated overlay banner for incoming chat messages
│   │   └── location_service.dart             # Geolocator GPS & universal Google Maps integration
│   ├── utils/
│   │   └── validators.dart                   # Input field validation rules
│   └── widgets/
│       ├── input_decoration.dart             # Centralized InputDecoration styling
│       └── screen_background.dart            # Consistent gradient/pattern background wrapper
├── api/                                      # Centralized REST API Layer
│   ├── controllers/                          # Controllers orchestrating HTTP calls
│   │   ├── auth_controller.dart
│   │   ├── bookmark_controller.dart
│   │   ├── chat_controller.dart
│   │   ├── comment_controller.dart
│   │   ├── profile_controller.dart
│   │   └── trip_controller.dart
│   ├── models/                               # Strongly typed data models
│   │   ├── bookmark_model.dart
│   │   ├── chat_room_model.dart
│   │   ├── comment_model.dart
│   │   ├── message_model.dart
│   │   ├── trip_model.dart
│   │   └── user_model.dart
│   └── providers/                            # ChangeNotifier State Providers
│       ├── auth_provider.dart
│       ├── bookmark_provider.dart
│       ├── chat_provider.dart
│       ├── comment_provider.dart
│       ├── profile_provider.dart
│       ├── trip_provider.dart
│       └── trip_request_provider.dart
└── features/                                 # Feature-specific UI & Presentation Layer
    ├── auth/presentation/                    # Splash, Login, SignUp, ForgotPassword, ResetPassword
    ├── bookmarks/                            # Saved trips feed & bookmark store
    ├── chat/presentation/screens/            # ChatInboxScreen & live ChatRoomScreen
    ├── navigation/presentation/              # MainNavScreen & Floating Capsule / Island Navigation Bar
    │   ├── main_nav_screen.dart              # Root Scaffold with PopScope double-back safety
    │   └── widgets/
    │       ├── bottom_nav_item.dart          # Island navigation item with active dot & micro-animations
    │       ├── main_bottom_nav_bar.dart      # Floating Capsule / Island Bar with integrated center FAB
    │       └── main_fab.dart                 # Standalone action button component
    ├── notifications/                        # In-app notifications feed
    ├── profile/presentation/                 # UserProfileScreen, EditProfileScreen, ManageAccountSettings
    └── trips/                                # HomeTab, ExploreScreen, ViewScreen, AddNewTripScreen,
                                              # EditTripScreen, MyTrips, RatingScreen, TripCard
```

---

## 🌐 API Endpoints Reference

All endpoints are defined in `lib/core/constants/url.dart` relative to `AppUrl.baseUrl` (`http://localhost/travel_buddy/api`):

| Module | Endpoints | Description |
|---|---|---|
| **Auth** | `/login`, `/registration`, `/forgot_password`, `/verify_otp`, `/reset_password`, `/change_password`, `/logout` | User registration, authentication, and password management |
| **Profile** | `/profile`, `/update_profile` | Fetching and updating user profile data |
| **Trips** | `/all_trips`, `/category_trips`, `/create_trip`, `/update_trip`, `/delete_trip` | Trip catalog, category filtering, and CRUD operations |
| **Requests** | `/join_trip`, `/pending_requests`, `/accept_request`, `/reject_request`, `/respond_request` | Trip joining, approval drawer, and status responses |
| **Bookmarks** | `/add_bookmark`, `/remove_bookmark`, `/my_bookmarks` | Saving and managing bookmarked trips |
| **Comments** | `/add_comment`, `/reply_comment`, `/get_comments` | Community discussion threads on trips |
| **Chat** | `/chat_rooms`, `/start_chat`, `/get_messages`, `/send_message` | Real-time conversations and message delivery |

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK** (`^3.5.3` or later)
- **Dart SDK** (`^3.5.3` or later)
- **Local Server** (e.g. XAMPP with Apache & MariaDB/MySQL) for the backend API
- Android Studio / VS Code with Flutter extension
- Physical Android/iOS device or Emulator

### Installation & Run

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/Travel_Buddy_Finder.git
   cd Travel_Buddy_Finder
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Backend Setup (XAMPP)**
   - Start **Apache** and **MySQL** in XAMPP.
   - Place backend PHP API files in `htdocs/travel_buddy/api/`.
   - Import the database schema (`travel_buddy.sql`).
   - If using a physical mobile device, replace `localhost` in `lib/core/constants/url.dart` with your machine's local IP (e.g. `http://192.168.x.x/travel_buddy/api`).

4. **Launch Application**
   - **Mobile (Android / iOS):**
     ```bash
     flutter run
     ```
   - **Web (Chrome):**
     ```bash
     flutter run -d chrome
     ```
   - **Production Web Build:**
     ```bash
     flutter build web --base-href /travel_buddy/
     ```
     *(Web output is placed in `build/web/`.)*

---

## 👥 Contributors

This project was developed by:

1. **Pranta Nag**
2. **Yeasin Khan**
3. **Abdullah Mohammad Galib**

---

⭐ **Thank you for exploring Travel Buddy Finder!**
