import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/reset_password_screen.dart';
import 'screens/splash_screen.dart';
import 'services/local_database.dart';
import 'services/notification_service.dart';

// Please open terminal and insert (flutter run -d chrome --web-port 3000)

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url:
    'https://ubaosrzatzegqoshyxyo.supabase.co',

    anonKey:
    'sb_publishable_XqeVUdxLUNxTSuqYxrF3KQ_u6KOAIDM',
  );

  if (!kIsWeb) {
    await LocalDatabase.instance
        .initDatabase();

    await NotificationService.instance
        .initialize();
  }

  runApp(
    const AutoSpaApp(),
  );
}

class AutoSpaApp extends StatefulWidget {
  const AutoSpaApp({
    super.key,
  });

  @override
  State<AutoSpaApp> createState() =>
      _AutoSpaAppState();
}

class _AutoSpaAppState
    extends State<AutoSpaApp> {
  final navigatorKey =
  GlobalKey<NavigatorState>();

  StreamSubscription<AuthState>?
  authSubscription;

  bool recoveryScreenOpened = false;

  @override
  void initState() {
    super.initState();

    authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen(
              (data) {
            if (data.event ==
                AuthChangeEvent.passwordRecovery) {
              openRecoveryScreen();
            }
          },
        );
  }

  void openRecoveryScreen() {
    if (recoveryScreenOpened) {
      return;
    }

    recoveryScreenOpened = true;

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        navigatorKey.currentState
            ?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) =>
            const ResetPasswordScreen(),
          ),
              (route) => false,
        );
      },
    );
  }

  @override
  void dispose() {
    authSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    const navy =
    Color(0xFF0B2344);

    return MaterialApp(
      navigatorKey:
      navigatorKey,

      debugShowCheckedModeBanner:
      false,

      title:
      '67AutoSpa',

      theme: ThemeData(
        useMaterial3: true,

        colorScheme:
        ColorScheme.fromSeed(
          seedColor: navy,
        ),

        scaffoldBackgroundColor:
        const Color(
          0xFFF3F6FA,
        ),

        appBarTheme:
        const AppBarTheme(
          backgroundColor:
          Color(
            0xFFF3F6FA,
          ),

          foregroundColor:
          navy,

          elevation: 0,
        ),

        inputDecorationTheme:
        InputDecorationTheme(
          filled: true,

          fillColor:
          Colors.white,

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),

          border:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),

            borderSide:
            const BorderSide(
              color:
              Color(
                0xFFE1E6ED,
              ),
            ),
          ),

          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),

            borderSide:
            const BorderSide(
              color:
              Color(
                0xFFE1E6ED,
              ),
            ),
          ),

          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(
              14,
            ),

            borderSide:
            const BorderSide(
              color: navy,
              width: 1.5,
            ),
          ),
        ),

        elevatedButtonTheme:
        ElevatedButtonThemeData(
          style:
          ElevatedButton.styleFrom(
            backgroundColor:
            navy,

            foregroundColor:
            Colors.white,

            minimumSize:
            const Size(
              double.infinity,
              52,
            ),

            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(
                14,
              ),
            ),
          ),
        ),
      ),

      home:
      const SplashScreen(),
    );
  }
}