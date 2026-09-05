import 'package:flutter/material.dart';

import 'booking_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'services_screen.dart';

class MainNavigationScreen
    extends StatefulWidget {

  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen>
  createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {

  late int selectedIndex;

  String? bookingService;
  String? bookingWorkshop;

  @override
  void initState() {
    super.initState();

    selectedIndex =
        widget.initialIndex;
  }

  void changePage(
      int index,
      ) {
    setState(() {
      selectedIndex = index;
    });
  }

  void openBookingWithService(
      String serviceName,
      ) {
    setState(() {
      bookingService =
          serviceName;

      selectedIndex = 2;
    });
  }

  void openBookingWithWorkshop(
      String workshopName,
      ) {
    setState(() {
      bookingWorkshop =
          workshopName;

      selectedIndex = 2;
    });
  }

  void resetBookingSelection() {
    setState(() {
      bookingService = null;
      bookingWorkshop = null;
    });
  }

  void goHome() {
    setState(() {
      selectedIndex = 0;
    });
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    List<Widget> pages = [
      HomeScreen(
        onChangeTab:
        changePage,
        onBookService:
        openBookingWithService,
        onBookWorkshop:
        openBookingWithWorkshop,
      ),

      ServicesScreen(
        onBookService:
        openBookingWithService,
      ),

      BookingScreen(
        selectedService:
        bookingService,
        selectedWorkshop:
        bookingWorkshop,
        onGoHome:
        goHome,
        onBookingComplete:
        resetBookingSelection,
      ),

      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor:
      const Color(
        0xFFF3F6FA,
      ),

      body:
      IndexedStack(
        index:
        selectedIndex,
        children:
        pages,
      ),

      bottomNavigationBar:
      NavigationBar(
        selectedIndex:
        selectedIndex,

        onDestinationSelected:
        changePage,

        indicatorColor:
        const Color(
          0xFFE5EDF8,
        ),

        destinations:
        const [
          NavigationDestination(
            icon:
            Icon(
              Icons.home_outlined,
            ),
            selectedIcon:
            Icon(
              Icons.home_rounded,
            ),
            label:
            'Home',
          ),

          NavigationDestination(
            icon:
            Icon(
              Icons.build_outlined,
            ),
            selectedIcon:
            Icon(
              Icons.build_rounded,
            ),
            label:
            'Services',
          ),

          NavigationDestination(
            icon:
            Icon(
              Icons
                  .calendar_month_outlined,
            ),
            selectedIcon:
            Icon(
              Icons
                  .calendar_month_rounded,
            ),
            label:
            'Booking',
          ),

          NavigationDestination(
            icon:
            Icon(
              Icons.person_outline,
            ),
            selectedIcon:
            Icon(
              Icons.person_rounded,
            ),
            label:
            'Profile',
          ),
        ],
      ),
    );
  }
}