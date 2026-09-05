import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/booking_model.dart';
import '../models/vehicle_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../services/user_session.dart';

class MyBookingScreen extends StatefulWidget {
  const MyBookingScreen({
    super.key,
  });

  @override
  State<MyBookingScreen> createState() =>
      _MyBookingScreenState();
}

class _MyBookingScreenState
    extends State<MyBookingScreen> {

  List<Booking> bookings = [];
  List<Vehicle> vehicles = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadBookings();
  }

  Future<void> loadBookings() async {
    final user =
        UserSession.currentUser;

    if (user?.id == null) {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }

      return;
    }

    try {
      List<Booking> bookingResult =
      await DatabaseHelper.instance
          .getBookings(
        user!.id!,
      );

      List<Vehicle> vehicleResult =
      await DatabaseHelper.instance
          .getVehicles(
        user.id!,
      );

      DateTime now =
      DateTime.now();

      DateTime today =
      DateTime(
        now.year,
        now.month,
        now.day,
      );

      List<Booking> upcoming =
      bookingResult.where(
            (booking) {
          DateTime date =
          DateTime(
            booking.date.year,
            booking.date.month,
            booking.date.day,
          );

          return !date.isBefore(today) &&
              booking.status !=
                  'Cancelled';
        },
      ).toList();

      upcoming.sort(
            (a, b) {
          return a.date.compareTo(
            b.date,
          );
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        bookings = upcoming;
        vehicles = vehicleResult;
        loading = false;
      });
    } catch (error) {
      debugPrint(
        'Load booking error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });

      showMessage(
        'Unable to load bookings.',
      );
    }
  }

  Vehicle? findVehicle(
      String plate,
      ) {
    for (Vehicle vehicle
    in vehicles) {
      if (vehicle.plateNumber
          .trim()
          .toLowerCase() ==
          plate
              .trim()
              .toLowerCase()) {
        return vehicle;
      }
    }

    return null;
  }

  String formatDate(
      DateTime date,
      ) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  DateTime getBookingDateTime(
      Booking booking,
      ) {
    try {
      String cleanTime =
      booking.time
          .replaceAll(
        ' AM',
        '',
      )
          .replaceAll(
        ' PM',
        '',
      );

      List<String> parts =
      cleanTime.split(
        ':',
      );

      int hour =
      int.parse(
        parts[0],
      );

      int minute =
      int.parse(
        parts[1],
      );

      if (booking.time.contains(
        'PM',
      ) &&
          hour != 12) {
        hour += 12;
      }

      if (booking.time.contains(
        'AM',
      ) &&
          hour == 12) {
        hour = 0;
      }

      return DateTime(
        booking.date.year,
        booking.date.month,
        booking.date.day,
        hour,
        minute,
      );
    } catch (error) {
      return booking.date;
    }
  }

  void showQrCode(
      Booking booking,
      ) {
    String bookingId =
        booking.id?.toString() ?? '0';

    String qrData =
        '67AutoSpa\n'
        'Booking ID: $bookingId\n'
        'Service: ${booking.serviceName}\n'
        'Vehicle: ${booking.vehiclePlate}\n'
        'Workshop: ${booking.workshopName}\n'
        'Date: ${formatDate(booking.date)}\n'
        'Time: ${booking.time}\n'
        'Status: ${booking.status}';

    showDialog(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,

          title: const Text(
            'Booking QR Code',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF0B2344),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Container(
            width: 250,
            height: 250,
            padding: const EdgeInsets.all(15),

            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFE1E6ED),
              ),
            ),

            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 220,
              backgroundColor: Colors.white,

              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Colors.black,
              ),

              dataModuleStyle:
              const QrDataModuleStyle(
                dataModuleShape:
                QrDataModuleShape.square,
                color: Colors.black,
              ),

              errorStateBuilder:
                  (context, error) {
                return const Center(
                  child: Text(
                    'Unable to create QR Code',
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child: const Text(
                'Close',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> addToCalendar(
      Booking booking,
      ) async {
    try {
      DateTime start =
      getBookingDateTime(
        booking,
      );

      DateTime end =
      start.add(
        const Duration(
          hours: 1,
        ),
      );

      Event event =
      Event(
        title:
        '67AutoSpa - ${booking.serviceName}',
        description:
        'Vehicle: ${booking.vehiclePlate}\n'
            'Service: ${booking.serviceName}\n'
            'Workshop: ${booking.workshopName}',
        location:
        booking.workshopName,
        startDate: start,
        endDate: end,
      );

      bool added =
      await Add2Calendar
          .addEvent2Cal(
        event,
      );

      if (!mounted) {
        return;
      }

      if (added) {
        showMessage(
          'Booking added to calendar.',
        );
      }
    } catch (error) {
      debugPrint(
        'Calendar error: $error',
      );

      showMessage(
        'Unable to open calendar.',
      );
    }
  }

  String getWorkshopPhone(
      String workshop,
      ) {
    if (workshop ==
        '67AutoSpa Setapak') {
      return '0367326767';
    }

    if (workshop ==
        '67AutoSpa Cheras') {
      return '0367326767';
    }

    if (workshop ==
        '67AutoSpa Kepong') {
      return '0367326767';
    }

    return '0367326767';
  }

  Future<void> callWorkshop(
      Booking booking,
      ) async {
    String phone =
    getWorkshopPhone(
      booking.workshopName,
    );

    Uri phoneUri =
    Uri(
      scheme: 'tel',
      path: phone,
    );

    try {
      bool opened =
      await launchUrl(
        phoneUri,
        mode:
        LaunchMode
            .externalApplication,
      );

      if (!opened) {
        showMessage(
          'Unable to open phone dialer.',
        );
      }
    } catch (error) {
      debugPrint(
        'Phone error: $error',
      );

      showMessage(
        'Unable to open phone dialer.',
      );
    }
  }

  Future<void> cancelBooking(
      Booking booking,
      ) async {
    if (booking.id == null) {
      showMessage(
        'Booking ID not found.',
      );

      return;
    }

    bool? confirm =
    await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) {
        return AlertDialog(
          title:
          const Text(
            'Cancel Booking',
          ),
          content:
          const Text(
            'Are you sure you want to cancel this booking?',
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
              const Text(
                'No',
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
              const Text(
                'Yes, Cancel',
                style:
                TextStyle(
                  color:
                  Colors.red,
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

    try {
      await DatabaseHelper.instance
          .updateBookingStatus(
        booking.id!,
        'Cancelled',
      );

      try {
        await NotificationService
            .instance
            .cancelBookingReminder(
          booking.id!,
        );
      } catch (error) {
        debugPrint(
          'Notification cancel error: $error',
        );
      }

      await loadBookings();

      showMessage(
        'Booking cancelled successfully.',
      );
    } catch (error) {
      debugPrint(
        'Cancel booking error: $error',
      );

      showMessage(
        'Unable to cancel booking.',
      );
    }
  }

  void showMessage(
      String message,
      ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
        Text(
          message,
        ),
      ),
    );
  }

  Color statusColor(
      String status,
      ) {
    if (status ==
        'Confirmed') {
      return Colors.green;
    }

    if (status ==
        'Pending') {
      return Colors.orange;
    }

    if (status ==
        'In Service') {
      return Colors.blue;
    }

    if (status ==
        'Cancelled') {
      return Colors.red;
    }

    return Colors.grey;
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xFFF3F6FA,
      ),

      appBar: AppBar(
        title:
        const Text(
          'My Bookings',
        ),
      ),

      body:
      loading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : bookings.isEmpty
          ? emptyBooking()
          : RefreshIndicator(
        onRefresh:
        loadBookings,
        child:
        ListView.builder(
          padding:
          const EdgeInsets.all(
            16,
          ),
          itemCount:
          bookings.length,
          itemBuilder:
              (
              context,
              index,
              ) {
            Booking booking =
            bookings[index];

            return bookingCard(
              booking,
            );
          },
        ),
      ),
    );
  }

  Widget bookingCard(
      Booking booking,
      ) {
    Vehicle? vehicle =
    findVehicle(
      booking.vehiclePlate,
    );

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 15,
      ),

      padding:
      const EdgeInsets.all(
        18,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        border:
        Border.all(
          color:
          const Color(
            0xFFE5E9EF,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFEAF1FA,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                const Icon(
                  Icons.build_outlined,
                  color:
                  Color(
                    0xFF0B2344,
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.serviceName,
                      style:
                      const TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      vehicle != null
                          ? '${vehicle.brand} ${vehicle.model}'
                          : booking.vehiclePlate,
                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF7B8494,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFE7F6EC,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),
                child: Text(
                  booking.status,
                  style:
                  TextStyle(
                    fontSize: 12,
                    color:
                    statusColor(
                      booking.status,
                    ),
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Divider(
            height: 28,
          ),

          infoRow(
            Icons
                .pin_outlined,
            'Plate',
            booking.vehiclePlate,
          ),

          infoRow(
            Icons
                .store_outlined,
            'Workshop',
            booking.workshopName,
          ),

          infoRow(
            Icons
                .calendar_month_outlined,
            'Date',
            formatDate(
              booking.date,
            ),
          ),

          infoRow(
            Icons
                .schedule_outlined,
            'Time',
            booking.time,
          ),

          if (booking.problemNote
              .trim()
              .isNotEmpty)
            infoRow(
              Icons
                  .description_outlined,
              'Problem',
              booking.problemNote,
            ),

          if (booking.problemPhotoUrl
              .trim()
              .isNotEmpty) ...[
            const SizedBox(
              height: 8,
            ),

            ClipRRect(
              borderRadius:
              BorderRadius.circular(
                12,
              ),
              child:
              Image.network(
                booking.problemPhotoUrl,
                width:
                double.infinity,
                height: 500,
                fit:
                BoxFit.contain,
                errorBuilder:
                    (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return Container(
                    height: 100,
                    color:
                    const Color(
                      0xFFF1F4F8,
                    ),
                    alignment:
                    Alignment.center,
                    child:
                    const Text(
                      'Photo unavailable',
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(
            height: 18,
          ),

          Row(
            children: [
              Expanded(
                child:
                OutlinedButton.icon(
                  onPressed: () {
                    showQrCode(
                      booking,
                    );
                  },
                  icon:
                  const Icon(
                    Icons
                        .qr_code_rounded,
                  ),
                  label:
                  const Text(
                    'QR Code',
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                OutlinedButton.icon(
                  onPressed: () {
                    addToCalendar(
                      booking,
                    );
                  },
                  icon:
                  const Icon(
                    Icons
                        .calendar_month_outlined,
                  ),
                  label:
                  const Text(
                    'Calendar',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          SizedBox(
            width:
            double.infinity,
            child:
            OutlinedButton.icon(
              onPressed: () {
                callWorkshop(
                  booking,
                );
              },
              icon:
              const Icon(
                Icons.call_outlined,
              ),
              label:
              const Text(
                'Call Workshop',
              ),
            ),
          ),

          if (booking.status ==
              'Confirmed' ||
              booking.status ==
                  'Pending') ...[
            const SizedBox(
              height: 10,
            ),

            SizedBox(
              width:
              double.infinity,
              child:
              OutlinedButton.icon(
                onPressed: () {
                  cancelBooking(
                    booking,
                  );
                },
                style:
                OutlinedButton
                    .styleFrom(
                  foregroundColor:
                  Colors.red,
                ),
                icon:
                const Icon(
                  Icons
                      .cancel_outlined,
                ),
                label:
                const Text(
                  'Cancel Booking',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget infoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color:
            const Color(
              0xFF0B2344,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          SizedBox(
            width: 70,
            child: Text(
              title,
              style:
              const TextStyle(
                color:
                Color(
                  0xFF7B8494,
                ),
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyBooking() {
    return const Center(
      child: Padding(
        padding:
        EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons
                  .calendar_month_outlined,
              size: 70,
              color:
              Color(
                0xFF7B8494,
              ),
            ),

            SizedBox(
              height: 18,
            ),

            Text(
              'No Upcoming Bookings',
              style:
              TextStyle(
                fontSize: 21,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 7,
            ),

            Text(
              'Your upcoming bookings will appear here.',
              textAlign:
              TextAlign.center,
              style:
              TextStyle(
                color:
                Color(
                  0xFF7B8494,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}