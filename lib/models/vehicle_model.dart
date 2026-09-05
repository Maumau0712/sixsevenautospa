class Vehicle {
  final int? id;
  final int userId;
  final String plateNumber;
  final String brand;
  final String model;
  final String year;

  Vehicle({
    this.id,
    required this.userId,
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.year,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'plate_number': plateNumber,
      'brand': brand,
      'model': model,
      'year': year,
    };
  }

  factory Vehicle.fromMap(
      Map<String, dynamic> map,
      ) {
    return Vehicle(
      id: map['id'] as int?,
      userId: map['user_id'] as int? ?? 0,
      plateNumber:
      map['plate_number']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      model: map['model']?.toString() ?? '',
      year: map['year']?.toString() ?? '',
    );
  }
}