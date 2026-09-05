import '../models/vehicle_model.dart';

class VehicleStore {
  static final List<Vehicle> vehicles = [];

  static void addVehicle(Vehicle vehicle) {
    vehicles.add(vehicle);
  }

  static void removeVehicle(Vehicle vehicle) {
    vehicles.remove(vehicle);
  }

  static List<Vehicle> getVehicles() {
    return vehicles;
  }
}