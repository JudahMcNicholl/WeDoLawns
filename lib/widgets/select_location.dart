import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationPage extends StatefulWidget {
  final GeoPoint? currentLocation;
  const SelectLocationPage({
    super.key,
    this.currentLocation,
  });

  @override
  State<SelectLocationPage> createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  final List<Marker> markers = [];
  @override
  void initState() {
    super.initState();
    if (widget.currentLocation != null) {
      markers.add(Marker(markerId: MarkerId("1"), position: LatLng(widget.currentLocation!.latitude, widget.currentLocation!.longitude)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Select location"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            style:
                """[{"elementType":"geometry","stylers":[{"color":"#ebe3cd"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#523735"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f1e6"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},{"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#c9b2a6"}]},{"featureType":"administrative.land_parcel","elementType":"geometry.stroke","stylers":[{"color":"#dcd2be"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#ae9e90"}]},{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"poi","stylers":[{"visibility":"off"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#93817c"}]},{"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#a5b076"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#447530"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#f5f1e6"}]},{"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#fdfcf8"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#f8c967"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#e9bc62"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#e98d58"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry.stroke","stylers":[{"color":"#db8555"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#806b63"}]},{"featureType":"transit","stylers":[{"visibility":"off"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"transit.line","elementType":"labels.text.fill","stylers":[{"color":"#8f7d77"}]},{"featureType":"transit.line","elementType":"labels.text.stroke","stylers":[{"color":"#ebe3cd"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#b9d3c2"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#92998d"}]},{"featureType":"poi.business","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.attraction","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.government","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.medical","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.place_of_worship","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.school","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.sports_complex","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]}]""",
            initialCameraPosition: CameraPosition(
              target: markers.isEmpty ? LatLng(-40.35629284713546, 175.61105584699382) : markers.first.position,
              zoom: 12.5,
            ),
            markers: markers.toSet(),
            onMapCreated: (GoogleMapController controller) {},
            onTap: (location) {
              setState(() {
                markers.clear();
                markers.add(Marker(markerId: MarkerId("1"), position: location));
              });
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  // Row for the two side buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Left circular button
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            markers.clear();
                          });
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Color(0xFFB9AB0E), // Background color
                            shape: BoxShape.circle, // Makes it circular
                          ),
                          child: Icon(
                            Icons.clear,
                            color: Colors.white, // Icon color
                          ),
                        ),
                      ),
                      // Right circular button
                      SizedBox(
                        width: 72,
                        height: 72,
                      ),
                    ],
                  ),
                  // Floating middle button
                  Positioned(
                    bottom: 8, // Adjust the value to float the button above
                    child: GestureDetector(
                      onTap: () {
                        if (markers.isEmpty) {
                          Navigator.of(context).pop();
                          return;
                        }
                        Navigator.of(context).pop(markers.first.position);
                      },
                      child: Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          color: Color(0xFF236002), // Background color
                          shape: BoxShape.circle, // Makes it circular
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 48, // Adjust icon size
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          // Expanded(
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: ElevatedButton(
          //             onPressed: () {
          //               setState(() {
          //                 markers.clear();
          //               });
          //             },
          //             child: Text("Clear")),
          //       ),
          //       Expanded(
          //         child: ElevatedButton(
          //             onPressed: () {
          //
          //             },
          //             child: Text("Confirm")),
          //       ),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
