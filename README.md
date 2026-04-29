# Offline-First Customer Visit Management App

A production-ready Flutter mobile application that demonstrates offline-first architecture, clean code organization, and robust data synchronization with a live REST API.

---

## 📱 Features

- **Offline-first**: The app always reads and writes to local Hive storage first
- **Auto-sync**: Automatically syncs pending changes when internet connectivity is restored
- **Manual sync**: Users can trigger a sync at any time via the "Sync Now" button
- **Search & Filter**: Real-time search by name/phone and filter by visit status
- **Connectivity indicator**: Live online/offline badge in the header
- **Pending sync counter**: Banner shows number of items waiting to be synced
- **Premium UI**: Gradient headers, animated cards, status chips, and smooth transitions

---

## 🚀 Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd nano_soft_task
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters and DI code**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

> No local server setup is needed. The app connects to a live mock API hosted on **MockAPI.io**.

---

## 🔗 API Configuration

The app uses a live hosted mock API:

| Resource   | Endpoint                                                                 |
|------------|--------------------------------------------------------------------------|
| Base URL   | `https://69f253a8b15130b97352ce1c.mockapi.io/`                           |
| Customers  | `GET /customers` — fetch all customers                                   |
| Update     | `PUT /customers/{id}` — update visit status and notes                    |
| Visits     | `POST /visits` — create a new visit record                               |

To change the API base URL, update `lib/core/network/api_urls.dart`:
```dart
static const String baseUrl = 'https://your-api-url.com/';
```

---

## 🏛️ Architecture

The project strictly follows **Clean Architecture** with **Feature-Driven** folder organization:

```
lib/
├── core/
│   ├── constants/       # Enums: VisitStatus, SyncStatus, HttpMethod
│   ├── network/         # ApiClient (Dio), interceptors, URL config
│   ├── database/        # HiveInit — adapter registration & box opening
│   ├── errors/          # ApiException, ApiFailure
│   ├── utils/           # AppPreferences
│   └── di/              # GetIt + Injectable dependency injection
│
└── features/
    └── customer/
        ├── data/
        │   ├── models/            # CustomerModel, SyncQueueModel (Hive)
        │   ├── datasource/
        │   │   ├── local/         # CustomerLocalDataSource (Hive)
        │   │   └── remote/        # CustomerRemoteDataSource (Dio)
        │   └── repositories/      # CustomerRepositoryImpl
        │
        ├── domain/
        │   ├── entities/          # Customer (pure Dart entity)
        │   └── repositories/      # CustomerRepository (abstract interface)
        │
        └── presentation/
            ├── cubit/             # CustomerBloc, SyncBloc + events/states
            ├── screens/           # CustomerListScreen, CustomerDetailScreen
            └── widgets/           # Reusable UI components
```

### Layer Responsibilities

| Layer        | Responsibility                                                                |
|-------------|--------------------------------------------------------------------------------|
| **Domain**   | Pure business logic, entities, and repository contracts. No Flutter/Dart I/O  |
| **Data**     | API calls, Hive operations, model ↔ entity mapping, sync queue management     |
| **Presentation** | BLoC state management, UI rendering, user interaction handling           |

---

## 🔄 Offline Sync Flow

```
User Action
    │
    ▼
Save to Hive (Local)      ← Always happens first
    │
    ▼
Add to SyncQueue          ← Tracks operation: update / create
    │
    ▼
Online?
  ├── YES → syncPendingData() immediately (fire-and-forget)
  └── NO  → Wait for connectivity change event
                │
                ▼
           Connectivity restored
                │
                ▼
           Auto-sync triggered via SyncBloc
                │
                ▼
           Push to API → Mark as Synced in Hive → Remove from queue
```

### Conflict Prevention

When fetching remote data, the app **skips overwriting** any local record with a `pendingUpdate` or `pendingCreate` status. This ensures offline edits are never lost.

---

## 🗂️ State Management

**flutter_bloc** is used exclusively for state management:

| Bloc | Responsibility |
|------|---------------|
| `CustomerBloc` | Loads, searches, filters, and updates customers |
| `SyncBloc` | Tracks pending count, triggers auto/manual sync, manages sync lifecycle |

---

## 💾 Local Database — Hive

| Feature | Detail |
|---------|--------|
| Storage | `customers` box — keyed by customer ID |
| Queue   | `sync_queue` box — keyed by entity ID |
| Adapters | Auto-generated via `hive_generator` + `build_runner` |
| Safety | Adapters registered with ID checks to prevent duplicate registration |

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `hive` + `hive_flutter` | Offline-first local database |
| `dio` | HTTP client with interceptor support |
| `injectable` + `get_it` | Dependency injection |
| `connectivity_plus` | Network connectivity detection |
| `dartz` | Functional error handling (Either) |
| `flutter_screenutil` | Responsive UI scaling |
| `pretty_dio_logger` | Network request logging |

---

## ⚠️ Known Limitations

- **No background sync**: Sync only runs when the app is open or recently backgrounded. WorkManager / BackgroundFetch is not implemented in this version.
- **Single-user**: No multi-user conflict resolution (last-write-wins by timestamp) — assumes a single field agent per device.
- **Mock API**: MockAPI.io may reset data periodically; the app gracefully falls back to cached local data in that case.

---

## 👨‍💻 Author

Built as part of a technical assignment for a Flutter Developer role.  
Focus areas: **Offline-first architecture**, **Clean Code**, **BLoC**, **Hive**, **Dio**, **Dependency Injection**.
