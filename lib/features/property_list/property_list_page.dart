import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wedolawns/features/property_list/property_list_cubit.dart';
import 'package:wedolawns/objects/property.dart';

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
        title: Text("We.Do.Lawns"),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            toggleShowMap();
          },
          icon: Icon(_showMap ? Icons.list : Icons.map_outlined),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Phoenix.rebirth(context);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.of(context).pushNamed("/property_create").then((value) {
              if (value == true) {
                refetchData();
              }
            });
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
      body: BlocConsumer<PropertyListCubit, PropertyListState>(
        listener: (context, state) {
          if (state is InfoWindowTapped) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(state.property.name),
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
                        Navigator.of(context).pushNamed("/property", arguments: state.property).then((value) {});
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
        },
        builder: (context, state) {
          if (_showMap) {
            return GoogleMap(
              style:
                  """[{"elementType":"geometry","stylers":[{"color":"#ebe3cd"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#523735"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#f5f1e6"}]},{"featureType":"administrative","elementType":"geometry","stylers":[{"visibility":"off"}]},{"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#c9b2a6"}]},{"featureType":"administrative.land_parcel","elementType":"geometry.stroke","stylers":[{"color":"#dcd2be"}]},{"featureType":"administrative.land_parcel","elementType":"labels.text.fill","stylers":[{"color":"#ae9e90"}]},{"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"poi","stylers":[{"visibility":"off"}]},{"featureType":"poi","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#93817c"}]},{"featureType":"poi.park","elementType":"geometry.fill","stylers":[{"color":"#a5b076"}]},{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#447530"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#f5f1e6"}]},{"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]},{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#fdfcf8"}]},{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#f8c967"}]},{"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#e9bc62"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#e98d58"}]},{"featureType":"road.highway.controlled_access","elementType":"geometry.stroke","stylers":[{"color":"#db8555"}]},{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#806b63"}]},{"featureType":"transit","stylers":[{"visibility":"off"}]},{"featureType":"transit.line","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"transit.line","elementType":"labels.text.fill","stylers":[{"color":"#8f7d77"}]},{"featureType":"transit.line","elementType":"labels.text.stroke","stylers":[{"color":"#ebe3cd"}]},{"featureType":"transit.station","elementType":"geometry","stylers":[{"color":"#dfd2ae"}]},{"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#b9d3c2"}]},{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#92998d"}]},{"featureType":"poi.business","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.attraction","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.government","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.medical","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.place_of_worship","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.school","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi.sports_complex","elementType":"all","stylers":[{"visibility":"off"}]},{"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]}]""",
              initialCameraPosition: CameraPosition(
                target: LatLng(-40.35629284713546, 175.61105584699382),
                zoom: 12.5,
              ),
              markers: _cubit.markers.toSet(),
              onMapCreated: (GoogleMapController controller) {
                // _controller.complete(controller);
              },
            );
          }
          if (state is PropertyListStateInitial) {
            return Center(child: CircularProgressIndicator.adaptive());
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: _cubit.properties.length,
              itemBuilder: (BuildContext context, int index) {
                Property property = _cubit.properties[index];

                return Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                  child: ListTile(
                    title: Text(property.name),
                    subtitle: Text(property.description),
                    trailing: GestureDetector(
                      onTap: () {
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
                      child: Icon(Icons.delete),
                    ),
                    isThreeLine: false,
                    tileColor: property.dateFinished == null ? const Color.fromARGB(255, 202, 120, 120) : const Color.fromARGB(57, 50, 99, 48),
                    onTap: () {
                      Navigator.of(context).pushNamed("/property", arguments: property).then((value) {});
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  refetchData() {
    setState(() {
      _cubit.initialize();
    });
  }
}
