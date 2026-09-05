import 'package:flutter/material.dart';

import '../models/service_model.dart';
import '../services/user_session.dart';
import 'my_booking_screen.dart';
import 'service_detail_screen.dart';
import 'weather_screen.dart';
import 'workshop_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onChangeTab;
  final Function(String) onBookService;
  final Function(String) onBookWorkshop;

  const HomeScreen({
    super.key,
    required this.onChangeTab,
    required this.onBookService,
    required this.onBookWorkshop,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController =
  TextEditingController();

  String searchText = '';

  List<ServiceModel> get searchResults {
    if (searchText.trim().isEmpty) {
      return [];
    }

    String text =
    searchText.trim().toLowerCase();

    return ServiceCatalog.services.where(
          (service) {
        return service.name
            .toLowerCase()
            .contains(text) ||
            service.shortName
                .toLowerCase()
                .contains(text) ||
            service.description
                .toLowerCase()
                .contains(text);
      },
    ).toList();
  }

  void openService(
      ServiceModel service,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ServiceDetailScreen(
              service: service,
              onBookService:
              widget.onBookService,
            ),
      ),
    );
  }

  Future<void> openWorkshops() async {
    String? workshop =
    await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const WorkshopScreen(),
      ),
    );

    if (workshop != null) {
      widget.onBookWorkshop(
        workshop,
      );
    }
  }

  void openBookings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const MyBookingScreen(),
      ),
    );
  }

  void openWeather() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const WeatherScreen(),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    const navy =
    Color(0xFF0B2344);

    String name =
        UserSession.currentUser?.name ??
            'User';

    String firstName =
    name.trim().isEmpty
        ? 'User'
        : name
        .trim()
        .split(' ')
        .first;

    return Scaffold(
      backgroundColor:
      const Color(
        0xFFF3F6FA,
      ),

      appBar: AppBar(
        backgroundColor:
        const Color(
          0xFFF3F6FA,
        ),

        elevation: 0,

        title: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            const Text(
              '67AutoSpa',

              style: TextStyle(
                color: navy,
                fontSize: 22,
                fontWeight:
                FontWeight.w800,
              ),
            ),

            Text(
              'Hi, $firstName',

              style:
              const TextStyle(
                color:
                Color(
                  0xFF7B8494,
                ),

                fontSize: 12,
              ),
            ),
          ],
        ),

        actions: [
          IconButton(
            tooltip:
            'My Bookings',

            onPressed:
            openBookings,

            icon:
            const Icon(
              Icons
                  .calendar_month_outlined,

              color: navy,
            ),
          ),

          const SizedBox(
            width: 8,
          ),
        ],
      ),

      body:
      SingleChildScrollView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          30,
        ),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            TextField(
              controller:
              searchController,

              onChanged:
                  (value) {
                setState(() {
                  searchText =
                      value;
                });
              },

              decoration:
              InputDecoration(
                hintText:
                'Search services',

                filled: true,

                fillColor:
                Colors.white,

                prefixIcon:
                const Icon(
                  Icons.search,
                ),

                suffixIcon:
                searchText.isNotEmpty
                    ? IconButton(
                  onPressed:
                      () {
                    searchController
                        .clear();

                    setState(() {
                      searchText =
                      '';
                    });
                  },

                  icon:
                  const Icon(
                    Icons.close,
                  ),
                )
                    : null,

                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),

                  borderSide:
                  BorderSide.none,
                ),
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            if (searchText
                .trim()
                .isNotEmpty)
              buildSearchResults()
            else
              buildHomeContent(),
          ],
        ),
      ),
    );
  }

  Widget buildSearchResults() {
    List<ServiceModel> results =
        searchResults;

    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding:
          EdgeInsets.only(
            top: 40,
          ),

          child: Column(
            children: [
              Icon(
                Icons
                    .search_off_rounded,

                size: 55,

                color:
                Color(
                  0xFF7B8494,
                ),
              ),

              SizedBox(
                height: 12,
              ),

              Text(
                'No service found',

                style:
                TextStyle(
                  fontSize: 17,

                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children:
      results.map(
            (service) {
          return Padding(
            padding:
            const EdgeInsets.only(
              bottom: 12,
            ),

            child: serviceCard(
              service,
            ),
          );
        },
      ).toList(),
    );
  }

  Widget buildHomeContent() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        // MAIN BANNER
        Container(
          width:
          double.infinity,

          padding:
          const EdgeInsets.all(
            20,
          ),

          decoration:
          BoxDecoration(
            color:
            const Color(
              0xFF0B2344,
            ),

            borderRadius:
            BorderRadius.circular(
              22,
            ),
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              const Text(
                'Take Care of Your Car',

                style:
                TextStyle(
                  color:
                  Colors.white,

                  fontSize: 22,

                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              const Text(
                'Book your next vehicle service easily with 67AutoSpa.',

                style:
                TextStyle(
                  color:
                  Colors.white70,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              ElevatedButton(
                onPressed: () {
                  widget.onChangeTab(
                    2,
                  );
                },

                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  Colors.white,

                  foregroundColor:
                  const Color(
                    0xFF0B2344,
                  ),
                ),

                child:
                const Text(
                  'Book a Service',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 24,
        ),

        // WEATHER
        InkWell(
          onTap:
          openWeather,

          borderRadius:
          BorderRadius.circular(
            18,
          ),

          child: Container(
            width:
            double.infinity,

            padding:
            const EdgeInsets.all(
              18,
            ),

            decoration:
            BoxDecoration(
              color:
              const Color(
                0xFFEAF1FA,
              ),

              borderRadius:
              BorderRadius.circular(
                18,
              ),
            ),

            child:
            const Row(
              children: [
                CircleAvatar(
                  radius: 27,

                  backgroundColor:
                  Colors.white,

                  child: Icon(
                    Icons
                        .cloud_outlined,

                    color:
                    Color(
                      0xFF0B2344,
                    ),

                    size: 29,
                  ),
                ),

                SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      Text(
                        'Weather',

                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF0B2344,
                          ),

                          fontSize: 16,

                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      SizedBox(
                        height: 4,
                      ),

                      Text(
                        'Check local weather before your car service',

                        style:
                        TextStyle(
                          color:
                          Color(
                            0xFF7B8494,
                          ),

                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  Icons
                      .arrow_forward_ios,

                  size: 16,

                  color:
                  Color(
                    0xFF0B2344,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(
          height: 28,
        ),

        // OUR SERVICES
        Row(
          mainAxisAlignment:
          MainAxisAlignment
              .spaceBetween,

          children: [
            const Text(
              'Our Services',

              style:
              TextStyle(
                color:
                Color(
                  0xFF0B2344,
                ),

                fontSize: 19,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            TextButton(
              onPressed: () {
                widget.onChangeTab(
                  1,
                );
              },

              child:
              const Text(
                'View All',
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 8,
        ),

        SizedBox(
          height: 130,

          child:
          ListView.separated(
            scrollDirection:
            Axis.horizontal,

            itemCount:
            ServiceCatalog
                .services.length,

            separatorBuilder:
                (context, index) =>
            const SizedBox(
              width: 12,
            ),

            itemBuilder:
                (context, index) {
              ServiceModel service =
              ServiceCatalog
                  .services[index];

              return InkWell(
                onTap: () {
                  openService(
                    service,
                  );
                },

                borderRadius:
                BorderRadius.circular(
                  18,
                ),

                child: Container(
                  width: 115,

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
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,

                    children: [
                      Icon(
                        service.icon,

                        color:
                        const Color(
                          0xFF0B2344,
                        ),

                        size: 32,
                      ),

                      const SizedBox(
                        height: 10,
                      ),

                      Padding(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 5,
                        ),

                        child: Text(
                          service.shortName,

                          textAlign:
                          TextAlign.center,

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w600,

                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(
          height: 28,
        ),

        // POPULAR SERVICE
        const Text(
          'Popular Service',

          style:
          TextStyle(
            color:
            Color(
              0xFF0B2344,
            ),

            fontSize: 19,

            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        serviceCard(
          ServiceCatalog
              .services.last,
        ),

        const SizedBox(
          height: 28,
        ),

        // OUR WORKSHOPS
        const Text(
          'Our Workshops',

          style:
          TextStyle(
            color:
            Color(
              0xFF0B2344,
            ),

            fontSize: 19,

            fontWeight:
            FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 12,
        ),

        InkWell(
          onTap:
          openWorkshops,

          borderRadius:
          BorderRadius.circular(
            18,
          ),

          child: Container(
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

            child:
            const Row(
              children: [
                CircleAvatar(
                  radius: 27,

                  backgroundColor:
                  Color(
                    0xFFEAF1FA,
                  ),

                  child: Icon(
                    Icons
                        .car_repair_rounded,

                    color:
                    Color(
                      0xFF0B2344,
                    ),
                  ),
                ),

                SizedBox(
                  width: 14,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                    children: [
                      Text(
                        'View Workshops',

                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      SizedBox(
                        height: 4,
                      ),

                      Text(
                        'GPS, call and navigation',

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

                Icon(
                  Icons
                      .arrow_forward_ios,

                  size: 16,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(
          height: 25,
        ),
      ],
    );
  }

  Widget serviceCard(
      ServiceModel service,
      ) {
    return InkWell(
      onTap: () {
        openService(
          service,
        );
      },

      borderRadius:
      BorderRadius.circular(
        18,
      ),

      child: Container(
        padding:
        const EdgeInsets.all(
          17,
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

        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,

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

              child: Icon(
                service.icon,

                color:
                const Color(
                  0xFF0B2344,
                ),

                size: 29,
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
                    service.name,

                    style:
                    const TextStyle(
                      fontSize: 16,

                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'From ${service.price}',

                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF2563A6,
                      ),

                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons
                  .arrow_forward_ios,

              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}