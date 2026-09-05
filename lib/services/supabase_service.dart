import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../models/vehicle_model.dart';

class SupabaseService {
  static final SupabaseService instance =
  SupabaseService._internal();

  SupabaseService._internal();

  final SupabaseClient supabase =
      Supabase.instance.client;

  Future<AuthResponse> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'name': name,
        'phone': phone,
      },
    );
  }

  Future<AuthResponse> loginUser(
      String email,
      String password,
      ) async {
    return await supabase.auth
        .signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  Future<void> sendPasswordReset(
      String email,
      ) async {
    String redirectUrl;

    if (kIsWeb) {
      redirectUrl =
          Uri.base.origin;
    } else {
      redirectUrl =
      'com.example.sixsevenautospa://reset-password';
    }

    await supabase.auth
        .resetPasswordForEmail(
      email,
      redirectTo:
      redirectUrl,
    );
  }

  Future<UserModel?> getProfileByEmail(
      String email,
      ) async {
    final result =
    await supabase
        .from('users')
        .select()
        .eq(
      'email',
      email,
    )
        .maybeSingle();

    if (result == null) {
      return null;
    }

    return UserModel.fromMap(
      result,
    );
  }

  Future<UserModel> createProfile()
  async {
    final authUser =
        supabase.auth.currentUser;

    if (authUser == null) {
      throw Exception(
        'No logged in user.',
      );
    }

    String email =
        authUser.email ?? '';

    String name =
        authUser
            .userMetadata?['name']
            ?.toString() ??
            'User';

    String phone =
        authUser
            .userMetadata?['phone']
            ?.toString() ??
            '';

    final result =
    await supabase
        .from('users')
        .insert({
      'name': name,
      'email': email,
      'phone': phone,
      'password': '',
    })
        .select()
        .single();

    return UserModel.fromMap(
      result,
    );
  }

  Future<UserModel>
  createOrGetProfile() async {
    final authUser =
        supabase.auth.currentUser;

    if (authUser == null) {
      throw Exception(
        'No logged in user.',
      );
    }

    String email =
        authUser.email ?? '';

    UserModel? user =
    await getProfileByEmail(
      email,
    );

    if (user != null) {
      return user;
    }

    return await createProfile();
  }

  Future<UserModel?> getUserById(
      int id,
      ) async {
    final result =
    await supabase
        .from('users')
        .select()
        .eq(
      'id',
      id,
    )
        .maybeSingle();

    if (result == null) {
      return null;
    }

    return UserModel.fromMap(
      result,
    );
  }

  Future<void> updateUser(
      UserModel user,
      ) async {
    if (user.id == null) {
      return;
    }

    await supabase
        .from('users')
        .update({
      'name':
      user.name,
      'phone':
      user.phone,
    })
        .eq(
      'id',
      user.id!,
    );

    await supabase.auth.updateUser(
      UserAttributes(
        data: {
          'name':
          user.name,
          'phone':
          user.phone,
        },
      ),
    );
  }

  Future<Vehicle> addVehicle(
      Vehicle vehicle,
      ) async {
    final result =
    await supabase
        .from('vehicles')
        .insert({
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
    })
        .select()
        .single();

    return Vehicle.fromMap(
      result,
    );
  }

  Future<List<Vehicle>> getVehicles(
      int userId,
      ) async {
    final result =
    await supabase
        .from('vehicles')
        .select()
        .eq(
      'user_id',
      userId,
    )
        .order(
      'id',
      ascending: false,
    );

    return result
        .map(
          (data) =>
          Vehicle.fromMap(
            data,
          ),
    )
        .toList();
  }

  Future<void> deleteVehicle(
      int id,
      ) async {
    await supabase
        .from('vehicles')
        .delete()
        .eq(
      'id',
      id,
    );
  }

  Future<String> uploadBookingPhoto(
      XFile image,
      int userId,
      ) async {
    String extension =
    image.name
        .split('.')
        .last
        .toLowerCase();

    String fileName =
        '${userId}_${DateTime.now().millisecondsSinceEpoch}.$extension';

    String storagePath =
        'user_$userId/$fileName';

    if (kIsWeb) {
      Uint8List bytes =
      await image.readAsBytes();

      await supabase.storage
          .from(
        'booking_photos',
      )
          .uploadBinary(
        storagePath,
        bytes,
        fileOptions:
        const FileOptions(
          upsert: false,
        ),
      );
    } else {
      File imageFile =
      File(
        image.path,
      );

      await supabase.storage
          .from(
        'booking_photos',
      )
          .upload(
        storagePath,
        imageFile,
        fileOptions:
        const FileOptions(
          upsert: false,
        ),
      );
    }

    String imageUrl =
    supabase.storage
        .from(
      'booking_photos',
    )
        .getPublicUrl(
      storagePath,
    );

    return imageUrl;
  }

  Future<Booking> addBooking(
      Booking booking,
      ) async {
    final result =
    await supabase
        .from('bookings')
        .insert({
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
    })
        .select()
        .single();

    return Booking.fromMap(
      result,
    );
  }

  Future<List<Booking>> getBookings(
      int userId,
      ) async {
    final result =
    await supabase
        .from('bookings')
        .select()
        .eq(
      'user_id',
      userId,
    )
        .order(
      'date',
      ascending: false,
    );

    return result
        .map(
          (data) =>
          Booking.fromMap(
            data,
          ),
    )
        .toList();
  }

  Future<List<String>> getBookedTimes(
      String workshop,
      DateTime date,
      ) async {
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

    final result =
    await supabase
        .from('bookings')
        .select('time')
        .eq(
      'workshop_name',
      workshop,
    )
        .gte(
      'date',
      startDate
          .toIso8601String(),
    )
        .lt(
      'date',
      endDate
          .toIso8601String(),
    )
        .neq(
      'status',
      'Cancelled',
    );

    return result
        .map(
          (data) =>
          data['time']
              .toString(),
    )
        .toList();
  }

  Future<void> updateBookingStatus(
      int id,
      String status,
      ) async {
    await supabase
        .from('bookings')
        .update({
      'status':
      status,
    })
        .eq(
      'id',
      id,
    );
  }
}