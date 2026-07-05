# أدوات ومكتبات تطبيق Sufar Booking

## 📦 المكتبات الخارجية (External Packages)

### 1. **Firebase Core** (`firebase_core: ^4.4.0`)
- **الدور**: تهيئة Firebase في التطبيق
- **الاستخدام**: الاتصال بـ Firebase Backend والخدمات المختلفة
- **الإصدار**: 4.4.0

### 2. **Flutter SVG** (`flutter_svg: ^2.2.3`)
- **الدور**: عرض ملفات SVG في التطبيق
- **الاستخدام**: الأيقونات والصور المتجهة (Vector Images)
- **الإصدار**: 2.2.3

### 3. **HTTP** (`http: ^1.2.0`)
- **الدور**: إجراء طلبات HTTP للـ APIs
- **الاستخدام**: التواصل مع Backend APIs (الفنادق، الوجهات، الرحلات)
- **الإصدار**: 1.2.0

### 4. **Cached Network Image** (`cached_network_image: ^3.4.1`)
- **الدور**: تحميل وتخزين الصور من الإنترنت
- **الاستخدام**: عرض صور الفنادق والوجهات مع التخزين المؤقت
- **الإصدار**: 3.4.1

### 5. **Intl** (`intl: ^0.20.2`)
- **الدور**: معالجة اللغات والتنسيقات الدولية
- **الاستخدام**: تنسيق التواريخ والأوقات والأرقام
- **الإصدار**: 0.20.2

### 6. **Shared Preferences** (`shared_preferences: ^2.5.4`)
- **الدور**: تخزين البيانات المحلية البسيطة
- **الاستخدام**: حفظ تفضيلات المستخدم والبيانات المحلية
- **الإصدار**: 2.5.4

### 7. **Flutter Map** (`flutter_map: ^7.0.2`)
- **الدور**: عرض الخرائط التفاعلية
- **الاستخدام**: عرض مواقع الفنادق والوجهات على الخريطة
- **الإصدار**: 7.0.2

### 8. **Latlong2** (`latlong2: ^0.9.1`)
- **الدور**: التعامل مع الإحداثيات الجغرافية
- **الاستخدام**: حساب المسافات والإحداثيات على الخريطة
- **الإصدار**: 0.9.1

### 9. **URL Launcher** (`url_launcher: ^6.3.1`)
- **الدور**: فتح الروابط والتطبيقات الخارجية
- **الاستخدام**: فتح الهاتف والبريد الإلكتروني والمواقع
- **الإصدار**: 6.3.1

### 10. **Google Fonts** (`google_fonts: ^6.2.1`)
- **الدور**: استخدام خطوط Google في التطبيق
- **الاستخدام**: خطوط مخصصة في الواجهة
- **الإصدار**: 6.2.1

### 11. **Cupertino Icons** (`cupertino_icons: ^1.0.8`)
- **الدور**: أيقونات iOS Style
- **الاستخدام**: أيقونات قياسية في الواجهة
- **الإصدار**: 1.0.8

---

## 🎨 خطوط مخصصة (Custom Fonts)

- **Poppins Font Family**
  - `Poppins-Regular.ttf` (Weight: 400)
  - `Poppins-Medium.ttf` (Weight: 500)
  - `Poppins-SemiBold.ttf` (Weight: 600)
  - `Poppins-Bold.ttf` (Weight: 700)

---

## 🔧 الخدمات والأدوات المحلية (Internal Services)

### 1. **App Theme Service** (`theme/app_theme.dart`)
- **الدور**: إدارة الألوان والنمط البصري للتطبيق
- **الميزات**: دعم Dark Mode و Light Mode

### 2. **Activity Image Resolver** (`services/activity_image_resolver.dart`)
- **الدور**: معالجة وحل مسارات صور الأنشطة
- **الميزات**: تحميل مسبق للصور (Preloading)

### 3. **Destination Catalog Service** (`services/destination_catalog_service.dart`)
- **الدور**: إدارة بيانات الوجهات السياحية
- **الميزات**: تحميل وتخزين كتالوج الوجهات

---

## 📱 الشاشات والميزات الرئيسية (Main Features)

### 1. **Splash Screen** (`onboarding/splash_screen.dart`)
- شاشة التطبيق الأولية

### 2. **Home Screen** (`home/home_screen.dart`)
- الشاشة الرئيسية للتطبيق
- عرض الوجهات الموصى بها

### 3. **Services Screen** (`home/services_screen.dart`)
- عرض الخدمات المتاحة

### 4. **Flights Screen** (`flights/flight_landing_screen_v2.dart`)
- البحث والحجز للرحلات الجوية

### 5. **AI Planner Screen** (`ai_planner/ai_planner_screen.dart`)
- مخطط رحلات ذكي مدعوم بـ AI

### 6. **Chat Bot Screen** (`chat_bot/chat_bot_screen.dart`)
- محادثة روبوت ذكي للدعم والاستفسارات

### 7. **Profile Screen** (`profile/profile_screen.dart`)
- ملف المستخدم الشخصي

### 8. **Booking Section** (`booking/`)
- نظام الحجز والعروض

### 9. **Hotels Section** (`hotels/`)
- البحث والحجز للفنادق

### 10. **Travel Offices** (`travel_offices/`)
- معلومات مكاتب السفر

### 11. **Visa Advisor** (`visa_advisor/`)
- نصائح ومعلومات التأشيرات

### 12. **Destinations** (`destinations/`)
- تفاصيل الوجهات السياحية

### 13. **Authentication** (`auth/`)
- نظام التسجيل والدخول

---

## 📊 الأصول والبيانات (Assets & Data)

### JSON Files:
- `destinations_data.json` - بيانات الوجهات
- `activity_images.json` - صور الأنشطة
- `intents.json` - نوايا الذكاء الاصطناعي

### Asset Folders:
- `assets/destinations/` - صور الوجهات

---

## ⚙️ متطلبات النظام

- **Flutter SDK**: 3.11.0
- **Dart SDK**: 3.11.0+
- **iOS**: يدعم المشاريع القديمة
- **Android**: يدعم Android 5.0+

---

## 🔌 الخدمات الخارجية (External Services)

### 1. **Firebase**
- Authentication
- Firestore Database
- Firebase Storage
- Cloud Messaging

### 2. **Backend APIs**
- Destinations API
- Hotels API
- Flights API
- Booking API

### 3. **Cloudinary** (من الملفات)
- خدمة استضافة الصور

### 4. **Vercel** (من الملفات)
- استضافة Backend

---

## 📝 ملاحظات إضافية

- التطبيق يدعم Material Design 3
- يوجد دعم للغات المختلفة (Intl)
- يحتوي على نظام Dark Mode متقدم
- جميع الطلبات تمر عبر HTTP/HTTPS
- يستخدم تخزين محلي للبيانات الصغيرة

---

---

## 🏗️ البنية المعمارية (Architecture)

### Folder Structure:
```
lib/
├── auth/              # Authentication screens (Login, Register, Verify)
├── ai_planner/        # AI-powered trip planning
├── booking/           # Booking management
├── chat_bot/          # Chatbot interface
├── config/            # App configuration (AppConfig, AssetPaths)
├── destinations/      # Destination details & discovery
├── flights/           # Flight search & booking
├── home/              # Home screen & services hub
├── hotels/            # Hotel search & booking
├── models/            # Data models
├── onboarding/        # Splash & onboarding screens
├── profile/           # User profile management
├── services/          # API & utility services
├── theme/             # Theming (Dark/Light mode)
├── travel_offices/    # Travel agency information
├── visa_advisor/      # Visa information & guidance
├── main.dart          # App entry point
└── firebase_options.dart # Firebase configuration
```

---

## 🔌 API Endpoints

### Base URL:
- **Production**: `https://sufar-rho.vercel.app/api`
- **Local Development**:
  - Android Emulator: `http://10.0.2.2:5000/api`
  - Real Device (WiFi): `http://YOUR_PC_IP:5000/api`

### Authentication Endpoints:
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/auth/register` | POST | Register new user |
| `/auth/login` | POST | User login |
| `/auth/verify` | POST | Verify email code |
| `/auth/me` | GET | Get current user profile |
| `/auth/profile` | PUT | Update user profile |
| `/auth/logout` | POST | User logout |
| `/auth/forgot-password` | POST | Request password reset |
| `/auth/reset-password` | POST | Reset password |

### Data Endpoints:
| Endpoint | Method | Description |
|----------|--------|-------------|
| `/destinations` | GET | List all destinations |
| `/destinations/:id` | GET | Get destination details |
| `/hotels` | GET | List all hotels |
| `/hotels/:id` | GET | Get hotel details |
| `/flights` | GET | Search flights |
| `/flights/:id` | GET | Get flight details |
| `/travel-offices` | GET | List travel offices |
| `/bookings` | POST/GET | Create/retrieve bookings |

### Request Headers:
```dart
Content-Type: application/json
Authorization: Bearer <token>  // For authenticated requests
```

---

## 📊 Data Models

### 1. UserModel
```dart
{
  id: String,                 // MongoDB _id
  name: String,              // Full name
  email: String,
  avatarUrl: String?,
  phone: String?,
  nationality: String?,
  gender: String?,
  dateOfBirth: String?,
  createdAt: String,
}
```

### 2. DestinationModel
```dart
{
  id: String,
  name: String,              // English name
  nameAr: String,            // Arabic name
  slug: String,
  country: String,
  countryAr: String,
  region: String,
  description: String,
  highlights: List<String>,  // Key attractions
  imageUrl: String,
  isFeatured: bool,
}
```

### 3. Hotel Model
```dart
{
  id: String,
  slug: String,
  name: String,
  city: String,
  country: String,
  description: String,
  images: List<String>,
  stars: int,                // 1-5
  rating: double,
  reviewsCount: int,
  startingFrom: double,      // Price
  mealPlan: String,          // BB, HB, FB, AI
  locationType: String,      // City center, Beach, etc
  address: String,
  latitude: double?,
  longitude: double?,
  facilities: List<String>,  // WiFi, Pool, Gym, etc
  nearbyActivities: List<String>,
}
```

### 4. TravelOfficeModel
```dart
{
  id: String,
  name: String,
  city: String?,
  country: String?,
  rating: double?,
  reviewsCount: int?,
  description: String?,
  priceRange: String?,       // $, $$, $$$
  workingHours: String?,
  services: List<String>,    // Flight, Hotel, Visa, etc
  phone: String?,
  email: String?,
  website: String?,
  imageUrl: String?,
  logoUrl: String?,
  isActive: bool,
}
```

### 5. BookingModel
```dart
{
  id: String,
  userId: String,
  type: String,              // hotel, flight
  itemId: String,            // hotel or flight ID
  checkIn: String,           // ISO date
  checkOut: String,
  adults: int,
  children: int,
  totalPrice: double,
  status: String,            // pending, confirmed, cancelled
  createdAt: String,
}
```

### 6. FlightModel
```dart
{
  id: String,
  airline: String,
  from: String,              // City code
  to: String,
  departureTime: String,
  arrivalTime: String,
  duration: String,          // HH:MM format
  price: double,
  availability: int,         // Remaining seats
  class: String,             // Economy, Business
}
```

---

## 🔐 Authentication Flow

### 1. Registration:
```
User enters: fullName, email, password
  ↓
POST /auth/register
  ↓
Verification code sent to email
  ↓
User receives code and verifies
  ↓
POST /auth/verify (email, code)
  ↓
Account created & logged in
```

### 2. Login:
```
User enters: email, password
  ↓
POST /auth/login
  ↓
Server returns: token + user object
  ↓
Token saved in SharedPreferences
  ↓
User redirected to MainScreen
```

### 3. Token Management:
- Token stored in: `SharedPreferences.getInstance().getString('auth_token')`
- Backend user data: `SharedPreferences.getInstance().getString('backend_user')`
- Passed in header: `Authorization: Bearer <token>`

---

## 🎯 Core Services

### 1. ApiService (`services/api_service.dart`)
Main HTTP client for all API calls. Features:
- Automatic token management
- Request/response handling
- Error handling
- Base URL configuration via `AppConfig`

**Usage Pattern:**
```dart
// Get data
final hotels = await ApiService.getHotels();

// Post data with auth
final booking = await ApiService.createBooking(data);

// Login/Logout
await ApiService.login(email: 'user@email.com', password: 'pass');
```

### 2. ActivityImageResolver (`services/activity_image_resolver.dart`)
Handles activity images for AI planner:
- Preloads activity images
- Maps activities to icons/images
- Manages Cloudinary URLs

### 3. DestinationCatalogService (`services/destination_catalog_service.dart`)
Manages destination data:
- Loads raw catalog from assets
- Caches destination data
- Provides search functionality

### 4. ImageService (`services/image_service.dart`)
Image handling:
- Cloudinary integration
- Fallback images
- Image deduplication

---

## 🎨 Theme System

### App Theme (`theme/app_theme.dart`)
- **Dark Mode Support**: Toggle via `ValueListenable<ThemeMode>`
- **Colors**: Primary, accent, background configured
- **Typography**: Uses Poppins font family
- **Custom Material Design 3 theming**

**Toggle Dark Mode:**
```dart
AppTheme.themeNotifier.value = ThemeMode.dark;  // Enable dark mode
AppTheme.themeNotifier.value = ThemeMode.light; // Enable light mode
```

---

## 💾 Local Storage

### Shared Preferences Usage:
```dart
// Save data
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);
await prefs.setString('backend_user', jsonEncode(userObj));

// Retrieve data
final token = prefs.getString('auth_token');
final user = jsonDecode(prefs.getString('backend_user') ?? '{}');

// Clear data
await prefs.remove('auth_token');
await prefs.clear();  // Clear all
```

---

## 🌍 Firebase Integration

### Firebase Project ID: `sufar-89113`

### Platform Configurations:
- **Android**: App ID `1:95707773579:android:7a5070b8e607caf9bbb28e`
- **iOS**: App ID `1:95707773579:ios:ea1a9b3a4a55fb48bbb28e`
- **Web**: App ID `1:95707773579:web:72d5f5efb5b5f9debbb28e`

### Firebase Services Used:
1. **Authentication** (optional - currently using custom backend auth)
2. **Cloud Messaging** (push notifications)
3. **Storage** (backup media)
4. **Firestore** (optional real-time data)

### Initialization:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}
```

---

## 🚀 Build & Deployment

### Build Commands:
```bash
# Flutter clean
flutter clean

# Get dependencies
flutter pub get

# Run app
flutter run

# Build APK (Android)
flutter build apk --release

# Build iOS
flutter build ios --release

# Build Web
flutter build web --release
```

### Important Files:
- `google-services.json` - Android Firebase config
- `GoogleService-Info.plist` - iOS Firebase config
- `pubspec.yaml` - Dependencies & assets

---

## 🧪 Testing & Development

### Test Files in Root:
- `test_models.dart` - Test model parsing
- `test_api_2.dart` - Test API endpoints
- `test_vercel.dart` - Test Vercel deployment
- `check_db.dart` - Check database connection
- `test_hotels.dart` - Test hotel data

### Run Tests:
```bash
dart test_models.dart
dart check_db.dart
```

---

## 📱 Platform-Specific Setup

### Android:
- Min SDK: 21 (Android 5.0)
- Target SDK: Latest (34+)
- Firebase config: `android/app/google-services.json`

### iOS:
- Min iOS: 12.0
- Cocoapods required
- Firebase config: `ios/Runner/GoogleService-Info.plist`

### Web:
- Uses `web/index.html` as entry point
- Firebase web config included
- Responsive design for all screen sizes

---

## ⚙️ Configuration

### AppConfig (`lib/config/app_config.dart`)
```dart
// Use environment variables for different environments
const String API_BASE_URL = 'https://sufar-rho.vercel.app/api';

// Override at runtime:
// flutter run --dart-define=API_BASE_URL=http://localhost:5000/api
```

### Asset Paths (`lib/config/asset_paths.dart`)
Central location for all asset references:
- JSON files path
- Images path
- Fonts path

---

## 🔄 Common Workflows

### 1. Adding New API Endpoint:
```dart
// 1. Add to ApiService class
static Future<Map<String, dynamic>> getNewData() async {
  final res = await http.get(
    Uri.parse('$baseUrl/new-endpoint'),
    headers: await _headers(auth: true),
  );
  return jsonDecode(res.body);
}

// 2. Create corresponding model
class NewDataModel {
  // ... fields
  factory NewDataModel.fromJson(Map<String, dynamic> json) { ... }
}

// 3. Use in UI
final data = await ApiService.getNewData();
```

### 2. Implementing Authentication:
```dart
// 1. User fills registration form
// 2. Call ApiService.register()
// 3. Verify code
// 4. Token automatically saved
// 5. Navigate to MainScreen
```

### 3. Handling Dark Mode:
```dart
// Theme automatically respects system setting
// Allow user to toggle:
AppTheme.themeNotifier.value = 
  AppTheme.themeNotifier.value == ThemeMode.light 
    ? ThemeMode.dark 
    : ThemeMode.light;
```

---

## ⚠️ Common Issues & Solutions

### Issue: "Cannot connect to backend"
**Solution:**
- Check API base URL in `AppConfig`
- For emulator use: `http://10.0.2.2:5000/api`
- Ensure backend server is running
- Check CORS settings on backend

### Issue: "Token expires or not saved"
**Solution:**
- Verify Shared Preferences is initialized
- Check token saving after login
- Clear and re-login if issues persist

### Issue: "Images not loading"
**Solution:**
- Check image URLs are valid
- Verify Cloudinary integration
- Check network permissions in manifest

### Issue: "Firebase not initializing"
**Solution:**
- Verify google-services.json exists
- Check project ID matches
- Rebuild after config changes

---

## 📚 Additional Resources

### Important Git Files:
- `analyze_output.txt` - Dart analysis results
- `ASSETS_ANALYSIS_REPORT.md` - Asset structure report
- `analysis_options.yaml` - Lint rules

### Python Backend:
Located in `python_backend/`:
- `sufar_smart_travel_assistant_v2.py` - AI recommendation engine
- Uses Flask for API
- Handles AI planning & NLP

### Scripts:
- `seed_travel_offices.js` - Database seeding
- `apply_curated_activity_photos.js` - Image sync
- `verify_media_paths.js` - Media validation

---

## 🚀 تطوير إضافي

للفريق الذي يريد تطوير التطبيق يجب أن يكون على دراية بـ:
- **Flutter & Dart Basics**: Widgets, State Management, async/await
- **Firebase Integration**: Auth, Cloud Messaging, Storage
- **REST APIs**: HTTP requests, JSON parsing, error handling
- **Mobile Platforms**: iOS & Android specifics
- **Responsive Design**: Different screen sizes (phone, tablet, web)
- **Git & GitHub**: Version control, branching, PR reviews
- **Backend Integration**: Understanding API contracts
- **State Management**: If adding complex features
- **Testing**: Unit tests, widget tests
- **Deployment**: App Store & Play Store publishing

