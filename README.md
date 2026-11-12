# Travel Buddy Finder

**Travel Buddy Finder** is a cross-platform mobile & web application built with Flutter that helps travelers find companions for their journeys. Users can browse and filter trips posted by other travelers, send join requests, create and manage their own trips, comment on trip posts, chat in real-time with hosts and fellow travelers, and manage their travel profiles.

---

## Features

### Authentication & Authorization
- **Onboarding Flow** – Splash screen, Login, Signup, Forgot Password with OTP verification, and Reset Password screens
- **JWT Authentication** – Stateless JWT tokens persisted in `SharedPreferences` with automated Bearer Token headers via `ApiClient`
- **Form Validation** – Real-time input validation via centralized validators
- **Multipart Registration** – Profile picture & NID card upload support

### Home & Explore Trips
- **Home Feed & Explore Screen** – Browse community-posted trips in **Grid & List** layouts with pull-to-refresh
- **Search** – Search trips by title, location, description, or host name
- **Advanced Filters** – Filter trips by:
  - Budget (price cap slider)
  - Gender preference
  - Category (Adventure, Beach, Cultural, Family, Romantic, Wildlife)
  - Transportation methods (multi-select chips)
  - Sort by: Recommended, Price (low–high / high–low), Highest-rated
- Active filter tags with quick one-tap removal

### Trip Details & Community Discussion
- Full-screen trip view with collapsible image header and Hero animations
- Host profile card with avatar, verification badge, and tap-to-view host profile
- Trip overview: budget (`৳`), seat availability, gender preference, category, and transportation method icons
- **Community Comments & Replies** – API-backed comments (`get_comments`, `add_comment`, `reply_comment`) with nested reply sheets
- **"Join Trip Now"** action to submit a trip join request

### Creating & Managing Trips
- **Add New Trip** form with:
  - Trip title & destination
  - Date picker (start & end dates)
  - Budget input
  - Category dropdown
  - Description field
  - Multi-select transportation methods
  - Seats counter
  - Cover photo picker (gallery upload with Base64/multipart handling)
- **Owner-Only Edit & Delete** – Only the trip host (`CurrentUser.isCurrentUser`) sees card edit controls and can access `EditTripScreen`, with delete confirmation dialogs
- **My Trips** screen displaying trips created by the current user

### Real-Time Messenger, Chat & In-App Notifications
- **Chat Inbox** – Displays active conversations with last message preview, timestamp, and unread count chips
- **Direct Chat Initiation** – Start a chat directly from a user's profile (`_openDirectChat`) or from any trip card/detail view
- **Smart Live Polling** – Inbox polling and 2-second chat room polling with `last_id` tracking for real-time messaging without WebSocket overhead
- **In-App Notification Banner** – Animated slide-down overlay banner (`InAppNotificationService`) when a new chat message arrives, with tap-to-open chat room and 5-second auto-dismiss
- **Bottom Navigation Badge** – Live unread message badge on the Chat tab
- Automatic message seen-status synchronization upon opening a chat room

### User Profile & Account Settings
- Personal & public traveler profiles bound to `AuthProvider` / `ProfileProvider`
- Gender-aware default fallback avatars (`dummy_boy.jpg` / `dummy_girl.png`) and custom image URL resolution
- Stats display (completed trips, followers, average rating)
- Travel interests & **Achievements / Badges** (`🏅 Wanderlust`, `🔥 5-Streak`, `🛡️ ID Verified`)
- Quick actions: **Bookmarks**, **Trip Approvals** (with pending count badge), and **My Trips**
- Edit profile, change password via API, & manage account settings (language, currency, privacy/notifications)
- Follow / unfollow other travelers

### Trip Requests & Approvals
- Send join requests to trip hosts (`join_trip`)
- Host approval workflow via a slide-out **Approvals Drawer** (`pending_requests`, `accept_request`, `reject_request`, `respond_request`)
- Pending / approved / rejected status tracking

### Ratings & Reviews
- **Rating Screen** with 1–5 star selection and dynamic feedback labels
- Quick-select review tags (Friendly Host, Safe & Reliable, etc.)
- Free-text review box with recommendation toggle and confirmation dialog

### Bookmarks
- API-backed bookmarks (`add_bookmark`, `remove_bookmark`, `my_bookmarks`) with `BookmarkProvider`
- Optimistic UI updates for instant bookmark toggling

### Notifications
- Notification center listing approval and activity updates with read/unread states
- Mark all as read & swipe-to-dismiss notifications

---

## Technology Stack

| Layer | Technology |
|---|---|
| Framework | [Flutter](https://flutter.dev) (Dart SDK `^3.5.3`) |
| Architecture | **Feature-First + Centralized API Architecture** (`api/` + `core/` + `features/`) |
| State Management | `provider` (`^6.1.2`) with `MultiProvider` (`AuthProvider`, `BookmarkProvider`, `ChatProvider`, `CommentProvider`, `ProfileProvider`, `TripProvider`, `TripRequestProvider`) + `ValueNotifier` |
| Networking | `http` (`^1.2.2`) & `http_parser` (`^4.1.0`) via custom `ApiClient` with Bearer Token & multipart support |
| Local Storage | `shared_preferences` (`^2.3.2`) |
| Media & Assets | `image_picker` (`^1.1.2`), `flutter_svg` (`^2.1.0`) |
| Formatting & Icons | `intl` (`^0.20.2`), `cupertino_icons` (`^1.0.8`) |

---

## Project Structure

```text
lib/
├── app.dart                                  # Root MaterialApp with AppNavigator key
├── main.dart                                 # App entrypoint & MultiProvider registration
├── core/                                     # Shared utilities, constants, network & services
│   ├── constants/
│   │   ├── api_constants.dart                # Wrapper helpers for base URL & image resolution
│   │   ├── app_colors.dart                   # Centralized color palette
│   │   ├── app_lists.dart                    # Static option lists (genders, countries, categories)
│   │   ├── asset_path.dart                   # Asset path constants
│   │   └── url.dart                          # AppUrl with all API endpoints & image URL resolver
│   ├── network/
│   │   └── api_client.dart                   # HTTP client with Bearer token & multipart upload
│   ├── services/
│   │   └── in_app_notification_service.dart  # Animated overlay banner for incoming chat messages
│   ├── utils/
│   │   └── validators.dart                   # Form field validators
│   └── widgets/
│       ├── input_decoration.dart             # Shared InputDecoration helper
│       └── screen_background.dart            # Shared screen background widget
├── api/                                      # Centralized REST API Layer
│   ├── models/                               # Data Models
│   │   ├── bookmark_model.dart
│   │   ├── chat_room_model.dart
│   │   ├── comment_model.dart
│   │   ├── message_model.dart
│   │   ├── trip_model.dart
│   │   └── user_model.dart
│   ├── controllers/                          # API Controllers
│   │   ├── auth_controller.dart
│   │   ├── bookmark_controller.dart
│   │   ├── chat_controller.dart
│   │   ├── comment_controller.dart
│   │   ├── profile_controller.dart
│   │   └── trip_controller.dart
│   └── providers/                            # ChangeNotifier State Providers
│       ├── auth_provider.dart
│       ├── bookmark_provider.dart
│       ├── chat_provider.dart
│       ├── comment_provider.dart
│       ├── profile_provider.dart
│       ├── trip_provider.dart
│       └── trip_request_provider.dart
└── features/                                 # Feature UI & Presentation Layer
    ├── auth/presentation/                    # Splash, Login, SignUp, ForgotPassword, ResetPassword
    ├── bookmarks/                            # BookmarksStore & BookmarksScreen
    ├── chat/presentation/screens/            # ChatInboxScreen & ChatRoomScreen
    ├── navigation/presentation/              # MainNavScreen, MainBottomNavBar, BottomNavItem, MainFAB
    ├── notifications/                        # Notification models, store & NotificationsScreen
    ├── profile/                              # CurrentUser, UserProfile, EditProfile, ChangePassword, Settings
    └── trips/                                # Home, Explore, ViewTrip, AddTrip, EditTrip, MyTrips, Rating, Comments, ApprovalsDrawer
```

---

## API Endpoints Overview

All endpoints are configured relative to `AppUrl.baseUrl` (`http://localhost/travel_buddy/api`) in `lib/core/constants/url.dart`:

- **Auth:** `/login`, `/registration`, `/forgot_password`, `/verify_otp`, `/reset_password`, `/change_password`, `/logout`
- **Profile:** `/profile`, `/update_profile`
- **Trips & Requests:** `/all_trips`, `/category_trips`, `/create_trip`, `/update_trip`, `/delete_trip`, `/join_trip`, `/pending_requests`, `/accept_request`, `/reject_request`, `/respond_request`
- **Bookmarks:** `/add_bookmark`, `/remove_bookmark`, `/my_bookmarks`
- **Comments:** `/add_comment`, `/reply_comment`, `/get_comments`
- **Chat:** `/chat_rooms`, `/start_chat`, `/get_messages`, `/send_message`

---

## Getting Started

### Prerequisites

- **Flutter** SDK
- **Dart** SDK `^3.5.3`
- **Local XAMPP Server** with PHP 8+ and MariaDB (or compatible backend host)
- Android Studio / VS Code

### Installation

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd Travel_Buddy_Finder
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure the PHP Backend**
   - Start Apache & MySQL in the XAMPP Control Panel.
   - Place the PHP API files inside `htdocs/travel_buddy/api/`.
   - Update `AppUrl.baseUrl` in `lib/core/constants/url.dart` if your server host or path differs.

4. **Run the app**

   **Web (Chrome):**
   ```bash
   flutter run -d chrome
   ```

   **Mobile (Android / iOS):**
   ```bash
   flutter run
   ```

   **Production Web Build:**
   ```bash
   flutter build web
   ```
   *(Pre-built web artifacts are output to `build/web/`.)*

---

## Contributors

1. Pranta Nag
2. Yeasin Khan
3. galib

Thank you!
