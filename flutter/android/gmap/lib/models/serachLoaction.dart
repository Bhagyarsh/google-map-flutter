import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomLocation {
  String name;
  LatLng coordinate;

  CustomLocation({@required this.name, @required this.coordinate});
}
