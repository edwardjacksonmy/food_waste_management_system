# Flutter Setup for Food Waste Management System

## 1. Install Flutter
First, you need to install Flutter on your development machine:

1. Download Flutter SDK from https://flutter.dev/docs/get-started/install for your platform (Windows, macOS, or Linux)
2. Extract the downloaded archive to a suitable location
3. Add Flutter to your PATH
4. Run `flutter doctor` to check if there are any dependencies you need to install

## 2. Create a New Flutter Project

```bash
# Create a new Flutter project
flutter create food_waste_app

# Navigate to the project directory
cd food_waste_app
```

## 3. Add Required Dependencies

Open `pubspec.yaml` and add the following dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.5           # For state management
  http: ^1.1.0               # For API calls
  shared_preferences: ^2.2.0 # For local storage
  google_maps_flutter: ^2.4.0 # For maps
  geolocator: ^10.0.0        # For location services
  flutter_polyline_points: ^1.0.0 # For route drawing
  intl: ^0.18.1              # For date formatting
  timeago: ^3.5.0            # For relative time formatting
  image_picker: ^1.0.2       # For picking images
  cached_network_image: ^3.2.3 # For image caching
  flutter_local_notifications: ^15.1.0+1 # For local notifications
  firebase_core: ^2.15.1     # Firebase core
  firebase_messaging: ^14.6.7 # For push notifications
  flutter_config: ^2.0.2     # For environment variables
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.2
```

Run `flutter pub get` to install the dependencies.

## 4. Project Structure Setup

Organize your project according to the structure we've outlined:

```bash
mkdir -p lib/config
mkdir -p lib/models
mkdir -p lib/services
mkdir -p lib/providers
mkdir -p lib/screens/auth
mkdir -p lib/screens/donor
mkdir -p lib/screens/recipient
mkdir -p lib/screens/common
mkdir -p lib/widgets
mkdir -p lib/utils
```

## 5. Configure Google Maps

### For Android:

1. Create an API key in the Google Cloud Console with Maps SDK for Android enabled
2. Add the API key to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <application ...>
        <!-- Add this line before the closing application tag -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY" />
    </application>
</manifest>
```

### For iOS:

1. Add the following to `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

2. Add these keys to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location to find nearby food donations.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location to find nearby food donations.</string>
```

## 6. Setup Main.dart

Replace the contents of `lib/main.dart` with the following:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/routes.dart';
import 'config/themes.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/donation_service.dart';
import 'services/transaction_service.dart';
import 'providers/auth_provider.dart';
import 'providers/donation_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/donor/donor_home_screen.dart';
import 'screens/recipient/recipient_home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ProxyProvider<ApiService, AuthService>(
          update: (_, apiService, __) => AuthService(apiService),
        ),
        ProxyProvider<ApiService, DonationService>(
          update: (_, apiService, __) => DonationService(apiService),
        ),
        ProxyProvider<ApiService, TransactionService>(
          update: (_, apiService, __) => TransactionService(apiService),
        ),
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) => AuthProvider(
            Provider.of<AuthService>(context, listen: false),
          ),
          update: (_, authService, previous) => 
              previous!..update(authService),
        ),
        ChangeNotifierProxyProvider<DonationService, DonationProvider>(
          create: (context) => DonationProvider(
            Provider.of<DonationService>(context, listen: false),
          ),
          update: (_, donationService, previous) => 
              previous!..update(donationService),
        ),
        ChangeNotifierProxyProvider<TransactionService, TransactionProvider>(
          create: (context) => TransactionProvider(
            Provider.of<TransactionService>(context, listen: false),
          ),
          update: (_, transactionService, previous) => 
              previous!..update(transactionService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Food Waste Management',
            theme: AppTheme.lightTheme,
            routes: AppRoutes.routes,
            home: FutureBuilder<bool>(
              future: authProvider.checkAuth(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SplashScreen();
                }
                
                final isAuthenticated = snapshot.data ?? false;
                
                if (isAuthenticated) {
                  return authProvider.isDonor
                      ? DonorHomeScreen()
                      : RecipientHomeScreen();
                } else {
                  return LoginScreen();
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(height: 24),
            Text(
              'Food Waste Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```

## 7. Create Routes Configuration

Create a file at `lib/config/routes.dart`:

```dart
import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/donor/donor_home_screen.dart';
import '../screens/donor/create_donation_screen.dart';
import '../screens/donor/donation_requests_screen.dart';
import '../screens/donor/donation_history_screen.dart';
import '../screens/recipient/recipient_home_screen.dart';
import '../screens/recipient/nearby_donations_screen.dart';
import '../screens/recipient/route_planning_screen.dart';
import '../screens/recipient/pickup_history_screen.dart';
import '../screens/common/notification_screen.dart';
import '../screens/common/chat_screen.dart';
import '../screens/common/feedback_screen.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    // Auth routes
    '/login': (context) => LoginScreen(),
    '/register': (context) => RegisterScreen(),
    '/profile': (context) => ProfileScreen(),
    
    // Donor routes
    '/donor-home': (context) => DonorHomeScreen(),
    '/create-donation': (context) => CreateDonationScreen(),
    '/donation-requests': (context) => DonationRequestsScreen(),
    '/donation-history': (context) => DonationHistoryScreen(),
    
    // Recipient routes
    '/recipient-home': (context) => RecipientHomeScreen(),
    '/nearby-donations': (context) => NearbyDonationsScreen(),
    '/route-planning': (context) => RoutePlanningScreen(),
    '/pickup-history': (context) => PickupHistoryScreen(),
    
    // Common routes
    '/notifications': (context) => NotificationScreen(),
    '/chat': (context) => ChatScreen(),
    '/feedback': (context) => FeedbackScreen(),
  };
}
```

## 8. Create Theme Configuration

Create a file at `lib/config/themes.dart`:

```dart
import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.green,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.green,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      filled: true,
      fillColor: Colors.grey[50],
    ),
  );
}
```

## 9. Backend Integration

To connect your Flutter app with your backend database:

1. Create a REST API service using a backend framework (e.g., Node.js with Express, Laravel, Django)
2. Set up API endpoints that match the ones used in the `ApiService` class
3. Implement JWT token authentication for secure API requests
4. Deploy your backend to a cloud hosting service

Example API endpoint structure:

```
/api/auth/register
/api/auth/login
/api/auth/logout
/api/auth/user

/api/donations
/api/donations/{id}
/api/donations/my-donations
/api/donations/nearby

/api/transactions
/api/transactions/{id}
/api/transactions/my-transactions
/api/transactions/{id}/confirm
/api/transactions/{id}/reject
/api/transactions/{id}/complete
/api/transactions/{id}/feedback
```

## 10. Setting Up Firebase for Push Notifications

1. Create a Firebase project in the Firebase Console
2. Add your Android and iOS apps to the Firebase project
3. Download and add the configuration files:
   - `google-services.json` for Android
   - `GoogleService-Info.plist` for iOS
4. Initialize Firebase in your app:

```dart
// main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Request permission for iOS
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission();
  
  runApp(MyApp());
}
```

## 11. Testing Your App

1. Use the following commands for testing:

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test
```

2. Test on both Android and iOS devices:

```bash
# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios
```

## 12. Building for Production

```bash
# Build Android APK
flutter build apk --release

# Build Android App Bundle
flutter build appbundle

# Build iOS IPA
flutter build ios --release
```

## 13. Next Steps

After setting up your project structure, consider these next steps:

1. Implement error handling throughout the app
2. Add more robust form validation
3. Implement analytics to track user behavior
4. Add multi-language support
5. Optimize for different screen sizes
6. Add unit and integration tests
7. Setup Continuous Integration/Continuous Deployment (CI/CD)