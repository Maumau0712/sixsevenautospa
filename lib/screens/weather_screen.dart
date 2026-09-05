import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({
    super.key,
  });

  @override
  State<WeatherScreen> createState() =>
      _WeatherScreenState();
}

class _WeatherScreenState
    extends State<WeatherScreen> {
  late Future<Map<String, dynamic>>
  weatherData;

  @override
  void initState() {
    super.initState();

    weatherData =
        loadWeather();
  }

  Future<Map<String, dynamic>>
  loadWeather() async {
    bool serviceEnabled =
    await Geolocator
        .isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Please turn on location services.',
      );
    }

    LocationPermission permission =
    await Geolocator
        .checkPermission();

    if (permission ==
        LocationPermission.denied) {
      permission =
      await Geolocator
          .requestPermission();
    }

    if (permission ==
        LocationPermission.denied) {
      throw Exception(
        'Location permission is needed.',
      );
    }

    if (permission ==
        LocationPermission
            .deniedForever) {
      throw Exception(
        'Location permission is permanently denied.',
      );
    }

    Position? position;

    try {
      position =
      await Geolocator
          .getCurrentPosition(
        desiredAccuracy:
        LocationAccuracy.medium,
        timeLimit:
        const Duration(
          seconds: 10,
        ),
      );
    } catch (e) {
      position =
      await Geolocator
          .getLastKnownPosition();
    }

    if (position == null) {
      throw Exception(
        'Unable to get your current location.',
      );
    }

    return await WeatherService
        .getWeather(
      latitude:
      position.latitude,
      longitude:
      position.longitude,
    );
  }

  Future<void>
  refreshWeather() async {
    final newFuture =
    loadWeather();

    setState(() {
      weatherData =
          newFuture;
    });

    await newFuture;
  }

  String weatherDescription(
      int code,
      ) {
    if (code == 0) {
      return 'Sunny';
    }

    if (code == 1) {
      return 'Mainly Clear';
    }

    if (code == 2) {
      return 'Partly Cloudy';
    }

    if (code == 3) {
      return 'Cloudy';
    }

    if (code == 45 ||
        code == 48) {
      return 'Foggy';
    }

    if (code >= 51 &&
        code <= 57) {
      return 'Drizzle';
    }

    if (code >= 61 &&
        code <= 67) {
      return 'Rain';
    }

    if (code >= 71 &&
        code <= 77) {
      return 'Snow';
    }

    if (code >= 80 &&
        code <= 82) {
      return 'Rain Showers';
    }

    if (code >= 85 &&
        code <= 86) {
      return 'Snow Showers';
    }

    if (code >= 95) {
      return 'Thunderstorm';
    }

    return 'Weather';
  }

  IconData weatherIcon(
      int code,
      ) {
    if (code == 0) {
      return Icons.wb_sunny;
    }

    if (code == 1 ||
        code == 2) {
      return Icons
          .wb_cloudy_outlined;
    }

    if (code == 3 ||
        code == 45 ||
        code == 48) {
      return Icons.cloud;
    }

    if (code >= 51 &&
        code <= 67) {
      return Icons.grain;
    }

    if (code >= 80 &&
        code <= 82) {
      return Icons
          .water_drop_outlined;
    }

    if (code >= 95) {
      return Icons
          .thunderstorm_outlined;
    }

    return Icons.cloud;
  }

  String dayName(
      String dateText,
      int index,
      ) {
    if (index == 0) {
      return 'Today';
    }

    final date =
    DateTime.tryParse(
      dateText,
    );

    if (date == null) {
      return dateText;
    }

    const days = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return days[
    date.weekday - 1];
  }

  String hourText(
      String dateTimeText,
      int index,
      ) {
    if (index == 0) {
      return 'Now';
    }

    final date =
    DateTime.tryParse(
      dateTimeText,
    );

    if (date == null) {
      return '';
    }

    int hour = date.hour;

    if (hour == 0) {
      return '12AM';
    }

    if (hour < 12) {
      return '${hour}AM';
    }

    if (hour == 12) {
      return '12PM';
    }

    return '${hour - 12}PM';
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      backgroundColor:
      const Color(
        0xFF4D9FE8,
      ),

      appBar: AppBar(
        backgroundColor:
        Colors.transparent,

        elevation: 0,

        foregroundColor:
        Colors.white,

        title:
        const Text(
          'Weather',
        ),

        actions: [
          IconButton(
            onPressed: () {
              refreshWeather();
            },

            icon:
            const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body:
      RefreshIndicator(
        onRefresh:
        refreshWeather,

        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),

          padding:
          const EdgeInsets.fromLTRB(
            16,
            5,
            16,
            25,
          ),

          children: [
            FutureBuilder<
                Map<String, dynamic>>(
              future:
              weatherData,

              builder:
                  (context, snapshot) {
                if (snapshot
                    .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const SizedBox(
                    height: 500,

                    child: Center(
                      child:
                      CircularProgressIndicator(
                        color:
                        Colors.white,
                      ),
                    ),
                  );
                }

                if (snapshot
                    .hasError) {
                  return buildError(
                    snapshot.error
                        .toString(),
                  );
                }

                if (!snapshot
                    .hasData) {
                  return buildError(
                    'Weather data is not available.',
                  );
                }

                return buildWeather(
                  snapshot.data!,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWeather(
      Map<String, dynamic> data,
      ) {
    final current =
    Map<String, dynamic>.from(
      data['current'] ?? {},
    );

    final hourly =
    Map<String, dynamic>.from(
      data['hourly'] ?? {},
    );

    final daily =
    Map<String, dynamic>.from(
      data['daily'] ?? {},
    );

    double temperature =
        (current[
        'temperature_2m']
        as num?)
            ?.toDouble() ??
            0;

    int weatherCode =
        (current[
        'weather_code']
        as num?)
            ?.toInt() ??
            0;

    int humidity =
        (current[
        'relative_humidity_2m']
        as num?)
            ?.toInt() ??
            0;

    double windSpeed =
        (current[
        'wind_speed_10m']
        as num?)
            ?.toDouble() ??
            0;

    final maxTemps =
    List<dynamic>.from(
      daily[
      'temperature_2m_max'] ??
          [],
    );

    final minTemps =
    List<dynamic>.from(
      daily[
      'temperature_2m_min'] ??
          [],
    );

    int high =
    maxTemps.isNotEmpty
        ? (maxTemps.first
    as num)
        .round()
        : 0;

    int low =
    minTemps.isNotEmpty
        ? (minTemps.first
    as num)
        .round()
        : 0;

    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),

        const Text(
          'MY LOCATION',

          style:
          TextStyle(
            color:
            Colors.white70,

            fontSize: 12,

            fontWeight:
            FontWeight.w600,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        const Text(
          'Current Location',

          style:
          TextStyle(
            color:
            Colors.white,

            fontSize: 28,

            fontWeight:
            FontWeight.w500,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        Text(
          '${temperature.round()}°',

          style:
          const TextStyle(
            color:
            Colors.white,

            fontSize: 82,

            fontWeight:
            FontWeight.w300,

            height: 1,
          ),
        ),

        Text(
          weatherDescription(
            weatherCode,
          ),

          style:
          const TextStyle(
            color:
            Colors.white,

            fontSize: 20,

            fontWeight:
            FontWeight.w500,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          'H:$high°  L:$low°',

          style:
          const TextStyle(
            color:
            Colors.white,

            fontSize: 16,

            fontWeight:
            FontWeight.w500,
          ),
        ),

        const SizedBox(
          height: 28,
        ),

        buildHourlyForecast(
          hourly,
        ),

        const SizedBox(
          height: 14,
        ),

        buildDailyForecast(
          daily,
        ),

        const SizedBox(
          height: 14,
        ),

        buildExtraInfo(
          humidity,
          windSpeed,
          daily,
        ),

        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget buildHourlyForecast(
      Map<String, dynamic> hourly,
      ) {
    final times =
    List<dynamic>.from(
      hourly['time'] ?? [],
    );

    final temperatures =
    List<dynamic>.from(
      hourly[
      'temperature_2m'] ??
          [],
    );

    final codes =
    List<dynamic>.from(
      hourly[
      'weather_code'] ??
          [],
    );

    final rainChance =
    List<dynamic>.from(
      hourly[
      'precipitation_probability'] ??
          [],
    );

    int currentHour =
        DateTime.now().hour;

    int startIndex = 0;

    for (int i = 0;
    i < times.length;
    i++) {
      final time =
      DateTime.tryParse(
        times[i].toString(),
      );

      if (time != null &&
          time.hour >=
              currentHour) {
        startIndex = i;
        break;
      }
    }

    int count = 6;

    if (startIndex + count >
        times.length) {
      count =
          times.length -
              startIndex;
    }

    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        14,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white
            .withOpacity(
          0.15,
        ),

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border:
        Border.all(
          color:
          Colors.white
              .withOpacity(
            0.15,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [
          const Row(
            children: [
              Icon(
                Icons
                    .schedule_outlined,

                color:
                Colors.white70,

                size: 17,
              ),

              SizedBox(
                width: 6,
              ),

              Text(
                'HOURLY FORECAST',

                style:
                TextStyle(
                  color:
                  Colors.white70,

                  fontSize: 12,

                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),

          const Divider(
            color:
            Colors.white24,
          ),

          SizedBox(
            height: 120,

            child:
            ListView.separated(
              scrollDirection:
              Axis.horizontal,

              itemCount:
              count,

              separatorBuilder:
                  (context, index) =>
              const SizedBox(
                width: 22,
              ),

              itemBuilder:
                  (context, index) {
                int i =
                    startIndex +
                        index;

                int code =
                (codes[i]
                as num)
                    .toInt();

                int temp =
                (temperatures[i]
                as num)
                    .round();

                int rain =
                    (rainChance[i]
                    as num?)
                        ?.round() ??
                        0;

                return SizedBox(
                  width: 48,

                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                    children: [
                      Text(
                        hourText(
                          times[i]
                              .toString(),
                          index,
                        ),

                        style:
                        const TextStyle(
                          color:
                          Colors.white,

                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),

                      Icon(
                        weatherIcon(
                          code,
                        ),

                        color:
                        Colors.white,

                        size: 25,
                      ),

                      if (rain > 0)
                        Text(
                          '$rain%',

                          style:
                          const TextStyle(
                            color:
                            Color(
                              0xFF7ED8FF,
                            ),

                            fontSize: 11,

                            fontWeight:
                            FontWeight.w600,
                          ),
                        )
                      else
                        const SizedBox(
                          height: 14,
                        ),

                      Text(
                        '$temp°',

                        style:
                        const TextStyle(
                          color:
                          Colors.white,

                          fontSize: 18,

                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDailyForecast(
      Map<String, dynamic> daily,
      ) {
    final dates =
    List<dynamic>.from(
      daily['time'] ?? [],
    );

    final codes =
    List<dynamic>.from(
      daily[
      'weather_code'] ??
          [],
    );

    final maxTemps =
    List<dynamic>.from(
      daily[
      'temperature_2m_max'] ??
          [],
    );

    final minTemps =
    List<dynamic>.from(
      daily[
      'temperature_2m_min'] ??
          [],
    );

    int count =
        dates.length;

    if (count > 5) {
      count = 5;
    }

    return Container(
      width:
      double.infinity,

      padding:
      const EdgeInsets.all(
        14,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white
            .withOpacity(
          0.15,
        ),

        borderRadius:
        BorderRadius.circular(
          18,
        ),

        border:
        Border.all(
          color:
          Colors.white
              .withOpacity(
            0.15,
          ),
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment
            .start,

        children: [
          const Row(
            children: [
              Icon(
                Icons
                    .calendar_month_outlined,

                color:
                Colors.white70,

                size: 17,
              ),

              SizedBox(
                width: 6,
              ),

              Text(
                '5-DAY FORECAST',

                style:
                TextStyle(
                  color:
                  Colors.white70,

                  fontSize: 12,

                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),

          const Divider(
            color:
            Colors.white24,
          ),

          ...List.generate(
            count,
                (index) {
              int code =
              (codes[index]
              as num)
                  .toInt();

              int max =
              (maxTemps[index]
              as num)
                  .round();

              int min =
              (minTemps[index]
              as num)
                  .round();

              return Column(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      vertical: 10,
                    ),

                    child: Row(
                      children: [
                        SizedBox(
                          width: 65,

                          child: Text(
                            dayName(
                              dates[index]
                                  .toString(),
                              index,
                            ),

                            style:
                            const TextStyle(
                              color:
                              Colors.white,

                              fontSize: 17,

                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ),

                        Icon(
                          weatherIcon(
                            code,
                          ),

                          color:
                          Colors.white,

                          size: 26,
                        ),

                        const Spacer(),

                        Text(
                          '$min°',

                          style:
                          const TextStyle(
                            color:
                            Colors.white60,

                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        Container(
                          width: 85,
                          height: 5,

                          decoration:
                          BoxDecoration(
                            borderRadius:
                            BorderRadius
                                .circular(
                              10,
                            ),

                            gradient:
                            const LinearGradient(
                              colors: [
                                Color(
                                  0xFF7DD3FC,
                                ),
                                Color(
                                  0xFFFFC857,
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 16,
                        ),

                        SizedBox(
                          width: 35,

                          child: Text(
                            '$max°',

                            textAlign:
                            TextAlign.end,

                            style:
                            const TextStyle(
                              color:
                              Colors.white,

                              fontSize: 17,

                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (index !=
                      count - 1)
                    const Divider(
                      height: 1,

                      color:
                      Colors.white24,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildExtraInfo(
      int humidity,
      double windSpeed,
      Map<String, dynamic> daily,
      ) {
    final rainChance =
    List<dynamic>.from(
      daily[
      'precipitation_probability_max'] ??
          [],
    );

    int rain =
    rainChance.isNotEmpty
        ? (rainChance.first
    as num?)
        ?.round() ??
        0
        : 0;

    return Row(
      children: [
        Expanded(
          child: infoBox(
            Icons
                .water_drop_outlined,
            'RAIN CHANCE',
            '$rain%',
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: infoBox(
            Icons.opacity,
            'HUMIDITY',
            '$humidity%',
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: infoBox(
            Icons.air,
            'WIND',
            '${windSpeed.toStringAsFixed(0)} km/h',
          ),
        ),
      ],
    );
  }

  Widget infoBox(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      padding:
      const EdgeInsets.all(
        12,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white
            .withOpacity(
          0.15,
        ),

        borderRadius:
        BorderRadius.circular(
          16,
        ),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                icon,

                size: 15,

                color:
                Colors.white70,
              ),

              const SizedBox(
                width: 4,
              ),

              Expanded(
                child: Text(
                  title,

                  style:
                  const TextStyle(
                    color:
                    Colors.white70,

                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            value,

            style:
            const TextStyle(
              color:
              Colors.white,

              fontSize: 19,

              fontWeight:
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildError(
      String error,
      ) {
    String message =
    error.replaceFirst(
      'Exception: ',
      '',
    );

    return Container(
      margin:
      const EdgeInsets.only(
        top: 100,
      ),

      padding:
      const EdgeInsets.all(
        22,
      ),

      decoration:
      BoxDecoration(
        color:
        Colors.white,

        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons
                .cloud_off_outlined,

            size: 55,

            color:
            Color(
              0xFF0B2344,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          const Text(
            'Unable to Show Weather',

            style:
            TextStyle(
              fontSize: 18,

              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Text(
            message,

            textAlign:
            TextAlign.center,
          ),

          const SizedBox(
            height: 18,
          ),

          ElevatedButton.icon(
            onPressed: () {
              refreshWeather();
            },

            icon:
            const Icon(
              Icons.refresh,
            ),

            label:
            const Text(
              'Try Again',
            ),
          ),
        ],
      ),
    );
  }
}