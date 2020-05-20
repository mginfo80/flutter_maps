import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerInformation extends StatefulWidget{
  String title;
  LatLng latLng;
  String image;
  MarkerInformation(this.title, this.latLng, this.image);
  @override
  State<StatefulWidget> createState() => MarkerInformationState();

}

class MarkerInformationState extends State<MarkerInformation>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        color: Colors.white
      ),
      child: Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left:10),
            width: 50,
            height: 50,
            child: ClipOval(child: Image.asset(widget.image,fit: BoxFit.cover))
          ),
          Container(
            margin: EdgeInsets.only(left:20),
            child: Column(
              children: <Widget>[
                Text(widget.title,style: TextStyle(color: Colors.greenAccent),),
                Text("Latitud: ${widget.latLng.latitude}",style: TextStyle(fontSize:12, color: Colors.grey),),
                Text("Longitud: ${widget.latLng.longitude}",style: TextStyle(fontSize:12, color: Colors.grey),),
              ]
            ),
          )
        ]
      ),
    );
  }

}