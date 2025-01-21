import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wedolawns/features/property_edit/property_edit_cubit.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/utils/constants.dart';
import 'package:wedolawns/widgets/add_job_dialog.dart';
import 'package:wedolawns/widgets/color_key.dart';
import 'package:wedolawns/widgets/job_item.dart';

class PropertyEditPage extends StatefulWidget {
  const PropertyEditPage({super.key});

  @override
  State<PropertyEditPage> createState() => _PropertyEditPageState();
}

class _PropertyEditPageState extends State<PropertyEditPage> {
  late PropertyEditCubit _cubit;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _contactOwnerController = TextEditingController();
  final TextEditingController _contactPhoneNumberController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  final TextEditingController _estWoolsackController = TextEditingController();
  final TextEditingController _actualWoolsacksController = TextEditingController();

  final TextEditingController _totalCostController = TextEditingController();
  final TextEditingController _dateFinishedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PropertyEditCubit>();

    _contactOwnerController.text = _cubit.property.contactName;
    _contactPhoneNumberController.text = _cubit.property.contactPhoneNumber;

    _addressController.text = _cubit.property.address;
    _difficultyController.text = _cubit.property.difficulty.toString();

    _latController.text = _cubit.property.location.latitude.toString();
    _lonController.text = _cubit.property.location.longitude.toString();

    _estWoolsackController.text = _cubit.property.estimatedWoolsacks.toString();
    _actualWoolsacksController.text = _cubit.property.actualWoolsacks == null ? "" : _cubit.property.actualWoolsacks.toString();

    _totalCostController.text = _cubit.property.totalCost.toString();
    _dateFinishedController.text = _cubit.property.dateFinished == null ? "" : _cubit.property.dateFinished.toString();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, d) {
        if (didPop) {
          return;
        }
        if (_cubit.hasEdited) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Changes"),
                content: Text("Changes have been made without saving"),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Close the dialog
                    },
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Close the dialog
                      Navigator.of(context).pop(_cubit.originalProperty);
                    },
                    child: Text("Proceed"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _cubit.saveProperty();
                      Navigator.of(context).pop(true); // Close the dialog
                      Navigator.of(context).pop(_cubit.property);
                    },
                    child: Text("Save"),
                  ),
                ],
              );
            },
          );
        } else {
          Navigator.of(context).pop();
        }
      },
      child: BlocConsumer<PropertyEditCubit, PropertyEditState>(
        listener: (context, state) {
          if (state is PropertyEditStateCreated) {
            Navigator.of(context).pop(true);
          }
        },
        buildWhen: (previous, current) {
          return true;
        },
        builder: (context, state) {
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    title: Text("Edit Property"),
                    centerTitle: true,
                  ),
                  body: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
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
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: TextFormField(
                                  controller: _addressController,
                                  textCapitalization: TextCapitalization.sentences,
                                  textInputAction: TextInputAction.done,
                                  onChanged: (value) {
                                    _cubit.property.address = value;
                                  },
                                  decoration: InputDecoration(
                                    labelText: "Address",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _contactOwnerController,
                                        textInputAction: TextInputAction.done,
                                        textCapitalization: TextCapitalization.sentences,
                                        onChanged: (value) {
                                          _cubit.property.contactName = value;
                                        },
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          labelText: "Owner",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Required";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10), // Add space between TextFields
                                    Expanded(
                                      child: TextFormField(
                                        controller: _contactPhoneNumberController,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (value) {
                                          _cubit.property.contactPhoneNumber = value;
                                        },
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: "Phone Number",
                                        ),
                                        validator: (value) {
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        enabled: false,
                                        controller: _latController,
                                        textInputAction: TextInputAction.next,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: "Lat",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Required";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10), // Add space between TextFields
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        enabled: false,
                                        controller: _lonController,
                                        textInputAction: TextInputAction.next,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: "Lon",
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Required";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed("/location").then((value) {
                                          if (value is LatLng) {
                                            // setState(() {
                                            _latController.text = value.latitude.toString();
                                            _lonController.text = value.longitude.toString();
                                            _cubit.property.location = GeoPoint(value.latitude, value.longitude);
                                            // });
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: 48,
                                        width: 48,
                                        decoration: ShapeDecoration(
                                          color: const Color.fromARGB(255, 186, 172, 15),
                                          shape: OvalBorder(),
                                          shadows: [
                                            BoxShadow(
                                              color: const Color(0x00baac0f),
                                              blurRadius: 2,
                                              offset: Offset(0, 2),
                                              spreadRadius: 0,
                                            )
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: SvgPicture.asset(
                                            width: 12,
                                            height: 12,
                                            color: Colors.white,
                                            "assets/svgs/house-regular.svg",
                                            semanticsLabel: 'House-Thin',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _difficultyController,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (value) {
                                          _cubit.property.difficulty = int.tryParse(value) ?? 0;
                                        },
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: "Difficulty",
                                          suffix: Text("/10"),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Required";
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10), // Add space between TextFields
                                    Expanded(
                                      child: TextFormField(
                                        controller: _totalCostController,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (value) {
                                          _cubit.property.totalCost = double.tryParse(value) ?? 0.0;
                                        },
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: "Total cost",
                                          suffix: Text(
                                            "Est ${_cubit.property.estimatedCostString}",
                                            style: TextStyle(color: Colors.grey),
                                          ),
                                        ),
                                        validator: (value) {
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _estWoolsackController,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (value) {
                                          _cubit.property.estimatedWoolsacks = double.tryParse(value) ?? 0.0;
                                        },
                                        keyboardType: TextInputType.datetime,
                                        decoration: InputDecoration(
                                          labelText: "Est Woolsacks",
                                        ),
                                        validator: (value) {
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10), // Add space between TextFields
                                    Expanded(
                                      child: TextFormField(
                                        controller: _actualWoolsacksController,
                                        textInputAction: TextInputAction.done,
                                        onChanged: (value) {
                                          _cubit.property.actualWoolsacks = double.tryParse(value) ?? 0.0;
                                        },
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: "Actual Woolsacks",
                                        ),
                                        validator: (value) {
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          showDatePicker(
                                                  context: context,
                                                  firstDate: DateTime.now().subtract(Duration(days: 365)),
                                                  lastDate: DateTime.now().add(Duration(days: 365)))
                                              .then((value) {
                                            if (value != null) {
                                              _cubit.property.dateFinished = value;
                                              _dateFinishedController.text = _cubit.property.dateFinishedString.toString();
                                            }
                                          });
                                        },
                                        child: TextFormField(
                                          enabled: false,
                                          controller: _dateFinishedController,
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.datetime,
                                          decoration: InputDecoration(
                                            labelText: "Date Finished",
                                          ),
                                          validator: (value) {
                                            return null;
                                          },
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10), // Add space between TextFields
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Text("In Progress"),
                                          Spacer(),
                                          Switch(
                                            // This bool value toggles the switch.
                                            value: _cubit.property.inProgress,
                                            activeColor: Theme.of(context).colorScheme.primary,
                                            onChanged: (bool value) {
                                              // This is called when the user toggles the switch.
                                              setState(() {
                                                _cubit.property.inProgress = value;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Add Job (${_cubit.jobCount})",
                              style: TextStyle(fontSize: 16),
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AddJobDialog(
                                      items: tools,
                                      onAddJob: (name, description, estimatedHours) {
                                        if (_cubit.addJob(name: name, description: description, estimatedHours: estimatedHours)) {
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
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              _cubit.jobs.length,
                              (index) {
                                Job job = _cubit.jobs[index];
                                return JobItem(
                                  job: job,
                                  onDelete: () {
                                    setState(() {
                                      _cubit.removeJob(job);
                                    });
                                  },
                                  onEdit: () {},
                                  onComplete: () {},
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
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
                          onTap: () async {
                            if (_cubit.hasEdited) {
                              await _cubit.saveProperty();
                              setState(() {});
                            }
                          },
                          child: Container(
                            width: 108,
                            height: 108,
                            decoration: BoxDecoration(
                              color: _cubit.hasEdited ? Color(0xFF236002) : Color(0xFF236002).withOpacity(0.3), // Background color
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
              ),
            ],
          );
        },
      ),
    );
  }
}
