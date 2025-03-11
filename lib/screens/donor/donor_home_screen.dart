// donor_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/donation.dart';
import '../providers/donation_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/donation_card.dart';

class DonorHomeScreen extends StatefulWidget {
  @override
  _DonorHomeScreenState createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends State<DonorHomeScreen> {
  bool _isLoading = true;
  List<FoodDonation> _activeDonations = [];

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final donationProvider = Provider.of<DonationProvider>(
        context,
        listen: false,
      );
      await donationProvider.loadMyDonations();

      setState(() {
        _activeDonations =
            donationProvider.myDonations
                .where(
                  (donation) =>
                      donation.status == DonationStatus.available ||
                      donation.status == DonationStatus.pending,
                )
                .toList();
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading donations: $e')));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Donor Dashboard'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              final unreadCount = notificationProvider.unreadCount;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDonations,
        child:
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : _activeDonations.isEmpty
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.no_food, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No active donations',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/create-donation');
                        },
                        child: Text('Create New Donation'),
                      ),
                    ],
                  ),
                )
                : ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    Text(
                      'Active Donations',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    ..._activeDonations.map(
                      (donation) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: DonationCard(
                          donation: donation,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/donation-details',
                              arguments: donation,
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildActionCard(
                      icon: Icons.add_circle,
                      title: 'Create New Donation',
                      subtitle: 'Share your excess food with those in need',
                      onTap: () {
                        Navigator.pushNamed(context, '/create-donation');
                      },
                    ),
                    SizedBox(height: 12),
                    _buildActionCard(
                      icon: Icons.history,
                      title: 'Donation History',
                      subtitle: 'View your past donations and impact',
                      onTap: () {
                        Navigator.pushNamed(context, '/donation-history');
                      },
                    ),
                  ],
                ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Donate',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/create-donation');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
