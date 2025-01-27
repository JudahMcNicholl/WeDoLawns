import 'dart:convert';
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
  final List<DriveItem> _driveItems = [];
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
                  List<DriveItem> data = snapshot.data!; // Assuming snapshot data is of type Map<String, List<dynamic>>

                  // Flatten the map structure
                  List<Widget> children = [];
                  if (data.isEmpty) {
                    children.add(Text("No data"));
                  } else {
                    for (DriveItem driveItem in data) {
                      if (driveItem.isTitle) {
                        children.add(ListTile(
                          title: Text(driveItem.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          leading: Checkbox(
                              value: driveItem.isSelected,
                              onChanged: (v) {
                                setState(() {
                                  driveItem.isSelected = !driveItem.isSelected;
                                  int indexOf = data.indexOf(driveItem);
                                  while (indexOf + 1 < data.length) {
                                    indexOf += 1;
                                    DriveItem i = data[indexOf];
                                    if (!i.isTitle) {
                                      data[indexOf].isSelected = driveItem.isSelected;
                                    } else {
                                      break;
                                    }
                                  }
                                });
                              }),
                        ));
                        // children.add(Text(, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)));
                      } else {
                        children.add(ListTile(
                          leading: Checkbox(
                              value: driveItem.isSelected,
                              onChanged: (v) {
                                setState(() {
                                  driveItem.isSelected = !driveItem.isSelected;
                                });
                              }),
                          trailing: CachedNetworkImage(
                              imageUrl: driveItem.path,
                              progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator.adaptive(value: downloadProgress.progress),
                                  ),
                              errorWidget: (context, url, error) {
                                return Icon(Icons.error);
                              }),
                          title: Text(driveItem.name),
                          subtitle: Text(driveItem.id),
                        ));
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

  Future<List<DriveItem>> _authenticateAndFetchFiles() async {
    _driveItems.clear();
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
      _driveItems.add(DriveItem(id: "-", name: file["name"], path: "", isTitle: true));

      var innerFiles = await fetchFromDrive(
        accessToken: accessToken,
        queryParameters: {
          'q': "'$fileId' in parents", // Get all files in the folder
          'fields': 'files(id, name, webContentLink)',
        },
      );

      for (var item in innerFiles) {
        String id = item["id"];
        DriveItem driveItem = DriveItem(
            id: item["id"], name: item["name"], path: item["webContentLink"], isSelected: widget.media.any((e) => e.path.contains(id)));
        _driveItems.add(driveItem);
      }
    }

    return _driveItems;
  }
}
