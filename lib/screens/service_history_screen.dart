import 'package:flutter/material.dart';

import '../models/booking_model.dart';
import '../models/vehicle_model.dart';
import '../services/database_helper.dart';
import '../services/user_session.dart';

class ServiceHistoryScreen
    extends StatefulWidget {

  const ServiceHistoryScreen({
    super.key,
  });

  @override
  State<ServiceHistoryScreen>
  createState() =>
      _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState
    extends State<ServiceHistoryScreen> {

  List<Booking> history = [];

  List<Vehicle> vehicles = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadHistory();
  }

  Future<void> loadHistory() async {
    final user =
        UserSession.currentUser;

    if (user?.id == null) {
      setState(() {
        isLoading = false;
      });

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

      List<Booking> pastServices =
      bookingResult.where(
            (booking) {

          DateTime bookingDate =
          DateTime(
            booking.date.year,
            booking.date.month,
            booking.date.day,
          );

          return bookingDate
              .isBefore(
            today,
          ) &&
              booking.status !=
                  'Cancelled';
        },
      ).toList();

      pastServices.sort(
            (a, b) =>
            b.date.compareTo(
              a.date,
            ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        history =
            pastServices;

        vehicles =
            vehicleResult;

        isLoading =
        false;
      });
    } catch (error) {
      debugPrint(
        'Service history error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  Vehicle? findVehicle(
      Booking booking,
      ) {
    for (Vehicle vehicle
    in vehicles) {

      if (vehicle.plateNumber
          .trim()
          .toLowerCase() ==
          booking.vehiclePlate
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
          'Service History',
        ),
      ),

      body:
      isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : history.isEmpty
          ? emptyHistory()
          : RefreshIndicator(
        onRefresh:
        loadHistory,

        child:
        ListView(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),

          children: [
            const Text(
              'Previous Services',

              style:
              TextStyle(
                color:
                Color(
                  0xFF0B2344,
                ),

                fontSize: 24,

                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'Your previous vehicle service records.',

              style:
              TextStyle(
                color:
                Color(
                  0xFF7B8494,
                ),
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            ...history.map(
              historyCard,
            ),
          ],
        ),
      ),
    );
  }

  Widget historyCard(
      Booking booking,
      ) {
    Vehicle? vehicle =
    findVehicle(
      booking,
    );

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 14,
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
            0xFFE6EAF0,
          ),
        ),
      ),

      child:
      Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,

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
                  Icons.build_rounded,

                  color:
                  Color(
                    0xFF0B2344,
                  ),
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

                  children: [
                    Text(
                      booking.serviceName,

                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF0B2344,
                        ),

                        fontSize: 17,

                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      vehicle != null
                          ? '${vehicle.brand} '
                          '${vehicle.model} • '
                          '${vehicle.plateNumber}'
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
                  horizontal: 10,
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

                child:
                const Text(
                  'Completed',

                  style:
                  TextStyle(
                    color:
                    Colors.green,

                    fontSize: 12,

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

          informationRow(
            Icons
                .location_on_outlined,

            booking.workshopName,
          ),

          informationRow(
            Icons
                .calendar_month_outlined,

            formatDate(
              booking.date,
            ),
          ),

          informationRow(
            Icons
                .access_time_rounded,

            booking.time,
          ),

          if (booking.problemNote
              .isNotEmpty)

            informationRow(
              Icons
                  .description_outlined,

              booking.problemNote,
            ),
        ],
      ),
    );
  }

  Widget informationRow(
      IconData icon,
      String text,
      ) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 11,
      ),

      child:
      Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Icon(
            icon,

            size: 19,

            color:
            const Color(
              0xFF2563A6,
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              text,

              style:
              const TextStyle(
                color:
                Color(
                  0xFF0B2344,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget emptyHistory() {
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
            CircleAvatar(
              radius: 55,

              backgroundColor:
              Color(
                0xFFEAF1FA,
              ),

              child: Icon(
                Icons.history_rounded,

                size: 55,

                color:
                Color(
                  0xFF0B2344,
                ),
              ),
            ),

            SizedBox(
              height: 20,
            ),

            Text(
              'No Service History',

              style:
              TextStyle(
                color:
                Color(
                  0xFF0B2344,
                ),

                fontSize: 22,

                fontWeight:
                FontWeight.w800,
              ),
            ),

            SizedBox(
              height: 8,
            ),

            Text(
              'Previous services will appear here after the booking date has passed.',

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