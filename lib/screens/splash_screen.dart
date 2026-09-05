import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/database_helper.dart';
import '../services/user_session.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    checkLogin();
  }

  Future<void> checkLogin() async {
    await Future.delayed(
      const Duration(
        milliseconds: 700,
      ),
    );

    if (!mounted) {
      return;
    }

    final session =
        Supabase.instance.client.auth.currentSession;

    if (session != null) {
      try {
        final user =
        await DatabaseHelper.instance
            .createOrGetProfile();

        if (user != null) {
          UserSession.login(
            user,
          );

          if (!mounted) {
            return;
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
              const MainNavigationScreen(),
            ),
          );

          return;
        }
      } catch (error) {
        debugPrint(
          'Login session error: $error',
        );
      }
    }

    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 52,
              backgroundColor:
              Color(0xFF0B2344),
              child: Icon(
                Icons.directions_car_rounded,
                size: 58,
                color: Colors.white,
              ),
            ),

            SizedBox(
              height: 24,
            ),

            Text(
              '67AutoSpa',
              style: TextStyle(
                color: Color(0xFF0B2344),
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 7,
            ),

            Text(
              'Smart Car Care',
              style: TextStyle(
                color: Color(0xFF7B8494),
                fontSize: 16,
              ),
            ),

            SizedBox(
              height: 38,
            ),

            SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF0B2344),
              ),
            ),
          ],
        ),
      ),
    );
  }
}