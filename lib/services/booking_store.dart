import '../models/booking_model.dart';

class BookingStore {
  static final List<Booking> bookings = [];

  static void addBooking(Booking booking) {
    bookings.add(booking);
  }

  static void removeBooking(Booking booking) {
    bookings.remove(booking);
  }

  static List<Booking> getBookings() {
    return bookings;
  }
}