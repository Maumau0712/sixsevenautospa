import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/vehicle_model.dart';
import '../services/database_helper.dart';
import '../services/user_session.dart';

class MyVehicleScreen extends StatefulWidget {
  const MyVehicleScreen({super.key});

  @override
  State<MyVehicleScreen> createState() =>
      _MyVehicleScreenState();
}

class _MyVehicleScreenState extends State<MyVehicleScreen> {
  static const navy = Color(0xFF0B2344);
  static const grey = Color(0xFF7B8494);

  final plateController =
  TextEditingController();

  final brandController =
  TextEditingController();

  final modelController =
  TextEditingController();

  final yearController =
  TextEditingController();

  List<Vehicle> vehicles = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadVehicles();
  }

  Future<void> loadVehicles() async {
    final user = UserSession.currentUser;

    if (user == null || user.id == null) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      return;
    }

    final result =
    await DatabaseHelper.instance
        .getVehicles(user.id!);

    if (!mounted) {
      return;
    }

    setState(() {
      vehicles = result;
      isLoading = false;
    });
  }

  void showAddVehicleDialog() {
    plateController.clear();
    brandController.clear();
    modelController.clear();
    yearController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add Vehicle',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                TextField(
                  controller:
                  plateController,
                  textCapitalization:
                  TextCapitalization
                      .characters,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Plate Number',
                    prefixIcon: Icon(
                      Icons
                          .confirmation_number_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller:
                  brandController,
                  textCapitalization:
                  TextCapitalization.words,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Car Brand',
                    hintText: 'Toyota',
                    prefixIcon: Icon(
                      Icons
                          .directions_car_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller:
                  modelController,
                  textCapitalization:
                  TextCapitalization.words,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Car Model',
                    hintText: 'Vios',
                    prefixIcon: Icon(
                      Icons
                          .car_repair_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller:
                  yearController,
                  keyboardType:
                  TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter
                        .digitsOnly,
                    LengthLimitingTextInputFormatter(
                      4,
                    ),
                  ],
                  decoration:
                  const InputDecoration(
                    labelText: 'Year',
                    hintText: '2022',
                    prefixIcon: Icon(
                      Icons
                          .calendar_month_outlined,
                    ),
                  ),
                ),
              ],
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
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                addVehicle(
                  dialogContext,
                );
              },
              child: const Text(
                'Add Vehicle',
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> addVehicle(
      BuildContext dialogContext,
      ) async {
    final plate =
    plateController.text
        .trim()
        .toUpperCase();

    final brand =
    brandController.text.trim();

    final model =
    modelController.text.trim();

    final year =
    yearController.text.trim();

    if (plate.isEmpty ||
        brand.isEmpty ||
        model.isEmpty ||
        year.isEmpty) {
      showMessage(
        'Please fill in all vehicle information.',
      );
      return;
    }

    if (year.length != 4) {
      showMessage(
        'Please enter a valid vehicle year.',
      );
      return;
    }

    final user =
        UserSession.currentUser;

    if (user == null ||
        user.id == null) {
      showMessage(
        'Please login again.',
      );
      return;
    }

    final alreadyExists =
    vehicles.any(
          (vehicle) =>
      vehicle.plateNumber
          .toUpperCase() ==
          plate,
    );

    if (alreadyExists) {
      showMessage(
        'This vehicle is already registered.',
      );
      return;
    }

    final vehicle = Vehicle(
      userId: user.id!,
      plateNumber: plate,
      brand: brand,
      model: model,
      year: year,
    );

    await DatabaseHelper.instance
        .addVehicle(vehicle);

    if (!mounted) {
      return;
    }

    Navigator.pop(dialogContext);

    await loadVehicles();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Vehicle added successfully.',
        ),
        backgroundColor:
        Colors.green,
      ),
    );
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> removeVehicle(
      Vehicle vehicle,
      ) async {
    if (vehicle.id == null) {
      return;
    }

    final confirm =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Vehicle',
          ),
          content: Text(
            'Are you sure you want to remove '
                '${vehicle.brand} '
                '${vehicle.model} '
                '(${vehicle.plateNumber})?',
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
                'Remove',
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

    await DatabaseHelper.instance
        .deleteVehicle(
      vehicle.id!,
    );

    await loadVehicles();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content: Text(
          'Vehicle removed.',
        ),
      ),
    );
  }

  @override
  void dispose() {
    plateController.dispose();
    brandController.dispose();
    modelController.dispose();
    yearController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF3F6FA),

      appBar: AppBar(
        title: const Text(
          'My Vehicles',
        ),
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed:
        showAddVehicleDialog,
        backgroundColor: navy,
        foregroundColor:
        Colors.white,
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add Vehicle',
        ),
      ),

      body: isLoading
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : vehicles.isEmpty
          ? buildEmptyVehicle()
          : RefreshIndicator(
        onRefresh: loadVehicles,
        child: ListView(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            100,
          ),
          children: [
            const Text(
              'Registered Vehicles',
              style: TextStyle(
                color: navy,
                fontSize: 24,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            const Text(
              'Manage vehicles used for your service bookings.',
              style: TextStyle(
                color: grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            ...vehicles.map(
              buildVehicleCard,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildVehicleCard(
      Vehicle vehicle,
      ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: const Color(
            0xFFE6EAF0,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color:
              const Color(0xFFEAF1FA),
              borderRadius:
              BorderRadius.circular(
                16,
              ),
            ),
            child: const Icon(
              Icons.directions_car_rounded,
              size: 32,
              color: navy,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} '
                      '${vehicle.model}',
                  style: const TextStyle(
                    color: navy,
                    fontSize: 17,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  vehicle.plateNumber,
                  style: const TextStyle(
                    color: Color(
                      0xFF2563A6,
                    ),
                    fontSize: 14,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Year ${vehicle.year}',
                  style: const TextStyle(
                    color: grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Remove vehicle',
            onPressed: () {
              removeVehicle(vehicle);
            },
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyVehicle() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration:
              const BoxDecoration(
                color: Color(
                  0xFFEAF1FA,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_outlined,
                size: 55,
                color: navy,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'No Vehicles Added',
              style: TextStyle(
                color: navy,
                fontSize: 22,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add your vehicle before making a service booking.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: grey,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton.icon(
              onPressed:
              showAddVehicleDialog,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Add Your First Vehicle',
              ),
            ),
          ],
        ),
      ),
    );
  }
}