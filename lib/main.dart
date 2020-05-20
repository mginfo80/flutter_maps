import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttermaps/MarkerInformation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as lc;

import 'Utils.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

const DEFAULT_LOCATION= LatLng(-34.757638, -58.580859);
class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  //LatLng position = DEFAULT_LOCATION;
  MapType mapType = MapType.normal;
  BitmapDescriptor icon;
  bool isShowInfo = false;
  GoogleMapController controller;
  LatLng latLngOnLogPress;
  lc.Location location;
  bool myLocationEnabled = false;
  bool myLocationButtonEnabled = false;
  LatLng currentLocation = DEFAULT_LOCATION;
  Set<Marker>markers=Set<Marker>();
  Set<Circle>circles=Set<Circle>();
  Set<Polygon>polygons=Set<Polygon>();
  Set<Polyline>polyline=Set<Polyline>();


  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }


  @override
  void initState() {
    getIcons();
    requestPerms();
  }

  getLocation()async{
    var currentLocation =await location.getLocation();
    updateLocation(currentLocation);
  }

  updateLocation(currentLocation){
    if(currentLocation != null){
     // print("Ubicación actual del usuario latitud ${currentLocation.latitude} longitud ${currentLocation.longitude}");
      setState((){
        this.currentLocation = LatLng(
            currentLocation.latitude, currentLocation.longitude);
        this.controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: this.currentLocation, zoom:17),)
        );
        createMarkers();
        createCircle();
        createPolygon();
        createPolyline();
      });
    }
  }

  locationChange(){
    location.onLocationChanged.listen((lc.LocationData cloc){
      if(cloc!=null)  updateLocation(cloc);
    });
  }

  requestPerms()async{
    Map<Permission, PermissionStatus>statuses =
    await [Permission.locationAlways].request();

    var status = statuses[Permission.locationAlways];
    if(status == PermissionStatus.denied){
      requestPerms();
    }else{
      enableGPS();
    }
  }

  enableGPS()async{
    location = lc.Location();
    bool serviceStatusResult = await location.requestService();

    if(!serviceStatusResult){
      enableGPS();
    }else{
      updateStatus();
      getLocation();
      locationChange();
    }
  }

  updateStatus(){
    setState((){
      myLocationButtonEnabled = true;
      myLocationEnabled = true;
    });
  }

  getIcons() async {
    var icon = await BitmapDescriptor.fromAssetImage(ImageConfiguration(devicePixelRatio: 2.5), "img/destination.png");
    setState(() {
      this.icon = icon;
    });
  }

  onMapCreated(GoogleMapController controller){
    controller.setMapStyle(Utils.mapStyle);
    this.controller = controller;
  }

  onTopMap(LatLng latLng){
    print("onTapMap $latLng");
  }

  onLongPressMap(LatLng latLng){
    latLngOnLogPress = latLng;
    showPopUpMenu();
  }

  showPopUpMenu()async{
    String selected=await showMenu(context: context, 
        position: RelativeRect.fromLTRB(200, 200, 250, 250),
        items: [
          PopupMenuItem<String>(
            child: Text("Que hay aquí"),
            value: "QueHay",
          ),
          PopupMenuItem<String>(
            child: Text("Ir a"),
            value: "Ir",
          ),
        ],
    elevation: 8.0);

    if(selected!=null)
      getValue(selected);
  }

  getValue(value){

    if(value =="QueHay")
      print("Ubicación $latLngOnLogPress");
  }

  createMarkers(){
    markers.add( Marker(
        markerId: MarkerId("MarkerCurrent"),
        position: currentLocation,
        icon: this.icon,
        //infoWindow: InfoWindow(title: "Información del marcador",
        //snippet: "Latitud ${position.latitude} y Longitud ${position.longitude}")
        onTap:()=>setState((){

          this.isShowInfo =! this.isShowInfo; })
    ));
  }


  createPolyline(){
    polyline.add(Polyline(
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
      points: <LatLng>[
        LatLng(-34.757471, -58.580882),
        LatLng(-34.752835, -58.583810),
        LatLng(-34.746651, -58.578794),
        LatLng(-34.740540, -58.578229),

        ],
      polylineId: PolylineId("PolylineMap"),
      color:Colors.red
    ));
  }

  createPolygon(){
    polygons.add(Polygon(
      polygonId: PolygonId("polygonMap"),
      strokeWidth: 6,
      strokeColor: Colors.lightGreen,
      fillColor: Colors.greenAccent,
      geodesic: true,
      visible: false,
      points: <LatLng>[
        LatLng(-34.757471, -58.580882),
        LatLng(-34.752835, -58.583810),
        LatLng(-34.740540, -58.578229),
        LatLng(-34.746651, -58.578794),

      ]

    ));
  }

  createCircle(){
    circles.add(Circle(
      circleId: CircleId("circleMap"),
      center: this.currentLocation,
      onTap: onTapCircle,
      consumeTapEvents: true,
      fillColor: Colors.green,
      radius:4000,
      strokeColor: Colors.red,
      strokeWidth: 6,
      visible: false
    ));

  }

  onTapCircle(){
    print("onTapCircle");
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Stack(children: <Widget>[
        GoogleMap(
          trafficEnabled: true,
          initialCameraPosition: CameraPosition(
            target: currentLocation,
            zoom: 5,
            //bearing: 90,
            tilt: 45
          ),
          circles: circles,
          polygons: polygons,
          polylines: polyline,
          myLocationEnabled: myLocationEnabled,
          myLocationButtonEnabled: myLocationButtonEnabled,
          onCameraMoveStarted: ()=>{
            print("inicio")
          },
          onCameraIdle: ()=>{
            print("fin")
          },
          onCameraMove: (CameraPosition cameraPosition)=>{
            print("moviendo ${cameraPosition.target}")
          },
          onMapCreated: onMapCreated,
          onTap: onTopMap,
          onLongPress: onLongPressMap,
          mapType: mapType,
          /*cameraTargetBounds: CameraTargetBounds(LatLngBounds(
            northeast: LatLng(-3.772992, -38.518158),
            southwest: LatLng(-5.789668, -35.188945)
          )),
          minMaxZoomPreference: MinMaxZoomPreference(1,10),*/
          markers: markers,
        ),
        SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          overlayColor: Colors.black,
          overlayOpacity: 0.5,
          elevation: 8.0,
          children: [
            SpeedDialChild(
              label: 'NORMAL',
              child: Icon(Icons.room),
              onTap: ()=>setState(()=>mapType = MapType.normal)
            ),
            SpeedDialChild(
                label: 'SATELIITE',
                child: Icon(Icons.satellite),
                onTap: ()=>setState(()=>mapType = MapType.satellite)
            ),
            SpeedDialChild(
                label: 'HYBRID',
                child: Icon(Icons.compare),
                onTap: ()=>setState(()=>mapType = MapType.hybrid)
            ),
            SpeedDialChild(
                label: 'TERRAIN',
                child: Icon(Icons.terrain),
                onTap: ()=>setState(()=>mapType = MapType.terrain)
            ),
          ]
        ),
        Visibility(visible: this.isShowInfo,
            child: MarkerInformation("Mi Ubicación", this.currentLocation, "img/naruto.jpg"))
      ]),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  onDragEnd(LatLng position){
    print("new position $position");
  }

}
