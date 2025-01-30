import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedolawns/features/property/property_cubit.dart';
import 'package:wedolawns/objects/drive_item.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/objects/property.dart';
import 'package:wedolawns/widgets/add_job_dialog.dart';
import 'package:wedolawns/widgets/color_key.dart';
import 'package:wedolawns/widgets/edit_job_dialog.dart';
import 'package:wedolawns/widgets/image_grid.dart';
import 'package:wedolawns/widgets/job_item.dart';
import 'package:wedolawns/widgets/left_right_item.dart';
import 'package:wedolawns/widgets/select_from_drive.dart';

class PropertyPage extends StatefulWidget {
  const PropertyPage({super.key});

  @override
  State<PropertyPage> createState() => _PropertyPageState();
}

void _launchYouTubeVideo(youtubeURL) async {
  String appURL = youtubeURL;

  // URLs sent to YouTube app can't start with https

  if (appURL.startsWith("https://")) {
    appURL = appURL.replaceFirst("https://", ""); // remove "https://" if it exists
  }

  try {
    await launch('youtube://$appURL', forceSafariVC: false).then((bool isLaunch) async {
      print('isLaunch: $isLaunch');
      if (!isLaunch) {
        // Launch Success
        print("Launching in browser now ...");
        await launch(youtubeURL);
      } else {
        // Launch Fail
        print("YouTube app Launched!");
      }
    });
  } catch (e) {
    print("An error occurred: $e");
    await launch(youtubeURL);
  }
}

class _PropertyPageState extends State<PropertyPage> {
  late PropertyCubit _cubit;
  late ValueNotifier<int> _currentImageIndexNotifier;
  late StreamController<int> _imageStreamController;
  final GlobalKey<ImageGridState> _imageGridState = GlobalKey();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PropertyCubit>();
    _imageStreamController = StreamController<int>();
    _currentImageIndexNotifier = ValueNotifier<int>(0);
    _imageStreamController.stream.listen((int value) {
      _currentImageIndexNotifier.value = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(_cubit.property);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_cubit.property.address),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: ColorKeyWidget(
                        isComplete: _cubit.property.isComplete,
                        isNew: _cubit.property.isNew,
                        inProgress: _cubit.property.isInProgress,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            _cubit.property.contactName.isEmpty ? "N/A" : _cubit.property.contactName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _cubit.property.contactPhoneNumber.isEmpty ? "N/A" : _cubit.property.contactPhoneNumber.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: LeftRightItem(
                              leftText: "Created @",
                              rightText: _cubit.property.dateCreatedString,
                            ),
                          ),
                          Spacer(flex: 1),
                          Expanded(
                            flex: 5,
                            child: LeftRightItem(
                              leftText: "Difficulty",
                              rightText: _cubit.property.difficultyString,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: LeftRightItem(
                              leftText: "Finished @",
                              rightText: _cubit.property.dateFinishedString,
                            ),
                          ),
                          Spacer(flex: 1),
                          Expanded(
                            flex: 5,
                            child: LeftRightItem(
                              leftText: "Est/Hrs",
                              rightText: _cubit.property.hoursConcatenatedString,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: LeftRightItem(
                              leftText: "Cost",
                              rightText: _cubit.property.totalCostString,
                            ),
                          ),
                          Spacer(flex: 1),
                          Expanded(
                            flex: 5,
                            child: LeftRightItem(
                              leftText: "Est/WoolSacks",
                              rightText: _cubit.property.woolsacksConcatenatedString,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            "Media",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: IconButton(
                            icon: Icon(Icons.play_circle),
                            onPressed: () {
                              if (_cubit.property.youtubeUrl.isNotEmpty) {
                                _launchYouTubeVideo(_cubit.property.youtubeUrl);
                              }
                            },
                            color: _cubit.property.youtubeUrl.isEmpty ? Colors.grey : Theme.of(context).primaryColor,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (context) => SelectFromDrive(
                                    propertyName: _cubit.property.address,
                                    media: _cubit.property.photos,
                                  ),
                                ),
                              )
                                  .then((value) {
                                if (value is List<List<DriveItem>>) {
                                  setState(() {
                                    _cubit.updateMedia(value);
                                  });
                                }
                              });
                            },
                            child: Text(
                              "Edit/Add",
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return Scaffold(
                            appBar: AppBar(
                              title: Text("Media (${_cubit.property.photos.length})"),
                              centerTitle: true,
                            ),
                            body: ImageGrid(
                              key: _imageGridState,
                              photos: _cubit.property.photos,
                              deleteMedia: (index) {
                                return _cubit.deleteMedia(index: index);
                              },
                              swapMedia: (index, type) {
                                return _cubit.swapMedia(index: index, swapType: type);
                              },
                            ),
                          );
                        }));
                      },
                      child: Text("View Media"),
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Jobs (${_cubit.property.jobs.length})",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          iconSize: 32,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AddJobDialog(
                                  items: _cubit.items,
                                  onAddJob: (name, description, estimatedHours) {
                                    if (_cubit.addJob(
                                      name: name,
                                      description: description,
                                      estimatedHours: estimatedHours,
                                    )) {
                                      setState(() {});
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 148),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _cubit.property.jobs.length,
                        itemBuilder: (BuildContext context, int index) {
                          Job job = _cubit.property.jobs[index];
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                            child: JobItem(
                              job: job,
                              onComplete: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    TextEditingController controller = TextEditingController();
                                    return AlertDialog(
                                      title: Text("Set actual hours"),
                                      content: Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                                        child: TextField(
                                          controller: controller,
                                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                          textInputAction: TextInputAction.done,
                                          textCapitalization: TextCapitalization.sentences,
                                          decoration: InputDecoration(
                                            labelText: "Actual hours",
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false); // Close the dialog
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (await _cubit.completeJob(job, controller.text)) {
                                              Navigator.of(context).pop(true); // Close the dialog
                                              setState(() {});
                                            }
                                          },
                                          child: Text("Update"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              onDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Delete Job"),
                                      content: Text("Confirm delete of (${job.name})"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false); // Close the dialog
                                          },
                                          child: Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _cubit.removeJob(job);
                                            });
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
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return EditJobDialog(
                                      items: _cubit.items,
                                      jobName: job.name,
                                      jobDescription: job.description,
                                      jobEstimatedHours: job.estimatedHours,
                                      onEditJob: (name, description, estimatedHours) {
                                        if (_cubit.editJob(
                                          job: job,
                                          name: name,
                                          description: description,
                                          estimatedHours: estimatedHours,
                                        )) {
                                          setState(() {});
                                        }
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    // Floating middle button
                    Positioned(
                      bottom: 8, // Adjust the value to float the button above
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushNamed("/property_edit", arguments: _cubit.property).then((value) {
                            setState(() {
                              if (value is Property) {
                                _cubit.property = Property.fromJson(value.toJson());
                              }
                            });
                          });
                        },
                        child: Container(
                          width: 108,
                          height: 108,
                          decoration: BoxDecoration(
                            color: Color(0xFFB9AB0E), // Background color
                            shape: BoxShape.circle, // Makes it circular
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 48, // Adjust icon size
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
