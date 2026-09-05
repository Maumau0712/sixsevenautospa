import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';
import 'local_database.dart';
import 'supabase_service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance =
  DatabaseHelper._internal();

  DatabaseHelper._internal();

  final SupabaseService online =
      SupabaseService.instance;

  final LocalDatabase local =
      LocalDatabase.instance;

  Future<AuthResponse> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    return await online.registerUser(
      name: name,
      email: email,
      phone: phone,
      password: password,
    );
  }

  Future<UserModel?> loginUser(
      String email,
      String password,
      ) async {
    await online.loginUser(
      email,
      password,
    );

    UserModel user =
    await online.createOrGetProfile();

    if (!kIsWeb) {
      await local.saveUser(
        user,
      );

      if (user.id != null) {
        await syncUserData(
          user.id!,
        );
      }
    }

    return user;
  }

  Future<UserModel?> createOrGetProfile() async {
    final authUser =
        Supabase.instance.client.auth.currentUser;

    if (authUser == null) {
      return null;
    }

    try {
      UserModel user =
      await online.createOrGetProfile();

      if (!kIsWeb) {
        await local.saveUser(
          user,
        );

        if (user.id != null) {
          await syncUserData(
            user.id!,
          );
        }
      }

      return user;
    } catch (error) {
      debugPrint(
        'Profile error: $error',
      );

      if (kIsWeb) {
        return null;
      }

      String email =
          authUser.email ?? '';

      return await local.getUserByEmail(
        email,
      );
    }
  }

  Future<void> syncUserData(
      int userId,
      ) async {
    if (kIsWeb) {
      return;
    }

    try {
      List<Vehicle> vehicles =
      await online.getVehicles(
        userId,
      );

      await local.saveVehicles(
        vehicles,
        userId,
      );
    } catch (error) {
      debugPrint(
        'Vehicle sync error: $error',
      );
    }

    try {
      List<Booking> bookings =
      await online.getBookings(
        userId,
      );

      await local.saveBookings(
        bookings,
        userId,
      );
    } catch (error) {
      debugPrint(
        'Booking sync error: $error',
      );
    }
  }

  Future<void> sendPasswordReset(
      String email,
      ) async {
    await online.sendPasswordReset(
      email,
    );
  }

  Future<void> logout() async {
    await online.logout();
  }

  Future<UserModel?> getUserById(
      int id,
      ) async {
    try {
      UserModel? user =
      await online.getUserById(
        id,
      );

      if (user != null &&
          !kIsWeb) {
        await local.saveUser(
          user,
        );
      }

      return user;
    } catch (error) {
      debugPrint(
        'Get profile error: $error',
      );

      if (kIsWeb) {
        return null;
      }

      return await local.getUser(
        id,
      );
    }
  }

  Future<int> updateUser(
      UserModel user,
      ) async {
    if (user.id == null) {
      return 0;
    }

    await online.updateUser(
      user,
    );

    if (!kIsWeb) {
      await local.saveUser(
        user,
      );
    }

    return 1;
  }

  Future<int> addVehicle(
      Vehicle vehicle,
      ) async {
    Vehicle savedVehicle =
    await online.addVehicle(
      vehicle,
    );

    if (!kIsWeb) {
      await local.saveVehicle(
        savedVehicle,
      );
    }

    return savedVehicle.id ?? 0;
  }

  Future<List<Vehicle>> getVehicles(
      int userId,
      ) async {
    try {
      List<Vehicle> vehicles =
      await online.getVehicles(
        userId,
      );

      if (!kIsWeb) {
        await local.saveVehicles(
          vehicles,
          userId,
        );
      }

      return vehicles;
    } catch (error) {
      debugPrint(
        'Get vehicles error: $error',
      );

      if (kIsWeb) {
        return [];
      }

      return await local.getVehicles(
        userId,
      );
    }
  }

  Future<int> deleteVehicle(
      int id,
      ) async {
    await online.deleteVehicle(
      id,
    );

    if (!kIsWeb) {
      await local.deleteVehicle(
        id,
      );
    }

    return 1;
  }

  Future<int> addBooking(
      Booking booking,
      ) async {
    Booking savedBooking =
    await online.addBooking(
      booking,
    );

    if (!kIsWeb) {
      await local.saveBooking(
        savedBooking,
      );
    }

    return savedBooking.id ?? 0;
  }

  Future<List<Booking>> getBookings(
      int userId,
      ) async {
    try {
      List<Booking> bookings =
      await online.getBookings(
        userId,
      );

      if (!kIsWeb) {
        await local.saveBookings(
          bookings,
          userId,
        );
      }

      return bookings;
    } catch (error) {
      debugPrint(
        'Get bookings error: $error',
      );

      if (kIsWeb) {
        return [];
      }

      return await local.getBookings(
        userId,
      );
    }
  }

  Future<List<String>> getBookedTimes(
      String workshop,
      DateTime date,
      ) async {
    return await online.getBookedTimes(
      workshop,
      date,
    );
  }

  Future<int> updateBookingStatus(
      int id,
      String status,
      ) async {
    await online.updateBookingStatus(
      id,
      status,
    );

    if (!kIsWeb) {
      await local.updateBookingStatus(
        id,
        status,
      );
    }

    return 1;
  }

  Future<String> uploadBookingPhoto(
      XFile image,
      int userId,
      ) async {
    return await online.uploadBookingPhoto(
      image,
      userId,
    );
  }
}