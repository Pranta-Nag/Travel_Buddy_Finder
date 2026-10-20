# Travel Buddy Finder

**Travel Buddy Finder** is a mobile & web application built with Flutter that helps travelers find companions for their journeys. Users can browse trips posted by other travelers, join trips as companions, create their own trips, chat in real-time with hosts, and connect with like-minded adventurers.

---

## Features

### Authentication & Authorization
- **Onboarding Flow** – Splash screen, Login, Signup, Forgot Password with OTP, and Reset Password screens
- **JWT Authentication** – Stateless JWT tokens saved in `SharedPreferences` with Bearer Token headers
- Form validation with real-time input checking
- Multipart form-data registration with Profile Picture & NID Card copy upload

### Explore Trips & Feed
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
- **Community discussion** section with top-level comments and nested replies
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

### Real-Time Messenger & Chat Engine
- **Chat Inbox** displaying active conversations with last message, time, and unread badges
- **Smart Live Polling** engine (2-second interval with `last_id` tracking) for real-time messaging without WebSocket overhead
- Automatic message `seen_status` updates when entering chat rooms
- Auto-scrolling chat room interface

### User Profile & Settings
- Personal profile with dynamic logged-in user data
- Stats display (completed trips, followers, avg rating)
- Travel interests and achievement badges
- Quick actions: Bookmarks, Trip Approvals, My Trips
- Edit profile, change password via API, & manage account settings
- Follow other travelers

### Trip Requests & Approvals
- Send join requests to trip hosts
- Host approval workflow via a slide-out **Approvals Drawer**
- Pending / approved / rejected status tracking

### Ratings & Reviews
- **Rating screen** with 1–5 star selection
- Quick-select tags (Friendly Host, Safe & Reliable, etc.)
- Free-text review box with recommendation toggle
- Success confirmation dialog

### Bookmarks
- Save interesting trips to a personal bookmarks list
- Optimistic UI updates for instant bookmark toggling

### Notifications
- List of user notifications with read/unread states
- Mark all as read
- Dismissible notifications (swipe to delete)

---

## Technology Stack

| Layer        | Tech                        |
|--------------|-----------------------------|
| Framework    | [Flutter](https://flutter.dev) (Dart SDK ^3.5.3) |
| Architecture | **Feature-First Architecture** |
| State        | `Provider` (`ChangeNotifier` + `Consumer`) + `ValueNotifier` |
| Networking   | `http` `^1.2.2` with custom `ApiClient` & Bearer Token |
| Storage      | `shared_preferences` `^2.3.2` |
| Image Picker | `image_picker` `^1.1.2`     |
| SVG Rendering| `flutter_svg` `^2.1.0`      |
| Intl         | `intl` `^0.20.2`            |
| Icons        | `cupertino_icons` `^1.0.8`  |

---

## Project Structure

```
lib/
├── app.dart                      # Root MaterialApp widget
├── main.dart                     # App entry point with MultiProvider setup
├── core/                         # Shared core utilities & constants
│   ├── constants/
│   │   ├── api_constants.dart    # Central API constants
│   │   ├── app_colors.dart       # Centralized color palette
│   │   ├── app_lists.dart        # Option lists (genders, countries, categories)
│   │   ├── asset_path.dart       # Asset path constants
│   │   └── url.dart              # Base API URL configuration
│   ├── network/
│   │   └── api_client.dart       # Base HTTP client with Bearer Token & multipart
│   ├── utils/
│   │   └── validators.dart       # Form input validators
│   └── widgets/
│       ├── input_decoration.dart # Shared InputDecoration helper
│       └── screen_background.dart# Shared background widget
└── features/                     # Feature-First Modules
    ├── auth/                     # Authentication & Password Recovery
    │   ├── data/
    │   │   ├── models/           # UserModel
    │   │   ├── services/         # AuthService (REST API calls)
    │   │   └── providers/        # AuthProvider (State Management)
    │   └── presentation/         # Auth Screens (Login, SignUp, ForgotPass, ResetPass)
    ├── navigation/               # App Navigation Shell
    │   └── presentation/         # MainNavScreen, BottomNavBar, MainFAB
    ├── profile/                  # User Profile & Settings
    │   ├── data/                 # CurrentUser store
    │   └── presentation/         # UserProfileScreen, EditProfile, ChangePassword, ManageSettings
    ├── trips/                    # Trips Feed, Details, Creation & Reviews
    │   ├── data/
    │   │   ├── models/           # Trip, TripData, TripRequest, Review models
    │   │   └── stores/           # TripStore, TripRequestStore, ReviewStore
    │   └── presentation/         # Explore, ViewTrip, AddTrip, EditTrip, MyTrips, Rating, Comments screens & widgets
    ├── bookmarks/                # Saved / Bookmarked Trips
    │   ├── data/                 # BookmarkStore
    │   └── presentation/         # BookmarksScreen
    ├── notifications/            # User Notifications
    │   ├── data/                 # AppNotification, NotificationStore
    │   └── presentation/         # NotificationsScreen
    └── chat/                     # Real-Time Messenger & Chat Engine
        ├── data/
        │   ├── models/           # ChatRoomModel, MessageModel
        │   ├── services/         # ChatService (REST API calls)
        │   └── providers/        # ChatProvider (Smart Polling Engine)
        └── presentation/         # ChatInboxScreen & ChatRoomScreen
```

---

## Getting Started

### Prerequisites

- **Flutter** SDK
- **Dart** SDK ^3.5.3
- **Local XAMPP Server** with PHP 8+ and MariaDB
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd Travel_Buddy_Finder
   ```

2. **Get Dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Local XAMPP Backend**
   - Start Apache & MySQL in XAMPP Control Panel.
   - Place PHP API files inside `htdocs/travel_buddy/api/`.
   - Update `lib/core/constants/url.dart` with your base URL if needed.

4. **Run the app**

   **Web:**
   ```bash
   flutter run -d chrome
   ```

   **Mobile (Android/iOS):**
   ```bash
   flutter run
   ```

---

## Contributors

1. Pranta Nag
2. Yeasin Khan
3. galib

Thank you!
