import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gmap/provider/Location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import "package:google_maps_webservice/places.dart";
import 'package:provider/provider.dart';
import '../models/serachLoaction.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DropLocation extends StatefulWidget {
  @override
  _DropLocationState createState() => _DropLocationState();
}

class _DropLocationState extends State<DropLocation> {
  List<Marker> allMarker = [];
  List<Polyline> _polyLine = [];
  bool _dropDownDisable;
  @override
  void initState() {
    super.initState();
    _dropDownDisable = true;
  }

  @override
  Widget build(BuildContext context) {
    final locationProvider =
        Provider.of<LocationProvider>(context, listen: true);
    Completer<GoogleMapController> _controller = Completer();

    Future<void> _goToLocation(LatLng target) async {
      final GoogleMapController controller = await _controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 14.0),
      ));
    }

    void _setDropLocation(String name, LatLng postion, bool changemarker) {
      if (allMarker.length == 3) {
        setState(() {
          allMarker.removeLast();
        });
      }
      locationProvider
          .setDropLocation(CustomLocation(name: name, coordinate: postion));
      if (changemarker) {
        BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(40, 40)),
                "assets/icons/locationmarker.png")
            .then((pickupicon) {
          setState(() {
            _dropDownDisable = false;
            allMarker.add(
              Marker(
                alpha: 1,
                icon: pickupicon,
                markerId: MarkerId("drop_location"),
                draggable: true,
                onDragEnd: (newPickupLocation) {
                  locationProvider.setDropLocation(CustomLocation(
                      name: "Drop Location", coordinate: newPickupLocation));
                },
                onTap: () {},
                position: locationProvider.getDropLocation().coordinate,
                infoWindow: InfoWindow(title: "Drop location"),
              ),
            );
          });
        });
      }
    }

    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(200, 100)),
            "assets/icons/currentLocation.png")
        .then((iconCurrentLocation) {
      setState(() {
        allMarker.add(
          Marker(
            alpha: 1,
            icon: iconCurrentLocation,
            markerId: MarkerId("current_location"),
            draggable: false,
            onTap: () {},
            position: locationProvider.getCurrentLocation().coordinate,
            infoWindow: InfoWindow(title: "pickup location"),
          ),
        );
      });
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(200, 100)),
            "assets/icons/pickupmarker.png")
        .then((iconPickup) {
      setState(() {
        allMarker.add(
          Marker(
            alpha: 1,
            icon: iconPickup,
            markerId: MarkerId("pickup_location"),
            draggable: false,
            onTap: () {},
            position: locationProvider.getPickupLocation().coordinate,
            infoWindow: InfoWindow(title: "pickup location"),
          ),
        );
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("Drop location"),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: DropLoactionSearch())
                    .then((locationResult) async {
                  if (locationResult != "") {
                    var location = locationResult.split("||");
                    print("name " + location[0]);
                    print(location[1]);
                    print(location[2]);

                    LatLng dropLocation = LatLng(
                      double.parse(location[1]),
                      double.parse(location[2]),
                    );
                    _setDropLocation("Drop Location", dropLocation, true);
                    _goToLocation(dropLocation);
                  }
                });
              })
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            polylines: _polyLine.toSet(),
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
                    if (!_dropDownDisable)
                      {
                        setState(() {
                          _polyLine.add(Polyline(
                            polylineId: PolylineId("route1"),
                            color: Colors.blue,
                            patterns: [
                              PatternItem.dash(20.0),
                              PatternItem.gap(10)
                            ],
                            width: 3,
                            points: [
                              locationProvider.getPickupLocation().coordinate,
                              locationProvider.getDropLocation().coordinate,
                            ],
                          ));
                        })
                      }
                    else
                      {
                        Fluttertoast.showToast(
                            msg: "Please Select Drop Location first",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.BOTTOM,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            fontSize: 16.0)
                      }
                  },
                  child: Text("Confirm drop location"),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class DropLoactionSearch extends SearchDelegate<String> {
  CustomLocation pickup;
  Future<List<CustomLocation>> _getLocationList(String search) async {
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
