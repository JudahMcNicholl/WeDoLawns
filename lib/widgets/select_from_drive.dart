import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wedolawns/objects/drive_item.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/utils/gsign.dart';

class SelectFromDrive extends StatefulWidget {
  final String propertyName;
  final List<MediaItem> media;
  const SelectFromDrive({
    super.key,
    required this.propertyName,
    required this.media,
  });

  @override
  State<SelectFromDrive> createState() => _SelectFromDriveState();
}

class _SelectFromDriveState extends State<SelectFromDrive> {
  final List<List<DriveItem>> _driveItems = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select files"),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, v) {
          if (didPop) return;
          Navigator.of(context).pop(_driveItems);
        },
        child: SingleChildScrollView(
          child: Center(
            child: FutureBuilder(
              future: _driveItems.isEmpty ? _authenticateAndFetchFiles() : null,
              initialData: [],
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator.adaptive();
                }
                if (snapshot.hasData) {
                  List<Widget> children = [];

                  if (_driveItems.isEmpty) {
                    children.add(Text("No data"));
                  } else {
                    for (var (index, group) in _driveItems.indexed) {
                      if (group.length == 2) {
                        // If we have a matched pair, display in a Row
                        children.add(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: group.map((driveItem) {
                              return Expanded(
                                child: ListTile(
                                  leading: Checkbox(
                                    value: driveItem.isSelected,
                                    onChanged: (v) {
                                      setState(() {
                                        driveItem.isSelected = !driveItem.isSelected;
                                        driveItem.isSelected = driveItem.isSelected;
                                      });
                                    },
                                  ),
                                  title: Platform.isIOS || driveItem.mimeType != "image/heic"
                                      ? CachedNetworkImage(
                                          imageUrl: driveItem.path,
                                          progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator.adaptive(value: downloadProgress.progress)),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                        )
                                      : Container(),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      } else {
                        // Single items are displayed normally
                        DriveItem driveItem = group.first;
                        if (driveItem.isTitle) {
                          children.add(ListTile(
                            title: Text(driveItem.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            leading: Checkbox(
                                value: driveItem.isSelected,
                                onChanged: (v) {
                                  setState(() {
                                    driveItem.isSelected = !driveItem.isSelected;
                                    int indexOf = index;
                                    while (indexOf + 1 < _driveItems.length) {
                                      indexOf += 1;
                                      List<DriveItem> i = _driveItems[indexOf];
                                      if (!i[0].isTitle) {
                                        i[0].isSelected = driveItem.isSelected;
                                        if (i.length > 1) {
                                          i[1].isSelected = driveItem.isSelected;
                                        }
                                      } else {
                                        break;
                                      }
                                    }
                                  });
                                }),
                          ));
                        } else {
                          children.add(
                            ListTile(
                              leading: Checkbox(
                                value: driveItem.isSelected,
                                onChanged: (v) {
                                  setState(() {
                                    driveItem.isSelected = !driveItem.isSelected;
                                  });
                                },
                              ),
                              title: CachedNetworkImage(
                                  imageUrl: driveItem.path,
                                  progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
                                      width: 12, height: 12, child: CircularProgressIndicator.adaptive(value: downloadProgress.progress)),
                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                  imageBuilder: (context, imageProvider) {
                                    return SizedBox(
                                      width: 52, // Set your desired width
                                      height: 100, // Set your desired height
                                      child: Image(
                                        image: imageProvider,
                                        // fit: BoxFit.cover, // Adjust fit as needed (cover, contain, fill, etc.)
                                      ),
                                    );
                                  }),
                            ),
                          );
                        }
                      }
                    }
                  }

                  return Column(
                    children: children,
                  );
                }
                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }

  Future fetchFromDrive({
    required String accessToken,
    required Map<String, String> queryParameters,
  }) async {
    // Use HttpClient to make an API request
    final client = HttpClient();
    final request = await client.getUrl(
      Uri.https('www.googleapis.com', "/drive/v3/files", queryParameters),
    );

    // Add authorization header
    request.headers.set('Authorization', 'Bearer $accessToken');

    // Send the request and get the response
    var response = await request.close();
    if (response.statusCode == 200) {
      // Parse the response
      final responseBody = await response.transform(utf8.decoder).join();
      final jsonResponse = json.decode(responseBody) as Map<String, dynamic>;

      // Display the list of files
      return jsonResponse['files'] as List<dynamic>? ?? [];
      // for (var file in files) {
    }
  }

  Future<List<List<DriveItem>>> _authenticateAndFetchFiles() async {
    _driveItems.clear();
    List<DriveItem> innerDriveItems = [];
    // Authenticate the user
    GoogleSignInAccount? account = GSign.instance.googleSignIn.currentUser;
    if (GSign.instance.googleSignIn.currentUser == null) {
      account = await GSign.instance.googleSignIn.signIn();
    }
    if (account == null) {
      print("Sign-in aborted.");
      return [];
    }
    // Retrieve the authentication headers
    final authHeaders = await account.authHeaders;
    final accessToken = authHeaders['Authorization']?.split(' ').last;

    if (accessToken == null) {
      print("Failed to retrieve access token.");
      return [];
    }

    var files = await fetchFromDrive(
      accessToken: accessToken,
      queryParameters: {
        'q': "'1e3w96UxWVK_Sdbc19MAV5UoaF4ZURi98' in parents and name contains '${widget.propertyName.replaceAll(' ', '')}'",
      },
    );
    for (var file in files) {
      String fileId = file['id'];
      innerDriveItems.add(DriveItem(id: "-", name: file["name"], path: "", isTitle: true, mimeType: ""));

      var innerFiles = await fetchFromDrive(
        accessToken: accessToken,
        queryParameters: {
          'q': "'$fileId' in parents", // Get all files in the folder
          'fields': 'files(id, name, webContentLink, mimeType)',
        },
      );

      for (var item in innerFiles) {
        log(item["name"]);
        String id = item["id"];
        DriveItem driveItem = DriveItem(
            id: item["id"],
            name: item["name"],
            path: item["webContentLink"],
            isSelected: widget.media.any((e) => e.path.contains(id) || e.androidPath.contains(id)),
            mimeType: item["mimeType"]);
        innerDriveItems.add(driveItem);
      }
    }
    Map<String, List<DriveItem>> groupedItems = {};

    for (var item in innerDriveItems) {
      // Extract base name without extension
      String baseName = item.name.replaceAll(RegExp(r'\.\w+$'), '');

      // Add to the map
      groupedItems.putIfAbsent(baseName, () => []).add(item);
    }

    // Convert map values into a list of lists
    List<List<DriveItem>> marriedDriveItems = groupedItems.values.toList();
    _driveItems.addAll(marriedDriveItems);
    return marriedDriveItems;
  }
}
