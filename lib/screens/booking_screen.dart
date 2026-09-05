import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/booking_model.dart';
import '../models/service_model.dart';
import '../models/vehicle_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../services/user_session.dart';
import 'my_booking_screen.dart';
import 'my_vehicle_screen.dart';

class BookingScreen extends StatefulWidget {
  final String? selectedService;
  final String? selectedWorkshop;
  final VoidCallback? onGoHome;
  final VoidCallback? onBookingComplete;

  const BookingScreen({
    super.key,
    this.selectedService,
    this.selectedWorkshop,
    this.onGoHome,
    this.onBookingComplete,
  });

  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();
}

class _BookingScreenState
    extends State<BookingScreen> {

  List<Vehicle> vehicles = [];

  final List<String> workshops = [
    '67AutoSpa Setapak',
    '67AutoSpa Cheras',
    '67AutoSpa Kepong',
  ];

  final List<String> times = [
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  String? selectedVehicle;
  String? selectedService;
  String? selectedWorkshop;
  String? selectedTime;

  DateTime selectedDate =
  DateTime.now();

  List<String> bookedTimes = [];

  bool loadingVehicles = true;
  bool booking = false;

  final problemController =
  TextEditingController();

  final ImagePicker imagePicker =
  ImagePicker();

  XFile? problemPhoto;

  @override
  void initState() {
    super.initState();

    selectedService =
        widget.selectedService;

    selectedWorkshop =
        widget.selectedWorkshop;

    loadVehicles();

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) {
        loadBookedTimes();
      },
    );
  }

  @override
  void didUpdateWidget(
      BookingScreen oldWidget,
      ) {
    super.didUpdateWidget(
      oldWidget,
    );

    if (widget.selectedService !=
        oldWidget.selectedService &&
        widget.selectedService !=
            null) {
      setState(() {
        selectedService =
            widget.selectedService;
      });
    }

    if (widget.selectedWorkshop !=
        oldWidget.selectedWorkshop &&
        widget.selectedWorkshop !=
            null) {
      setState(() {
        selectedWorkshop =
            widget.selectedWorkshop;

        selectedTime = null;
      });

      loadBookedTimes();
    }
  }

  Future<void> loadVehicles() async {
    final user =
        UserSession.currentUser;

    if (user?.id == null) {
      setState(() {
        loadingVehicles = false;
      });

      return;
    }

    try {
      List<Vehicle> result =
      await DatabaseHelper.instance
          .getVehicles(
        user!.id!,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        vehicles = result;
        loadingVehicles = false;
      });
    } catch (error) {
      debugPrint(
        'Vehicle error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        loadingVehicles = false;
      });
    }
  }

  Future<void> loadBookedTimes() async {
    if (selectedWorkshop == null) {
      setState(() {
        bookedTimes = [];
        selectedTime = null;
      });

      return;
    }

    try {
      List<String> result =
      await DatabaseHelper.instance
          .getBookedTimes(
        selectedWorkshop!,
        selectedDate,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        bookedTimes = result;

        if (selectedTime != null &&
            bookedTimes.contains(
              selectedTime,
            )) {
          selectedTime = null;
        }
      });
    } catch (error) {
      debugPrint(
        'Time error: $error',
      );
    }
  }

  Future<void> chooseDate() async {
    DateTime now =
    DateTime.now();

    DateTime today =
    DateTime(
      now.year,
      now.month,
      now.day,
    );

    DateTime? result =
    await showDatePicker(
      context: context,
      initialDate:
      selectedDate.isBefore(today)
          ? today
          : selectedDate,
      firstDate: today,
      lastDate:
      DateTime(
        now.year + 1,
      ),
    );

    if (result != null) {
      setState(() {
        selectedDate = result;
        selectedTime = null;
      });

      loadBookedTimes();
    }
  }

  Future<void> takePhoto() async {
    try {
      XFile? photo =
      await imagePicker.pickImage(
        source:
        ImageSource.camera,
        imageQuality: 75,
        maxWidth: 1200,
      );

      if (photo != null &&
          mounted) {
        setState(() {
          problemPhoto = photo;
        });
      }
    } catch (error) {
      showMessage(
        'Unable to open camera.',
      );
    }
  }

  Future<void> choosePhoto() async {
    try {
      XFile? photo =
      await imagePicker.pickImage(
        source:
        ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1200,
      );

      if (photo != null &&
          mounted) {
        setState(() {
          problemPhoto = photo;
        });
      }
    } catch (error) {
      showMessage(
        'Unable to select photo.',
      );
    }
  }

  void showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading:
                const Icon(
                  Icons
                      .camera_alt_outlined,
                ),
                title:
                const Text(
                  'Take Photo',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                  );

                  takePhoto();
                },
              ),

              ListTile(
                leading:
                const Icon(
                  Icons
                      .photo_library_outlined,
                ),
                title:
                const Text(
                  'Choose From Gallery',
                ),
                onTap: () {
                  Navigator.pop(
                    context,
                  );

                  choosePhoto();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> addVehicle() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
        const MyVehicleScreen(),
      ),
    );

    loadVehicles();
  }

  String vehicleText(
      String plate,
      ) {
    for (Vehicle vehicle
    in vehicles) {
      if (vehicle.plateNumber ==
          plate) {
        return '${vehicle.brand} '
            '${vehicle.model} • '
            '${vehicle.plateNumber}';
      }
    }

    return plate;
  }

  String formatDate(
      DateTime date,
      ) {
    return '${date.day}/'
        '${date.month}/'
        '${date.year}';
  }

  DateTime getBookingDateTime() {
    String clean =
    selectedTime!
        .replaceAll(
      ' AM',
      '',
    )
        .replaceAll(
      ' PM',
      '',
    );

    List<String> parts =
    clean.split(
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

    if (selectedTime!.contains(
      'PM',
    ) &&
        hour != 12) {
      hour += 12;
    }

    if (selectedTime!.contains(
      'AM',
    ) &&
        hour == 12) {
      hour = 0;
    }

    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      hour,
      minute,
    );
  }

  void resetBookingForm() {
    DateTime now =
    DateTime.now();

    setState(() {
      selectedVehicle = null;
      selectedService = null;
      selectedWorkshop = null;
      selectedTime = null;

      selectedDate =
          DateTime(
            now.year,
            now.month,
            now.day,
          );

      bookedTimes = [];

      problemController.clear();

      problemPhoto = null;

      booking = false;
    });

    widget.onBookingComplete
        ?.call();
  }

  Future<void> confirmBooking() async {
    if (selectedVehicle == null) {
      showMessage(
        'Please select a vehicle.',
      );

      return;
    }

    if (selectedService == null) {
      showMessage(
        'Please select a service.',
      );

      return;
    }

    if (selectedWorkshop == null) {
      showMessage(
        'Please select a workshop.',
      );

      return;
    }

    if (selectedTime == null) {
      showMessage(
        'Please select a time.',
      );

      return;
    }

    final user =
        UserSession.currentUser;

    if (user?.id == null) {
      showMessage(
        'Please login again.',
      );

      return;
    }

    setState(() {
      booking = true;
    });

    try {
      List<String> latestTimes =
      await DatabaseHelper.instance
          .getBookedTimes(
        selectedWorkshop!,
        selectedDate,
      );

      if (latestTimes.contains(
        selectedTime,
      )) {
        setState(() {
          bookedTimes =
              latestTimes;
          selectedTime = null;
          booking = false;
        });

        showMessage(
          'This time slot is already booked.',
        );

        return;
      }

      String photoUrl = '';

      if (problemPhoto != null) {
        photoUrl =
        await DatabaseHelper.instance
            .uploadBookingPhoto(
          problemPhoto!,
          user!.id!,
        );
      }

      String savedVehicle =
      selectedVehicle!;

      String savedService =
      selectedService!;

      String savedWorkshop =
      selectedWorkshop!;

      String savedTime =
      selectedTime!;

      DateTime savedDate =
          selectedDate;

      DateTime savedBookingDateTime =
      getBookingDateTime();

      Booking newBooking =
      Booking(
        userId:
        user!.id!,
        vehiclePlate:
        savedVehicle,
        serviceName:
        savedService,
        workshopName:
        savedWorkshop,
        date:
        DateTime(
          savedDate.year,
          savedDate.month,
          savedDate.day,
        ),
        time:
        savedTime,
        status:
        'Confirmed',
        problemNote:
        problemController.text
            .trim(),
        problemPhotoUrl:
        photoUrl,
      );

      int bookingId =
      await DatabaseHelper.instance
          .addBooking(
        newBooking,
      );

      try {
        await NotificationService
            .instance
            .scheduleBookingReminder(
          bookingId:
          bookingId,
          serviceName:
          savedService,
          vehiclePlate:
          savedVehicle,
          bookingDateTime:
          savedBookingDateTime,
        );
      } catch (error) {
        debugPrint(
          'Notification error: $error',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        booking = false;
      });

      showSuccess(
        vehicle:
        vehicleText(
          savedVehicle,
        ),
        service:
        savedService,
        workshop:
        savedWorkshop,
        date:
        formatDate(
          savedDate,
        ),
        time:
        savedTime,
      );
    } catch (error) {
      debugPrint(
        'Booking error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        booking = false;
      });

      showMessage(
        'Unable to complete booking.',
      );
    }
  }

  void showSuccess({
    required String vehicle,
    required String service,
    required String workshop,
    required String date,
    required String time,
  }) {
    showDialog(
      context: context,
      barrierDismissible:
      false,
      builder:
          (dialogContext) {
        return AlertDialog(
          icon:
          const Icon(
            Icons
                .check_circle_rounded,
            color:
            Colors.green,
            size: 58,
          ),

          title:
          const Text(
            'Booking Confirmed!',
          ),

          content:
          Text(
            '$vehicle\n'
                '$service\n'
                '$workshop\n'
                '$date • $time\n\n'
                'Your service reminder has been scheduled.',
            textAlign:
            TextAlign.center,
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                resetBookingForm();

                widget.onGoHome
                    ?.call();
              },
              child:
              const Text(
                'Back to Home',
              ),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );

                resetBookingForm();

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                    const MyBookingScreen(),
                  ),
                );
              },
              child:
              const Text(
                'View Booking',
              ),
            ),
          ],
        );
      },
    );
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

  @override
  void dispose() {
    problemController.dispose();

    super.dispose();
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
          'Book a Service',
        ),
      ),

      body:
      SingleChildScrollView(
        padding:
        const EdgeInsets.all(
          20,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Text(
              'Make a Booking',
              style:
              TextStyle(
                color:
                Color(
                  0xFF0B2344,
                ),
                fontSize: 25,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            title(
              '1',
              'Vehicle',
            ),

            const SizedBox(
              height: 10,
            ),

            if (loadingVehicles)
              const Center(
                child:
                CircularProgressIndicator(),
              )
            else if (vehicles.isEmpty)
              noVehicle()
            else
              DropdownButtonFormField<
                  String>(
                value:
                selectedVehicle,
                isExpanded:
                true,
                decoration:
                const InputDecoration(
                  hintText:
                  'Select your vehicle',
                  prefixIcon:
                  Icon(
                    Icons
                        .directions_car_outlined,
                  ),
                ),
                items:
                vehicles.map(
                      (vehicle) {
                    return DropdownMenuItem<
                        String>(
                      value:
                      vehicle.plateNumber,
                      child:
                      Text(
                        '${vehicle.brand} '
                            '${vehicle.model} • '
                            '${vehicle.plateNumber}',
                      ),
                    );
                  },
                ).toList(),
                onChanged:
                    (value) {
                  setState(() {
                    selectedVehicle =
                        value;
                  });
                },
              ),

            const SizedBox(
              height: 24,
            ),

            title(
              '2',
              'Service',
            ),

            const SizedBox(
              height: 10,
            ),

            DropdownButtonFormField<
                String>(
              value:
              ServiceCatalog.findService(
                selectedService,
              ) !=
                  null
                  ? selectedService
                  : null,
              isExpanded:
              true,
              decoration:
              const InputDecoration(
                hintText:
                'Select a service',
                prefixIcon:
                Icon(
                  Icons.build_outlined,
                ),
              ),
              items:
              ServiceCatalog.services
                  .map(
                    (service) {
                  return DropdownMenuItem<
                      String>(
                    value:
                    service.name,
                    child:
                    Text(
                      service.name,
                    ),
                  );
                },
              ).toList(),
              onChanged:
                  (value) {
                setState(() {
                  selectedService =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 24,
            ),

            title(
              '3',
              'Workshop',
            ),

            const SizedBox(
              height: 10,
            ),

            DropdownButtonFormField<
                String>(
              value:
              workshops.contains(
                selectedWorkshop,
              )
                  ? selectedWorkshop
                  : null,
              isExpanded:
              true,
              decoration:
              const InputDecoration(
                hintText:
                'Select a workshop',
                prefixIcon:
                Icon(
                  Icons.store_outlined,
                ),
              ),
              items:
              workshops.map(
                    (workshop) {
                  return DropdownMenuItem<
                      String>(
                    value: workshop,
                    child:
                    Text(
                      workshop,
                    ),
                  );
                },
              ).toList(),
              onChanged:
                  (value) {
                setState(() {
                  selectedWorkshop =
                      value;
                  selectedTime = null;
                });

                loadBookedTimes();
              },
            ),

            const SizedBox(
              height: 24,
            ),

            title(
              '4',
              'Date',
            ),

            const SizedBox(
              height: 10,
            ),

            OutlinedButton.icon(
              onPressed:
              chooseDate,
              icon:
              const Icon(
                Icons
                    .calendar_month_outlined,
              ),
              label:
              Text(
                formatDate(
                  selectedDate,
                ),
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            title(
              '5',
              'Available Time',
            ),

            const SizedBox(
              height: 10,
            ),

            if (selectedWorkshop ==
                null)
              const Text(
                'Select a workshop first.',
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                times.map(
                      (time) {
                    bool full =
                    bookedTimes.contains(
                      time,
                    );

                    return ChoiceChip(
                      label:
                      Text(
                        full
                            ? '$time - Full'
                            : time,
                      ),
                      selected:
                      selectedTime ==
                          time,
                      onSelected:
                      full
                          ? null
                          : (selected) {
                        setState(() {
                          selectedTime =
                          selected
                              ? time
                              : null;
                        });
                      },
                    );
                  },
                ).toList(),
              ),

            const SizedBox(
              height: 24,
            ),

            title(
              '6',
              'Vehicle Problem',
            ),

            const SizedBox(
              height: 10,
            ),

            TextField(
              controller:
              problemController,
              maxLines: 3,
              decoration:
              const InputDecoration(
                hintText:
                'Example: Engine warning light is on',
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            InkWell(
              onTap:
              showPhotoOptions,
              child: Container(
                width:
                double.infinity,
                padding:
                const EdgeInsets.all(
                  15,
                ),
                decoration:
                BoxDecoration(
                  color:
                  Colors.white,
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
                child:
                problemPhoto == null
                    ? const Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .camera_alt_outlined,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Add Problem Photo',
                    ),
                  ],
                )
                    : Column(
                  children: [
                    FutureBuilder<Uint8List>(
                      future:
                      problemPhoto!
                          .readAsBytes(),
                      builder:
                          (context, snapshot) {
                        if (snapshot
                            .connectionState ==
                            ConnectionState
                                .waiting) {
                          return const SizedBox(
                            height: 180,
                            child:
                            Center(
                              child:
                              CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError ||
                            !snapshot.hasData) {
                          return const SizedBox(
                            height: 180,
                            child:
                            Center(
                              child:
                              Text(
                                'Unable to display photo.',
                              ),
                            ),
                          );
                        }

                        return Image.memory(
                          snapshot.data!,
                          height: 500,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        );
                      },
                    ),

                    TextButton(
                      onPressed: () {
                        setState(() {
                          problemPhoto =
                          null;
                        });
                      },
                      child:
                      const Text(
                        'Remove Photo',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            if (selectedVehicle !=
                null &&
                selectedService !=
                    null &&
                selectedWorkshop !=
                    null &&
                selectedTime !=
                    null)
              summary(),

            const SizedBox(
              height: 20,
            ),

            SizedBox(
              width:
              double.infinity,
              child:
              ElevatedButton(
                onPressed:
                booking
                    ? null
                    : confirmBooking,
                child:
                booking
                    ? const CircularProgressIndicator(
                  color:
                  Colors.white,
                )
                    : const Text(
                  'Confirm Booking',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget title(
      String number,
      String text,
      ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor:
          const Color(
            0xFF0B2344,
          ),
          child:
          Text(
            number,
            style:
            const TextStyle(
              color:
              Colors.white,
            ),
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        Text(
          text,
          style:
          const TextStyle(
            fontSize: 17,
            fontWeight:
            FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget noVehicle() {
    return OutlinedButton(
      onPressed:
      addVehicle,
      child:
      const Text(
        'Add Vehicle',
      ),
    );
  }

  Widget summary() {
    return Container(
      width:
      double.infinity,
      padding:
      const EdgeInsets.all(
        16,
      ),
      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFEAF1FA,
        ),
        borderRadius:
        BorderRadius.circular(
          15,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style:
            TextStyle(
              fontWeight:
              FontWeight.bold,
              fontSize: 17,
            ),
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            vehicleText(
              selectedVehicle!,
            ),
          ),

          Text(
            selectedService!,
          ),

          Text(
            selectedWorkshop!,
          ),

          Text(
            '${formatDate(selectedDate)} • $selectedTime',
          ),
        ],
      ),
    );
  }
}