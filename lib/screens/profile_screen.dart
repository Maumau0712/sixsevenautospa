import 'package:flutter/material.dart';

import '../services/user_session.dart';
import 'login_screen.dart';
import 'my_booking_screen.dart';
import 'my_vehicle_screen.dart';
import 'personal_details_screen.dart';
import 'service_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const navy = Color(0xFF0B2344);
  static const grey = Color(0xFF7B8494);

  Future<void> openPersonalDetails() async {
    final updated =
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const PersonalDetailsScreen(),
      ),
    );

    if (updated == true && mounted) {
      setState(() {});
    }
  }

  void openMyVehicles() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const MyVehicleScreen(),
      ),
    );
  }

  void openMyBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const MyBookingScreen(),
      ),
    );
  }

  void openServiceHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const ServiceHistoryScreen(),
      ),
    );
  }

  Future<void> logout() async {
    final confirm =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Logout',
          ),
          content: const Text(
            'Are you sure you want to logout from 67AutoSpa?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
              const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    UserSession.logout();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const LoginScreen(),
      ),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user =
        UserSession.currentUser;

    final userName =
        user?.name ?? 'Guest User';

    final userEmail =
        user?.email ?? 'No email';

    final userPhone =
        user?.phone ?? 'No phone';

    return Scaffold(
      backgroundColor:
      const Color(0xFFF3F6FA),

      appBar: AppBar(
        title: const Text(
          'Profile',
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          30,
        ),
        children: [
          Container(
            padding:
            const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(
                20,
              ),
              border: Border.all(
                color: const Color(
                  0xFFE6EAF0,
                ),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration:
                  const BoxDecoration(
                    color: Color(
                      0xFFEAF1FA,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: navy,
                    size: 48,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  userName,
                  textAlign:
                  TextAlign.center,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 23,
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  userEmail,
                  style: const TextStyle(
                    color: grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  userPhone,
                  style: const TextStyle(
                    color: grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Account',
            style: TextStyle(
              color: navy,
              fontSize: 18,
              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          profileOption(
            icon:
            Icons.person_outline_rounded,
            title: 'Personal Details',
            subtitle:
            'View and edit your information',
            onTap: openPersonalDetails,
          ),

          profileOption(
            icon:
            Icons.directions_car_outlined,
            title: 'My Vehicles',
            subtitle:
            'Manage registered vehicles',
            onTap: openMyVehicles,
          ),

          profileOption(
            icon:
            Icons.calendar_month_outlined,
            title: 'My Bookings',
            subtitle:
            'View your service bookings',
            onTap: openMyBookings,
          ),

          profileOption(
            icon:
            Icons.history_rounded,
            title: 'Service History',
            subtitle:
            'View previous service records',
            onTap: openServiceHistory,
          ),

          const SizedBox(height: 26),

          OutlinedButton.icon(
            onPressed: logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            label: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            style:
            OutlinedButton.styleFrom(
              side: BorderSide(
                color:
                Colors.red.shade200,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget profileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 11,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color:
          const Color(0xFFE6EAF0),
        ),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 7,
        ),
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color:
            const Color(0xFFEAF1FA),
            borderRadius:
            BorderRadius.circular(
              12,
            ),
          ),
          child: Icon(
            icon,
            color: navy,
            size: 23,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: navy,
            fontWeight:
            FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: grey,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: grey,
        ),
      ),
    );
  }
}