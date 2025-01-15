import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedolawns/features/property/property_cubit.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/widgets/add_job_dialog.dart';
import 'package:wedolawns/widgets/edit_job_dialog.dart';
import 'package:wedolawns/widgets/job_item.dart';

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

  handleClick(int item) {
    switch (item) {
      case 0:
        //Actual hours

        if (_cubit.property.dateFinished != null) return;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController hoursController =
                TextEditingController(text: _cubit.property.hoursWorked == null ? "" : _cubit.property.hoursWorked.toString());
            TextEditingController woolsackController =
                TextEditingController(text: _cubit.property.actualWoolsacks == null ? "" : _cubit.property.actualWoolsacks.toString());
            return AlertDialog(
              title: Text("Finish Property"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                    child: TextField(
                      controller: hoursController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: "Hours worked",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                    child: TextField(
                      controller: woolsackController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: "Woolsacks filled",
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false); // Close the dialog
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_cubit.finished(hoursWorked: hoursController.text, woolsacksFilled: woolsackController.text)) {
                      setState(() {});
                    }

                    Navigator.of(context).pop(true); // Close the dialog
                  },
                  child: Text("Finished"),
                ),
              ],
            );
          },
        );
        break;
      case 1:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController controller =
                TextEditingController(text: _cubit.property.hoursWorked == null ? "" : _cubit.property.hoursWorked.toString());
            return AlertDialog(
              title: Text("Set Actual hours"),
              content: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "Hours worked",
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
                  onPressed: () {
                    if (_cubit.updateActualHours(hoursWorked: controller.text)) {
                      setState(() {});
                    }

                    Navigator.of(context).pop(true); // Close the dialog
                  },
                  child: Text("Update"),
                ),
              ],
            );
          },
        );
        break;
      case 2:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController controller =
                TextEditingController(text: _cubit.property.actualWoolsacks == null ? "" : _cubit.property.actualWoolsacks.toString());
            return AlertDialog(
              title: Text("Set Actual woolsacks"),
              content: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "Woolsacks used",
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
                  onPressed: () {
                    if (_cubit.updateActualWoolsacks(woolsacksUsed: controller.text)) {
                      setState(() {});
                    }

                    Navigator.of(context).pop(true); // Close the dialog
                  },
                  child: Text("Update"),
                ),
              ],
            );
          },
        );
        break;
      case 3:
        Navigator.of(context).pushNamed("/location", arguments: _cubit.property.location).then((value) {
          if (value is LatLng) {
            if (_cubit.updateLocation(loc: value)) {
              setState(() {});
            }
          }
        });
        break;
      case 4:
        showDialog(
          context: context,
          builder: (BuildContext context) {
            TextEditingController controller = TextEditingController(text: _cubit.property.youtubeUrl);
            return AlertDialog(
              title: Text("Set youtube url"),
              content: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: "Youtube url",
                  ),
                ),
              ),
              actions: [
                if (_cubit.property.youtubeUrl.isNotEmpty) ...[
                  TextButton(
                    onPressed: () {
                      _launchYouTubeVideo(_cubit.property.youtubeUrl);
                      Navigator.of(context).pop(false); // Close the dialog
                    },
                    child: Text("Play"),
                  ),
                ],
                ElevatedButton(
                  onPressed: () {
                    if (_cubit.setYoutubeUrl(youtubeUrl: controller.text)) {
                      setState(() {});
                    }
                    Navigator.of(context).pop(true); // Close the dialog
                  },
                  child: Text("Update"),
                ),
              ],
            );
          },
        );

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_cubit.property.name),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<int>(
            onSelected: (item) => handleClick(item),
            itemBuilder: (context) => [
              PopupMenuItem<int>(value: 0, child: Text('Finished')),
              PopupMenuItem<int>(value: 1, child: Text('Actual hours')),
              PopupMenuItem<int>(value: 2, child: Text('Actual woolsacks')),
              PopupMenuItem<int>(value: 3, child: Text('Location')),
              PopupMenuItem<int>(value: 4, child: Text('Youtube')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Difficulty"),
                        Text(_cubit.property.difficulty.toString(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Created at"),
                      Text(
                        _cubit.property.dateCreatedString,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Finished at"),
                        Text(
                          _cubit.property.dateFinishedString,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Estimated hours"),
                      Text(
                        _cubit.property.estimatedHoursString,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Actual hours"),
                        Text(
                          _cubit.property.hoursWorkedString,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Estimated woolsacks"),
                      Text(
                        _cubit.property.estimatedWoolsacksString,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Actual woolsacks"),
                        Text(
                          _cubit.property.actualWoolsacksString,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      _cubit.property.jobs.length,
                      (index) {
                        Job job = _cubit.property.jobs[index];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 2),
                          child: JobItem(
                            job: job,
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
                  Divider(),
                  Text(
                    "Media",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // Two columns
                      ),
                      itemCount: _cubit.property.photos.isEmpty ? 2 : _cubit.property.photos.length,
                      itemBuilder: (BuildContext context, int index) {
                        MediaItem? item;
                        if (index < _cubit.property.photos.length) {
                          item = _cubit.property.photos[index];
                        }
                        return Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: item == null || item.path.isEmpty
                              ? GestureDetector(
                                  onTap: () async {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        TextEditingController controller = TextEditingController(text: item?.path);
                                        return AlertDialog(
                                          title: Text("Add Media"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                                                child: TextField(
                                                  controller: controller,
                                                  textInputAction: TextInputAction.done,
                                                  decoration: InputDecoration(
                                                    labelText: "Media url",
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(false); // Close the dialog
                                              },
                                              child: Text("Cancel"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (_cubit.addMedia(index: index, mediaUrl: controller.text)) {
                                                  if (index == _cubit.property.photos.length - 2) {
                                                    // Add two new items to the photos array
                                                    _cubit.property.photos.add(MediaItem(id: _cubit.property.photos.length, path: ""));
                                                    _cubit.property.photos.add(MediaItem(id: _cubit.property.photos.length, path: ""));
                                                  }
                                                  setState(() {});
                                                }

                                                Navigator.of(context).pop(true); // Close the dialog
                                              },
                                              child: Text("Add"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      barrierColor: const Color.fromARGB(255, 41, 40, 40),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          // key: widget.dialogKey,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(0.0),
                                            side: const BorderSide(color: Colors.black, width: 1),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(0.0),
                                            child: GestureDetector(
                                              onHorizontalDragEnd: (dragEndDetails) {
                                                if ((dragEndDetails.primaryVelocity ?? 0) < 0) {
                                                  if (_currentImageIndexNotifier.value < _cubit.property.photos.length - 3) {
                                                    _imageStreamController.add(_currentImageIndexNotifier.value + 1);
                                                  }
                                                } else if ((dragEndDetails.primaryVelocity ?? 0) > 0) {
                                                  if (_currentImageIndexNotifier.value > 0) {
                                                    _imageStreamController.add(_currentImageIndexNotifier.value - 1);
                                                  }
                                                }
                                              },
                                              child: ValueListenableBuilder<int>(
                                                valueListenable: _currentImageIndexNotifier,
                                                builder: (context, value, child) {
                                                  return AnimatedSwitcher(
                                                    duration: const Duration(milliseconds: 300),
                                                    transitionBuilder: (Widget child, Animation<double> animation) {
                                                      return FadeTransition(
                                                        opacity: animation,
                                                        child: child,
                                                      );
                                                    },
                                                    child: CachedNetworkImage(
                                                      key: ValueKey<int>(value),
                                                      imageUrl: _cubit.property.photos[value].path,
                                                      placeholder: (context, url) => const Center(
                                                        child: SizedBox(
                                                          width: 40,
                                                          height: 40,
                                                          child: CircularProgressIndicator.adaptive(),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: item.path,
                                    progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator.adaptive(value: downloadProgress.progress),
                                    ),
                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
