import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';

class LocalDatabase {
  static final LocalDatabase instance =
  LocalDatabase._internal();

  LocalDatabase._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    await initDatabase();

    return _database!;
  }

  Future<void> initDatabase() async {
    if (_database != null) {
      return;
    }

    String databasePath =
    await getDatabasesPath();

    String path = join(
      databasePath,
      '67autospa.db',
    );

    _database = await openDatabase(
      path,
      version: 2,
      onCreate: createTables,
      onUpgrade: upgradeDatabase,
    );
  }

  Future<void> createTables(
      Database db,
      int version,
      ) async {
    await db.execute(
      '''
      CREATE TABLE local_users(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE local_vehicles(
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        plate_number TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        year TEXT NOT NULL
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE local_bookings(
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        vehicle_plate TEXT NOT NULL,
        service_name TEXT NOT NULL,
        workshop_name TEXT NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        status TEXT NOT NULL,
        problem_note TEXT NOT NULL DEFAULT '',
        problem_photo_url TEXT NOT NULL DEFAULT ''
      )
      ''',
    );
  }

  Future<void> upgradeDatabase(
      Database db,
      int oldVersion,
      int newVersion,
      ) async {
    if (oldVersion < 2) {
      await db.execute(
        '''
        ALTER TABLE local_bookings
        ADD COLUMN problem_note TEXT NOT NULL DEFAULT ''
        ''',
      );

      await db.execute(
        '''
        ALTER TABLE local_bookings
        ADD COLUMN problem_photo_url TEXT NOT NULL DEFAULT ''
        ''',
      );
    }
  }

  Future<void> saveUser(
      UserModel user,
      ) async {
    if (user.id == null) {
      return;
    }

    final db = await database;

    await db.insert(
      'local_users',
      {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
      },
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<UserModel?> getUser(
      int userId,
      ) async {
    final db = await database;

    final result = await db.query(
      'local_users',
      where: 'id = ?',
      whereArgs: [
        userId,
      ],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return UserModel.fromMap(
      result.first,
    );
  }

  Future<UserModel?> getUserByEmail(
      String email,
      ) async {
    final db = await database;

    final result = await db.query(
      'local_users',
      where: 'email = ?',
      whereArgs: [
        email,
      ],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return UserModel.fromMap(
      result.first,
    );
  }

  Future<void> updateUser(
      UserModel user,
      ) async {
    if (user.id == null) {
      return;
    }

    final db = await database;

    await db.update(
      'local_users',
      {
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
      },
      where: 'id = ?',
      whereArgs: [
        user.id,
      ],
    );
  }

  Future<void> saveVehicle(
      Vehicle vehicle,
      ) async {
    if (vehicle.id == null) {
      return;
    }

    final db = await database;

    await db.insert(
      'local_vehicles',
      {
        'id': vehicle.id,
        'user_id': vehicle.userId,
        'plate_number':
        vehicle.plateNumber,
        'brand': vehicle.brand,
        'model': vehicle.model,
        'year': vehicle.year,
      },
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<void> saveVehicles(
      List<Vehicle> vehicles,
      int userId,
      ) async {
    final db = await database;

    await db.transaction(
          (transaction) async {
        await transaction.delete(
          'local_vehicles',
          where: 'user_id = ?',
          whereArgs: [
            userId,
          ],
        );

        for (Vehicle vehicle
        in vehicles) {
          if (vehicle.id == null) {
            continue;
          }

          await transaction.insert(
            'local_vehicles',
            {
              'id': vehicle.id,
              'user_id':
              vehicle.userId,
              'plate_number':
              vehicle.plateNumber,
              'brand':
              vehicle.brand,
              'model':
              vehicle.model,
              'year':
              vehicle.year,
            },
            conflictAlgorithm:
            ConflictAlgorithm
                .replace,
          );
        }
      },
    );
  }

  Future<List<Vehicle>> getVehicles(
      int userId,
      ) async {
    final db = await database;

    final result = await db.query(
      'local_vehicles',
      where: 'user_id = ?',
      whereArgs: [
        userId,
      ],
      orderBy: 'id DESC',
    );

    return result.map(
          (data) {
        return Vehicle.fromMap(
          data,
        );
      },
    ).toList();
  }

  Future<void> deleteVehicle(
      int vehicleId,
      ) async {
    final db = await database;

    await db.delete(
      'local_vehicles',
      where: 'id = ?',
      whereArgs: [
        vehicleId,
      ],
    );
  }

  Future<void> saveBooking(
      Booking booking,
      ) async {
    if (booking.id == null) {
      return;
    }

    final db = await database;

    await db.insert(
      'local_bookings',
      {
        'id': booking.id,
        'user_id':
        booking.userId,
        'vehicle_plate':
        booking.vehiclePlate,
        'service_name':
        booking.serviceName,
        'workshop_name':
        booking.workshopName,
        'date':
        booking.date
            .toIso8601String(),
        'time':
        booking.time,
        'status':
        booking.status,
        'problem_note':
        booking.problemNote,
        'problem_photo_url':
        booking.problemPhotoUrl,
      },
      conflictAlgorithm:
      ConflictAlgorithm.replace,
    );
  }

  Future<void> saveBookings(
      List<Booking> bookings,
      int userId,
      ) async {
    final db = await database;

    await db.transaction(
          (transaction) async {
        await transaction.delete(
          'local_bookings',
          where: 'user_id = ?',
          whereArgs: [
            userId,
          ],
        );

        for (Booking booking
        in bookings) {
          if (booking.id == null) {
            continue;
          }

          await transaction.insert(
            'local_bookings',
            {
              'id':
              booking.id,

              'user_id':
              booking.userId,

              'vehicle_plate':
              booking.vehiclePlate,

              'service_name':
              booking.serviceName,

              'workshop_name':
              booking.workshopName,

              'date':
              booking.date
                  .toIso8601String(),

              'time':
              booking.time,

              'status':
              booking.status,

              'problem_note':
              booking.problemNote,

              'problem_photo_url':
              booking
                  .problemPhotoUrl,
            },
            conflictAlgorithm:
            ConflictAlgorithm
                .replace,
          );
        }
      },
    );
  }

  Future<List<Booking>> getBookings(
      int userId,
      ) async {
    final db = await database;

    final result = await db.query(
      'local_bookings',
      where: 'user_id = ?',
      whereArgs: [
        userId,
      ],
      orderBy: 'date DESC',
    );

    return result.map(
          (data) {
        return Booking.fromMap(
          data,
        );
      },
    ).toList();
  }

  Future<List<String>>
  getBookedTimes(
      String workshop,
      DateTime date,
      ) async {
    final db = await database;

    DateTime startDate =
    DateTime(
      date.year,
      date.month,
      date.day,
    );

    DateTime endDate =
    startDate.add(
      const Duration(
        days: 1,
      ),
    );

    final result = await db.query(
      'local_bookings',
      columns: [
        'time',
      ],
      where:
      'workshop_name = ? AND date >= ? AND date < ? AND status != ?',
      whereArgs: [
        workshop,
        startDate.toIso8601String(),
        endDate.toIso8601String(),
        'Cancelled',
      ],
    );

    return result.map(
          (data) {
        return data['time']
            .toString();
      },
    ).toList();
  }

  Future<void>
  updateBookingStatus(
      int bookingId,
      String status,
      ) async {
    final db = await database;

    await db.update(
      'local_bookings',
      {
        'status': status,
      },
      where: 'id = ?',
      whereArgs: [
        bookingId,
      ],
    );
  }

  Future<void> deleteBooking(
      int bookingId,
      ) async {
    final db = await database;

    await db.delete(
      'local_bookings',
      where: 'id = ?',
      whereArgs: [
        bookingId,
      ],
    );
  }

  Future<void> clearUserData(
      int userId,
      ) async {
    final db = await database;

    await db.delete(
      'local_bookings',
      where: 'user_id = ?',
      whereArgs: [
        userId,
      ],
    );

    await db.delete(
      'local_vehicles',
      where: 'user_id = ?',
      whereArgs: [
        userId,
      ],
    );

    await db.delete(
      'local_users',
      where: 'id = ?',
      whereArgs: [
        userId,
      ],
    );
  }

  Future<void> clearAllData() async {
    final db = await database;

    await db.delete(
      'local_bookings',
    );

    await db.delete(
      'local_vehicles',
    );

    await db.delete(
      'local_users',
    );
  }
}