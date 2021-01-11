import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gmap/provider/Location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:google_maps_webservice/places.dart";
import 'package:provider/provider.dart';
import '../models/serachLoaction.dart';
import 'DropLocation.dart';

class PickupLocation extends StatefulWidget {
  @override
  _PickupLocationState createState() => _PickupLocationState();
}

class _PickupLocationState extends State<PickupLocation> {
  List<Marker> allMarker = [];
  LatLng _center;

  Geolocator geolocator = Geolocator();

  @override
  Widget build(BuildContext context) {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: true);
    _setPickupLocation(String name, LatLng postion, bool changemarker) {
      if (allMarker.length == 2) {
        setState(() {
          allMarker.removeLast();
        });
      }
      locationProvider
          .setPickupLocation(CustomLocation(name: name, coordinate: postion));
      if (changemarker) {
        BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(40, 40)),
                "assets/icons/pickupmarker.png")
            .then((pickupicon) {
          setState(() {
            allMarker.add(
              Marker(
                alpha: 1,
                icon: pickupicon,
                markerId: MarkerId("pickup_location"),
                draggable: true,
                onDragEnd: (newPickupLocation) {
                  locationProvider.setPickupLocation(CustomLocation(
                      name: "Picup Location", coordinate: newPickupLocation));
                },
                onTap: () {},
                position: locationProvider.getPickupLocation().coordinate,
                infoWindow: InfoWindow(title: "Pickup location"),
              ),
            );
          });
        });
      }
    }

    Completer<GoogleMapController> _controller = Completer();

    Future<void> _goToLocation(LatLng target) async {
      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 14.0),
      ));
    }

    if (_center == null) {
      _getLocation().then((currentLocation) {
        print(currentLocation);
        locationProvider.setPickupLocation(CustomLocation(
            name: "Picup Location",
            coordinate:
                LatLng(currentLocation.latitude, currentLocation.longitude)));
        locationProvider.setCurrentLocation(CustomLocation(
            name: "current location",
            coordinate:
                LatLng(currentLocation.latitude, currentLocation.longitude)));
        BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(40, 40)),
                "assets/icons/currentLocation.png")
            .then((currentIcon) => {
                  setState(() {
                    _center = LatLng(
                        currentLocation.latitude, currentLocation.longitude);

                    allMarker.add(
                      Marker(
                        alpha: 1,
                        icon: currentIcon,
                        markerId: MarkerId("current_location"),
                        draggable: true,
                        onDragEnd: (newCurrentLocation) {},
                        onTap: () {},
                        position: _center,
                        infoWindow: InfoWindow(title: "current location"),
                      ),
                    );
                  })
                });
      });
    }

    if (_center != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Pick up location"),
          actions: [
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: PickupLoactionSearch())
                      .then((locationResult) async {
                    if (locationResult != "") {
                      var location = locationResult.split("||");
                      print("name " + location[0]);
                      print(location[1]);
                      print(location[2]);
                      LatLng _pickup = LatLng(
                        double.parse(location[1]),
                        double.parse(location[2]),
                      );
                      _goToLocation(_pickup);
                      _setPickupLocation("pick up location", _pickup, true);
                    }
                  });
                })
          ],
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              myLocationEnabled: false,
              markers: allMarker.toSet(),
              initialCameraPosition: CameraPosition(
                  target: locationProvider.getCurrentLocation().coordinate,
                  zoom: 14.0),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  RaisedButton(
                    onPressed: () => {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) =>
                              ChangeNotifierProvider<LocationProvider>.value(
                                value: locationProvider,
                                child: DropLocation(),
                              )))
                    },
                    child: Text("Confirm Pickup location"),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }
    return Scaffold(
        appBar: AppBar(title: Text("Pick up location")),
        body: Center(child: CircularProgressIndicator()));
  }

  Future<Position> _getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }
}
//   Future<Position> _getLocation() async {
//     var currentLocation;
//     try {
//       currentLocation = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.best);
//     } catch (e) {
//       currentLocation = null;
//     }
//     return currentLocation;
//   }
// }

class PickupLoactionSearch extends SearchDelegate<String> {
  CustomLocation pickup;
  Future<List<CustomLocation>> _getLocationList(String search) async {
    // PlacesSearchResponse response =
    //     await places.searchNearbyWithRadius(new Location(19, 73), 3000);
    const kGoogleApiKey = "AIzaSyAoaZYHwECCzM7vqcAZYPiQCYhIO2M9RrM";
    final places = new GoogleMapsPlaces(apiKey: kGoogleApiKey);

    PlacesSearchResponse response = await places.searchByText(search);
    print(response.results.length);
    List<CustomLocation> searchLocation = [];
    for (var result in response.results) {
      searchLocation.add(CustomLocation(
          name: result.name,
          coordinate: LatLng(
              result.geometry.location.lat, result.geometry.location.lng)));
    }
    return searchLocation;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, query);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Text(pickup?.name),
        Text(pickup?.coordinate.toString()),
      ],
    ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
        future: _getLocationList(query),
        builder: (context, AsyncSnapshot<List<CustomLocation>> snapshot) {
          if ((!snapshot.hasData) && (query.length < 3))
            return Text("No Location found");
          else {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) => ListTile(
                      onTap: () {
                        pickup = snapshot.data[index];
                        close(
                            context,
                            pickup.name +
                                "||" +
                                pickup.coordinate.latitude.toString() +
                                "||" +
                                pickup.coordinate.longitude.toString());
                        // showResults(context);
                      },
                      leading: Icon(Icons.location_on),
                      title: Text(snapshot.data[index].name),
                    ));
          }
        });
  }
}
