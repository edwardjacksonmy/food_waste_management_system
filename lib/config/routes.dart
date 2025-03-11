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
