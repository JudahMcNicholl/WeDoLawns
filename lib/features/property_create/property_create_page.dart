import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wedolawns/features/property_create/property_create_cubit.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/widgets/add_job_dialog.dart';
import 'package:wedolawns/widgets/color_key.dart';
import 'package:wedolawns/widgets/job_item.dart';

class PropertyCreatePage extends StatefulWidget {
  const PropertyCreatePage({super.key});

  @override
  State<PropertyCreatePage> createState() => _PropertyCreatePageState();
}

class _PropertyCreatePageState extends State<PropertyCreatePage> {
  late PropertyCreateCubit _cubit;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _propertyOwnerController = TextEditingController();
  final TextEditingController _propertyContactController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  final TextEditingController _estWoolsackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PropertyCreateCubit>();
    _latController.text = '0';
    _lonController.text = '0';

    _estWoolsackController.text = '0';

    _difficultyController.text = '0';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PropertyCreateCubit, PropertyCreateState>(
      listener: (context, state) {
        if (state is PropertyCreateStateCreated) {
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
                  title: Text("Create Property"),
                  centerTitle: true,
                ),
                body: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                            child: ColorKeyWidget(
                              isComplete: false,
                              isNew: true,
                              inProgress: false,
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
                                    textInputAction: TextInputAction.next,
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
                                          controller: _propertyOwnerController,
                                          textInputAction: TextInputAction.done,
                                          keyboardType: TextInputType.number,
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
                                          controller: _propertyContactController,
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: "Phone Number",
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "Required";
                                            }
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
                                          keyboardType: TextInputType.number,
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
                                          keyboardType: TextInputType.number,
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
                                              setState(() {
                                                _latController.text = value.latitude.toString();
                                                _lonController.text = value.longitude.toString();
                                              });
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
                                          keyboardType: TextInputType.number,
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
                                          controller: _estWoolsackController,
                                          textInputAction: TextInputAction.next,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            labelText: "Est woolsacks",
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return "Required";
                                            }
                                            return null;
                                          },
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
                                        items: _cubit.items,
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
                          if (_formKey.currentState?.validate() ?? false) {
                            _cubit.createProperty(
                              name: _addressController.text,
                              lat: _latController.text,
                              lon: _lonController.text,
                              difficulty: _difficultyController.text,
                              estWoolsacks: _estWoolsackController.text,
                            );
                          }
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
            ),
          ],
        );
      },
    );
  }
}
