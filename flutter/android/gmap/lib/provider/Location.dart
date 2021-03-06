import 'package:gmap/models/serachLoaction.dart';

import 'package:flutter/material.dart';


class LocationProvider with ChangeNotifier {

  String kGoogleApiKey = "AIzaSyAoaZYHwECCzM7vqcAZYPiQCYhIO2M9RrM";
  // ignore: unused_field
  CustomLocation _curretLocation;
  // ignore: unused_field
  CustomLocation _pickLocation;
  // ignore: unused_field
  CustomLocation _dropLocation;

  void setPickupLocation(CustomLocation pickupLocation) {
    this._pickLocation = pickupLocation;
  }

  void setCurrentLocation(CustomLocation currentLocation) {
    this._curretLocation = currentLocation;
  }

  void setDropLocation(CustomLocation dropLocation) {
    this._dropLocation = dropLocation;
  }

  CustomLocation getDropLocation() {
    return this._dropLocation;
  }

  CustomLocation getCurrentLocation() {
    return this._curretLocation;
  }

  CustomLocation getPickupLocation() {
    return this._pickLocation;
  }
}
