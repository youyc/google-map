import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Map',
      home: GoogleMapScreen(),
    );
  }
}

class GoogleMapScreen extends StatefulWidget {
  @override
  _GoogleMapScreenState createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  Completer<GoogleMapController> _controller = Completer();
  static LatLng _center = LatLng(6.4676929, 100.5067673);
  LatLng _lastMapPosition = _center;
  Set<Marker> _markers = {};
  Map<String, MapType> _mapType = {
    "maptype1": MapType.normal,
    "maptype2": MapType.hybrid,
    "maptype3": MapType.terrain,
    "maptype4": MapType.satellite,
  };
  MapType _currentMapType = MapType.normal;
  var _addressLine;

  void _onMapTypeButtonPressed() {
    setState(() {
      if (_currentMapType == _mapType["maptype1"])
        _currentMapType = _mapType["maptype2"];
      else if (_currentMapType == _mapType["maptype2"])
        _currentMapType = _mapType["maptype3"];
      else if (_currentMapType == _mapType["maptype3"])
        _currentMapType = _mapType["maptype4"];
      else if (_currentMapType == _mapType["maptype4"])
        _currentMapType = _mapType["maptype1"];
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onAddMarkerButtonPressed() async {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: "$_lastMapPosition",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        draggable: true,
      ));
      _getUserLocation();
    });
  }

  //translate latitude and longitude into address
  _getUserLocation() async {
    _markers.forEach((value) async {
      final coordinates =
          Coordinates(value.position.latitude, value.position.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var address = addresses.first;
      _addressLine = address.addressLine;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _onAddMarkerButtonPressed();
    _getUserLocation;
  }

  @override
  Widget build(BuildContext context) {
    double screen_height = MediaQuery.of(context).size.height;
    double screen_width = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'Google Map',
            style: TextStyle(
              fontSize: 28,
            ),
          ),
          backgroundColor: Colors.deepPurple,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                        height: (screen_height / 3) * 2,
                        width: screen_width - 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _center,
                            zoom: 17.0,
                          ),
                          mapType: _currentMapType,
                          markers: _markers,
                          onCameraMove: _onCameraMove,
                        )),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 20, 0),
                          child: FloatingActionButton(
                            onPressed: _onMapTypeButtonPressed,
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            backgroundColor: Colors.blueGrey[700],
                            child: const Icon(Icons.map, size: 30.0),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 20, 0),
                          child: FloatingActionButton(
                            onPressed: _onAddMarkerButtonPressed,
                            materialTapTargetSize: MaterialTapTargetSize.padded,
                            backgroundColor: Colors.blueGrey[700],
                            child: const Icon(Icons.add_location, size: 30.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.fromLTRB(15, 0, 0, 0),
                    width: (screen_width / 2) - 20,
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          color: Colors.deepPurple,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Latitude",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          color: Colors.deepPurple[400],
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "${_lastMapPosition.latitude}",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    width: (screen_width / 2) - 20,
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          color: Colors.deepPurple,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Longitude",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 40,
                          color: Colors.deepPurple[400],
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "${_lastMapPosition.longitude}",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 15, 0, 0),
              child: Row(
                children: [
                  Container(
                    height: 70,
                    width: 100,
                    color: Colors.deepPurple,
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Address",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 70,
                    width: screen_width - 130,
                    color: Colors.deepPurple[400],
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Text(
                      '${_addressLine}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
