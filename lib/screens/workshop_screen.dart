import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkshopScreen extends StatefulWidget {
  const WorkshopScreen({
    super.key,
  });

  @override
  State<WorkshopScreen> createState() =>
      _WorkshopScreenState();
}

class _WorkshopScreenState
    extends State<WorkshopScreen> {

  Position? currentPosition;

  bool gettingLocation = true;

  bool locationAvailable = false;

  final List<Map<String, dynamic>> workshops = [
    {
      'name': '67AutoSpa Setapak',
      'address': 'Setapak, Kuala Lumpur',

      'latitude': 3.2066149,
      'longitude': 101.7175568,

      'rating': '4.8',
      'open': true,

      'phone': '0367326767',
    },

    {
      'name': '67AutoSpa Cheras',
      'address': 'Cheras, Kuala Lumpur',

      'latitude': 3.090122,
      'longitude': 101.741520,

      'rating': '4.7',
      'open': true,

      'phone': '0367326767',
    },

    {
      'name': '67AutoSpa Kepong',
      'address': 'Kepong, Kuala Lumpur',

      'latitude': 3.213549,
      'longitude': 101.632810,

      'rating': '4.6',
      'open': true,

      'phone': '0367326767',
    },
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        getCurrentLocation();
      },
    );
  }

  Future<void> getCurrentLocation() async {
    if (!mounted) {
      return;
    }

    setState(() {
      gettingLocation = true;
    });

    try {
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) {
          return;
        }

        setState(() {
          gettingLocation = false;
          locationAvailable = false;
        });

        return;
      }

      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {

        permission =
        await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {

        if (!mounted) {
          return;
        }

        setState(() {
          gettingLocation = false;
          locationAvailable = false;
        });

        return;
      }

      Position position =
      await Geolocator.getCurrentPosition();

      if (!mounted) {
        return;
      }

      setState(() {
        currentPosition = position;
        gettingLocation = false;
        locationAvailable = true;
      });

      sortWorkshopsByDistance();

    } catch (error) {
      debugPrint(
        'GPS error: $error',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        gettingLocation = false;
        locationAvailable = false;
      });
    }
  }

  void sortWorkshopsByDistance() {
    if (currentPosition == null) {
      return;
    }

    workshops.sort(
          (a, b) {
        double distanceA =
        calculateDistance(
          a,
        );

        double distanceB =
        calculateDistance(
          b,
        );

        return distanceA.compareTo(
          distanceB,
        );
      },
    );

    if (mounted) {
      setState(() {});
    }
  }

  double calculateDistance(
      Map<String, dynamic> workshop,
      ) {
    if (currentPosition == null) {
      return 0;
    }

    double meters =
    Geolocator.distanceBetween(
      currentPosition!.latitude,
      currentPosition!.longitude,
      workshop['latitude'],
      workshop['longitude'],
    );

    return meters / 1000;
  }

  Future<void> callWorkshop(
      String phoneNumber,
      ) async {
    Uri phoneUri =
    Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    try {
      bool opened =
      await launchUrl(
        phoneUri,
        mode:
        LaunchMode.externalApplication,
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

  Future<void> openNavigation(
      Map<String, dynamic> workshop,
      ) async {
    double latitude =
    workshop['latitude'];

    double longitude =
    workshop['longitude'];

    String workshopName =
    workshop['name'];

    Uri googleMapsUrl =
    Uri.parse(
      'https://www.google.com/maps/dir/'
          '?api=1'
          '&destination=$latitude,$longitude',
    );

    try {
      bool opened =
      await launchUrl(
        googleMapsUrl,
        mode:
        LaunchMode.externalApplication,
      );

      if (!opened) {
        Uri geoUrl =
        Uri.parse(
          'geo:$latitude,$longitude'
              '?q=$latitude,$longitude'
              '($workshopName)',
        );

        opened =
        await launchUrl(
          geoUrl,
          mode:
          LaunchMode.externalApplication,
        );
      }

      if (!opened) {
        showMessage(
          'Please install Google Maps or a browser.',
        );
      }

    } catch (error) {
      debugPrint(
        'Navigation error: $error',
      );

      showMessage(
        'Unable to open navigation.',
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
        content: Text(
          message,
        ),
      ),
    );
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
        title: const Text(
          'Our Workshops',
        ),
      ),

      body: RefreshIndicator(
        onRefresh:
        getCurrentLocation,

        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            30,
          ),

          children: [
            const Text(
              'Choose a Workshop',

              style: TextStyle(
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
              height: 6,
            ),

            const Text(
              'Choose the workshop that is most convenient for you.',

              style: TextStyle(
                color:
                Color(
                  0xFF7B8494,
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            buildLocationStatus(),

            const SizedBox(
              height: 20,
            ),

            ...workshops.map(
                  (workshop) {
                bool isOpen =
                workshop['open'];

                double distance =
                calculateDistance(
                  workshop,
                );

                return buildWorkshopCard(
                  workshop,
                  isOpen,
                  distance,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLocationStatus() {
    if (gettingLocation) {
      return Container(
        padding:
        const EdgeInsets.all(
          14,
        ),

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

        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,

              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color:
                Color(
                  0xFF0B2344,
                ),
              ),
            ),

            SizedBox(
              width: 12,
            ),

            Expanded(
              child: Text(
                'Checking your location to find the nearest workshop...',

                style: TextStyle(
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

    if (locationAvailable &&
        currentPosition != null) {

      return Container(
        padding:
        const EdgeInsets.all(
          14,
        ),

        decoration:
        BoxDecoration(
          color:
          const Color(
            0xFFE7F6EC,
          ),

          borderRadius:
          BorderRadius.circular(
            14,
          ),
        ),

        child: const Row(
          children: [
            Icon(
              Icons
                  .location_on_outlined,

              color:
              Colors.green,
            ),

            SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                'Nearest workshops are shown first.',

                style: TextStyle(
                  color:
                  Color(
                    0xFF0B2344,
                  ),

                  fontWeight:
                  FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding:
      const EdgeInsets.all(
        14,
      ),

      decoration:
      BoxDecoration(
        color:
        const Color(
          0xFFFFF8E8,
        ),

        borderRadius:
        BorderRadius.circular(
          14,
        ),
      ),

      child: const Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Icon(
            Icons
                .location_off_outlined,

            color:
            Colors.orange,
          ),

          SizedBox(
            width: 10,
          ),

          Expanded(
            child: Text(
              'Location is unavailable. You can still choose any workshop below.',

              style: TextStyle(
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

  Widget buildWorkshopCard(
      Map<String, dynamic> workshop,
      bool isOpen,
      double distance,
      ) {
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
                width: 58,
                height: 58,

                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFFEAF1FA,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                ),

                child:
                const Icon(
                  Icons
                      .car_repair_rounded,

                  size: 30,

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
                  CrossAxisAlignment.start,

                  children: [
                    Text(
                      workshop['name'],

                      style:
                      const TextStyle(
                        fontSize: 17,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      workshop['address'],

                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF7B8494,
                        ),
                      ),
                    ),

                    if (currentPosition !=
                        null) ...[
                      const SizedBox(
                        height: 6,
                      ),

                      Row(
                        children: [
                          const Icon(
                            Icons
                                .location_on_outlined,

                            size: 16,

                            color:
                            Color(
                              0xFF2563A6,
                            ),
                          ),

                          const SizedBox(
                            width: 4,
                          ),

                          Text(
                            '${distance.toStringAsFixed(1)} km away',

                            style:
                            const TextStyle(
                              color:
                              Color(
                                0xFF2563A6,
                              ),

                              fontSize: 12,

                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                  isOpen
                      ? const Color(
                    0xFFE7F6EC,
                  )
                      : const Color(
                    0xFFFFEBEB,
                  ),

                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),

                child: Text(
                  isOpen
                      ? 'Open'
                      : 'Closed',

                  style:
                  TextStyle(
                    fontSize: 12,

                    fontWeight:
                    FontWeight.bold,

                    color:
                    isOpen
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          Row(
            children: [
              const Icon(
                Icons.star_rounded,

                color:
                Colors.orange,

                size: 20,
              ),

              const SizedBox(
                width: 5,
              ),

              Text(
                workshop['rating'],
              ),

              if (currentPosition !=
                  null) ...[
                const SizedBox(
                  width: 12,
                ),

                if (workshop ==
                    workshops.first)

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFEAF1FA,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        20,
                      ),
                    ),

                    child:
                    const Text(
                      'Nearest',

                      style:
                      TextStyle(
                        color:
                        Color(
                          0xFF2563A6,
                        ),

                        fontSize: 11,

                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
              ],

              const Spacer(),

              if (isOpen)

                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      workshop['name'],
                    );
                  },

                  icon:
                  const Icon(
                    Icons
                        .check_circle_outline,

                    size: 18,
                  ),

                  label:
                  const Text(
                    'Select',
                  ),
                ),
            ],
          ),

          const Divider(),

          Row(
            children: [
              Expanded(
                child:
                OutlinedButton.icon(
                  onPressed: () {
                    callWorkshop(
                      workshop['phone'],
                    );
                  },

                  icon:
                  const Icon(
                    Icons
                        .call_outlined,
                  ),

                  label:
                  const Text(
                    'Call',
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                ElevatedButton.icon(
                  onPressed: () {
                    openNavigation(
                      workshop,
                    );
                  },

                  icon:
                  const Icon(
                    Icons
                        .navigation_outlined,
                  ),

                  label:
                  const Text(
                    'Navigate',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}