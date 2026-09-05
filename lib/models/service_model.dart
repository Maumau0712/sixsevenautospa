import 'package:flutter/material.dart';

class ServiceModel {
  final String name;
  final String shortName;
  final String description;
  final String price;
  final String duration;
  final IconData icon;
  final List<String> included;

  const ServiceModel({
    required this.name,
    required this.shortName,
    required this.description,
    required this.price,
    required this.duration,
    required this.icon,
    required this.included,
  });
}

class ServiceCatalog {
  static const List<ServiceModel> services = [
    ServiceModel(
      name: 'Car Maintenance',
      shortName: 'Service',
      description:
      'General vehicle inspection and basic maintenance.',
      price: 'RM 99',
      duration: '1 - 2 hours',
      icon: Icons.build_rounded,
      included: [
        'Basic vehicle inspection',
        'Fluid level checking',
        'Brake inspection',
        'Battery checking',
        'Tyre condition checking',
      ],
    ),

    ServiceModel(
      name: 'Car Wash',
      shortName: 'Car Wash',
      description:
      'Exterior and interior vehicle cleaning.',
      price: 'RM 25',
      duration: '30 - 45 minutes',
      icon: Icons.local_car_wash_rounded,
      included: [
        'Exterior wash',
        'Interior cleaning',
        'Wheel cleaning',
        'Vehicle drying',
      ],
    ),

    ServiceModel(
      name: 'Tyre Service',
      shortName: 'Tyres',
      description:
      'Tyre replacement, balancing and alignment.',
      price: 'RM 80',
      duration: '45 - 60 minutes',
      icon: Icons.tire_repair_rounded,
      included: [
        'Tyre condition inspection',
        'Tyre pressure inspection',
        'Wheel balancing inspection',
        'Basic tyre advice',
      ],
    ),

    ServiceModel(
      name: 'Battery Service',
      shortName: 'Battery',
      description:
      'Battery inspection and replacement.',
      price: 'RM 150',
      duration: '30 - 45 minutes',
      icon: Icons.battery_charging_full_rounded,
      included: [
        'Battery health inspection',
        'Charging system inspection',
        'Battery terminal inspection',
        'Replacement recommendation',
      ],
    ),

    ServiceModel(
      name: 'Window Tint',
      shortName: 'Tint',
      description:
      'Professional automotive window tinting.',
      price: 'RM 199',
      duration: '2 - 3 hours',
      icon: Icons.wb_sunny_outlined,
      included: [
        'Tint consultation',
        'Window preparation',
        'Professional installation',
        'Installation inspection',
      ],
    ),

    ServiceModel(
      name: 'Engine Oil Service',
      shortName: 'Engine Oil',
      description:
      'Professional engine oil replacement and basic engine inspection.',
      price: 'RM 99',
      duration: '45 - 60 minutes',
      icon: Icons.oil_barrel_rounded,
      included: [
        'Engine oil replacement',
        'Oil filter checking',
        'Fluid level checking',
        'Basic engine inspection',
      ],
    ),
  ];

  static ServiceModel? findService(
      String? serviceName,
      ) {
    if (serviceName == null) {
      return null;
    }

    for (ServiceModel service in services) {
      if (service.name == serviceName) {
        return service;
      }
    }

    return null;
  }
}