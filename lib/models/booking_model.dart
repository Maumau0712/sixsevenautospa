class Booking {
  final int? id;
  final int userId;
  final String vehiclePlate;
  final String serviceName;
  final String workshopName;
  final DateTime date;
  final String time;
  final String status;
  final String problemNote;
  final String problemPhotoUrl;

  Booking({
    this.id,
    required this.userId,
    required this.vehiclePlate,
    required this.serviceName,
    required this.workshopName,
    required this.date,
    required this.time,
    this.status = 'Confirmed',
    this.problemNote = '',
    this.problemPhotoUrl = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'vehicle_plate':
      vehiclePlate,
      'service_name':
      serviceName,
      'workshop_name':
      workshopName,
      'date':
      date.toIso8601String(),
      'time':
      time,
      'status':
      status,
      'problem_note':
      problemNote,
      'problem_photo_url':
      problemPhotoUrl,
    };
  }

  factory Booking.fromMap(
      Map<String, dynamic> map,
      ) {
    DateTime bookingDate;

    try {
      bookingDate =
          DateTime.parse(
            map['date'].toString(),
          );
    } catch (error) {
      bookingDate =
          DateTime.now();
    }

    return Booking(
      id:
      map['id'] as int?,

      userId:
      map['user_id'] as int? ??
          0,

      vehiclePlate:
      map['vehicle_plate']
          ?.toString() ??
          '',

      serviceName:
      map['service_name']
          ?.toString() ??
          '',

      workshopName:
      map['workshop_name']
          ?.toString() ??
          '',

      date:
      bookingDate,

      time:
      map['time']
          ?.toString() ??
          '',

      status:
      map['status']
          ?.toString() ??
          'Confirmed',

      problemNote:
      map['problem_note']
          ?.toString() ??
          '',

      problemPhotoUrl:
      map['problem_photo_url']
          ?.toString() ??
          '',
    );
  }
}