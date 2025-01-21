import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wedolawns/features/property/property_cubit.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/objects/property.dart';
import 'package:wedolawns/widgets/add_job_dialog.dart';
import 'package:wedolawns/widgets/color_key.dart';
import 'package:wedolawns/widgets/edit_job_dialog.dart';
import 'package:wedolawns/widgets/job_item.dart';
import 'package:wedolawns/widgets/left_right_item.dart';

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
            TextEditingController hoursController = TextEditingController(text: _cubit.property.hoursWorkedString);
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            TextEditingController controller = TextEditingController(text: _cubit.property.hoursWorkedString);
            return AlertDialog(
              title: Text("Set Actual hours"),
              content: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 4),
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                    // if (_cubit.updateActualHours(hoursWorked: controller.text)) {
                    //   setState(() {});
                    // }

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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: SingleChildScrollView(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                              leftText: "Est/Hours Spent",
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
                              leftText: "Est/Woolsacks",
                              rightText: _cubit.property.woolsacksConcatenatedString,
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
                                          onPressed: () {
                                            if (_cubit.completeJob(job, controller.text)) {
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
                    Divider(),
                    Text(
                      "Media",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true, // Makes the GridView take only as much height as its children
                      physics: NeverScrollableScrollPhysics(), // Disables scrolling
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
                              ? Center(
                                  child: IconButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          TextEditingController controller = TextEditingController(
                                              text: false
                                                  ? "https://drive.google.com/file/d/18aYI5EHJ0WeAHVcnt31mZlce-b_L5JU6/view?usp=drive_link"
                                                  : item?.path);
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
                                                  if (_cubit.addMedia(
                                                    index: index,
                                                    mediaUrl: controller.text,
                                                    // heicUrl: heicController.text,
                                                  )) {
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
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    _imageStreamController.add(index);
                                    showDialog(
                                      barrierColor: const Color.fromARGB(255, 41, 40, 40),
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
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
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CachedNetworkImage(
                                          imageUrl: item.path,
                                          progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
                                                width: 12,
                                                height: 12,
                                                child: CircularProgressIndicator.adaptive(value: downloadProgress.progress),
                                              ),
                                          errorWidget: (context, url, error) {
                                            return Icon(Icons.error);
                                          }),
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: IconButton(
                                          onPressed: () {
                                            if (_cubit.deleteMedia(index: index)) {
                                              setState(() {});
                                            }
                                          },
                                          icon: Icon(Icons.delete, color: const Color.fromARGB(255, 220, 67, 56)),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: IconButton(
                                          onPressed: () {
                                            if (_cubit.swapMedia(index: index)) {
                                              setState(() {});
                                            }
                                          },
                                          icon: Icon(Icons.swap_horiz, color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        );
                      },
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
