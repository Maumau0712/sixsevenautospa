import 'package:flutter/material.dart';

import '../models/service_model.dart';
import 'service_detail_screen.dart';

class ServicesScreen
    extends StatelessWidget {

  final Function(String)
  onBookService;

  const ServicesScreen({
    super.key,
    required this.onBookService,
  });

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
          'Services',
        ),
      ),

      body: ListView(
        padding:
        const EdgeInsets.fromLTRB(
          16,
          5,
          16,
          30,
        ),

        children: [
          const Text(
            'Car Care Services',

            style:
            TextStyle(
              color:
              Color(
                0xFF0B2344,
              ),

              fontSize: 25,

              fontWeight:
              FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'Choose the service your vehicle needs.',

            style:
            TextStyle(
              color:
              Color(
                0xFF7B8494,
              ),

              fontSize: 14,
            ),
          ),

          const SizedBox(
            height: 22,
          ),

          ...ServiceCatalog.services.map(
                (service) {

              return Padding(
                padding:
                const EdgeInsets.only(
                  bottom: 12,
                ),

                child: Material(
                  color:
                  Colors.white,

                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),

                  child: InkWell(
                    borderRadius:
                    BorderRadius.circular(
                      18,
                    ),

                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder:
                              (context) =>
                              ServiceDetailScreen(
                                service:
                                service,

                                onBookService:
                                onBookService,
                              ),
                        ),
                      );
                    },

                    child: Container(
                      padding:
                      const EdgeInsets.all(
                        16,
                      ),

                      decoration:
                      BoxDecoration(
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
                      Row(
                        children: [
                          Container(
                            width: 62,
                            height: 62,

                            decoration:
                            BoxDecoration(
                              color:
                              const Color(
                                0xFFE8F0FA,
                              ),

                              borderRadius:
                              BorderRadius.circular(
                                16,
                              ),
                            ),

                            child: Icon(
                              service.icon,

                              color:
                              const Color(
                                0xFF0B2344,
                              ),

                              size: 30,
                            ),
                          ),

                          const SizedBox(
                            width: 15,
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
                                    color:
                                    Color(
                                      0xFF1D2939,
                                    ),

                                    fontSize: 17,

                                    fontWeight:
                                    FontWeight
                                        .w700,
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),

                                Text(
                                  service.description,

                                  maxLines: 2,

                                  overflow:
                                  TextOverflow
                                      .ellipsis,

                                  style:
                                  const TextStyle(
                                    color:
                                    Color(
                                      0xFF7B8494,
                                    ),

                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
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
                                    FontWeight
                                        .w700,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons
                                .arrow_forward_ios_rounded,

                            size: 17,

                            color:
                            Color(
                              0xFF98A2B3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}