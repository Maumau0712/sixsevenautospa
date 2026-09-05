import 'package:flutter/material.dart';

import '../models/service_model.dart';

class ServiceDetailScreen
    extends StatelessWidget {

  final ServiceModel service;

  final Function(String)
  onBookService;

  const ServiceDetailScreen({
    super.key,
    required this.service,
    required this.onBookService,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    const navy =
    Color(0xFF0B2344);

    return Scaffold(
      backgroundColor:
      const Color(
        0xFFF3F6FA,
      ),

      appBar: AppBar(
        title:
        const Text(
          'Service Details',
        ),
      ),

      bottomNavigationBar:
      SafeArea(
        child: Padding(
          padding:
          const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            15,
          ),

          child: ElevatedButton.icon(
            onPressed: () {

              onBookService(
                service.name,
              );

              Navigator.pop(
                context,
              );
            },

            icon:
            const Icon(
              Icons
                  .calendar_month_rounded,
            ),

            label:
            const Text(
              'Book This Service',
            ),
          ),
        ),
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
          CrossAxisAlignment
              .start,

          children: [
            Container(
              width:
              double.infinity,

              padding:
              const EdgeInsets.all(
                24,
              ),

              decoration:
              BoxDecoration(
                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(
                  22,
                ),

                border:
                Border.all(
                  color:
                  const Color(
                    0xFFE6EAF0,
                  ),
                ),
              ),

              child: Column(
                children: [
                  Container(
                    width: 95,
                    height: 95,

                    decoration:
                    const BoxDecoration(
                      color:
                      Color(
                        0xFFEAF1FA,
                      ),

                      shape:
                      BoxShape.circle,
                    ),

                    child: Icon(
                      service.icon,

                      size: 45,

                      color:
                      navy,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    service.name,

                    textAlign:
                    TextAlign.center,

                    style:
                    const TextStyle(
                      color:
                      navy,

                      fontSize: 25,

                      fontWeight:
                      FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    service.description,

                    textAlign:
                    TextAlign.center,

                    style:
                    const TextStyle(
                      color:
                      Color(
                        0xFF7B8494,
                      ),

                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),

                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFEAF1FA,
                      ),

                      borderRadius:
                      BorderRadius.circular(
                        25,
                      ),
                    ),

                    child: Text(
                      'From ${service.price}',

                      style:
                      const TextStyle(
                        color:
                        Color(
                          0xFF2563A6,
                        ),

                        fontWeight:
                        FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 22,
            ),

            Container(
              padding:
              const EdgeInsets.all(
                16,
              ),

              decoration:
              BoxDecoration(
                color:
                Colors.white,

                borderRadius:
                BorderRadius.circular(
                  16,
                ),
              ),

              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,

                    color:
                    navy,
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  const Text(
                    'Estimated Duration',

                    style:
                    TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    service.duration,

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

            const SizedBox(
              height: 24,
            ),

            const Text(
              "What's Included",

              style:
              TextStyle(
                color:
                navy,

                fontSize: 19,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            Container(
              padding:
              const EdgeInsets.all(
                16,
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
                children:
                service.included.map(
                      (item) {

                    return Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 13,
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons
                                .check_circle_rounded,

                            color:
                            Colors.green,

                            size: 20,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child: Text(
                              item,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Container(
              padding:
              const EdgeInsets.all(
                16,
              ),

              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFFFF8E8,
                ),

                borderRadius:
                BorderRadius.circular(
                  16,
                ),
              ),

              child:
              const Row(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [
                  Icon(
                    Icons
                        .info_outline_rounded,

                    color:
                    Colors.orange,
                  ),

                  SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: Text(
                      'Final price may vary depending on the vehicle condition and required parts.',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}