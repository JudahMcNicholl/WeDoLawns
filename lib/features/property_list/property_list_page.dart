import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swipe_refresh/swipe_refresh.dart';
import 'package:wedolawns/features/property_list/property_list_cubit.dart';
import 'package:wedolawns/objects/property.dart';
import 'package:wedolawns/widgets/color_key.dart';
import 'package:wedolawns/widgets/property_item.dart';

class PropertyListPage extends StatefulWidget {
  const PropertyListPage({super.key});

  @override
  State<PropertyListPage> createState() => PropertyListPageState();
}

class PropertyListPageState extends State<PropertyListPage> {
  late PropertyListCubit _cubit;

  bool _showMap = false;
  bool get showMap => _showMap;
  toggleShowMap() {
    setState(() {
      _showMap = !_showMap;
    });
  }

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PropertyListCubit>();
    _cubit.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(108, 28, 36, 24),
          child: SvgPicture.asset(
            "assets/svgs/mower_fence.svg",
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          BlocConsumer<PropertyListCubit, PropertyListState>(
            listener: (context, state) {
              if (state is InfoWindowTapped) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(state.property.address),
                      content: Text(state.property.description),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // Close the dialog
                          },
                          child: Text("Close"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // Close the dialog
                            Navigator.of(context).pushNamed("/property", arguments: state.property).then((value) {
                              if (value is Property) {
                                _cubit.findAndReplaceProperty(value);
                              }
                            });
                          },
                          child: Text("Details"),
                        ),
                      ],
                    );
                  },
                );
              }
            },
            buildWhen: (previous, current) {
              return current is PropertyListStateLoaded || current is PropertyListStateInitial || current is PropertyDeleted;
              // current is PropertiesReloading;
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                    child: ColorKeyWidget(
                      isComplete: true,
                      isNew: true,
                      inProgress: true,
                    ),
                  ),
                  if (_showMap) ...[
                    Expanded(
                      child: GoogleMap(
                        key: GlobalKey(),
                        style:
                            """[{"elementType":"geometry","stylers":[{"color":"#ebe3cd"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#523735"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f1e6"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},{"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#c9b2a6"}]},{"featureType":"administrative.land_parcel","elementType":"geometry.stroke","stylers":[{"color":"#dcd2be"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#ae9e90"}]},{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"poi","stylers":[{"visibility":"off"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#93817c"}]},{"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#a5b076"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#447530"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#f5f1e6"}]},{"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#fdfcf8"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#f8c967"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#e9bc62"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#e98d58"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry.stroke","stylers":[{"color":"#db8555"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#806b63"}]},{"featureType":"transit","stylers":[{"visibility":"off"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"transit.line","elementType":"labels.text.fill","stylers":[{"color":"#8f7d77"}]},{"featureType":"transit.line","elementType":"labels.text.stroke","stylers":[{"color":"#ebe3cd"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#b9d3c2"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#92998d"}]},{"featureType":"poi.business","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.attraction","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.government","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.medical","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.place_of_worship","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.school","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.sports_complex","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]}]""",
                        initialCameraPosition: CameraPosition(
                          target: LatLng(-40.35629284713546, 175.61105584699382),
                          zoom: 12.5,
                        ),
                        markers: _cubit.markers.toSet(),
                        onMapCreated: (GoogleMapController controller) {},
                        myLocationEnabled: false,
                        myLocationButtonEnabled: false,
                        compassEnabled: false,
                        tiltGesturesEnabled: false,
                        padding: EdgeInsets.only(
                          // top: 64.0,
                          left: Platform.isIOS ? 15 : 0,
                        ),
                      ),
                    ),
                  ] else ...[
                    if (state is PropertyListStateInitial) ...[
                      CircularProgressIndicator.adaptive(),
                    ],
                    Expanded(
                      child: SwipeRefresh.builder(
                        stateStream: _cubit.propertyLoadingStream,
                        onRefresh: () => _cubit.reloadPropertiesSessions(),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: _cubit.properties.length,
                        itemBuilder: (context, index) {
                          if (_cubit.properties.isEmpty) {
                            return Container();
                          }
                          Property property = _cubit.properties[index];
                          return PropertyItem(
                            property: property,
                            onDelete: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Delete Property"),
                                    content: Text("Confirm delete"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false); // Close the dialog
                                        },
                                        child: Text("Cancel"),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          _cubit.deleteProperty(property);
                                          Navigator.of(context).pop(true); // Close the dialog
                                        },
                                        child: Text("Delete"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            onEdit: () {
                              Navigator.of(context).pushNamed("/property", arguments: property).then((value) {
                                setState(() {});
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ],
              );
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
                          toggleShowMap();
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Color(0xFFB9AB0E), // Background color
                            shape: BoxShape.circle, // Makes it circular
                          ),
                          child: Icon(
                            _showMap ? Icons.list : Icons.map_outlined,
                            color: Colors.white, // Icon color
                          ),
                        ),
                      ),
                      // Right circular button
                      GestureDetector(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Logout?"),
                                content: Text("Confirm logout"),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false); // Close the dialog
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop(true); // Close the dialog
                                      await FirebaseAuth.instance.signOut();
                                      Phoenix.rebirth(context);
                                    },
                                    child: Text("Logout"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Color(0xFF860404), // Background color
                            shape: BoxShape.circle, // Makes it circular
                          ),
                          child: Icon(
                            Icons.logout,
                            color: Colors.white, // Icon color
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Floating middle button
                  Positioned(
                    bottom: 8, // Adjust the value to float the button above
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed("/property_create").then((value) {
                          if (value == true) {
                            setState(() {
                              _cubit.initialize();
                            });
                          }
                        });
                      },
                      child: Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          color: Color(0xFF236002), // Background color
                          shape: BoxShape.circle, // Makes it circular
                        ),
                        child: Icon(
                          Icons.add,
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
        ],
      ),
    );
  }
}
