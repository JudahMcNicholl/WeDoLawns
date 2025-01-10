import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedolawns/features/property/property_cubit.dart';
import 'package:intl/intl.dart';
import 'package:wedolawns/widgets/create_job_dialog.dart';
import 'package:wedolawns/features/property_create/property_create_cubit.dart';
import 'package:wedolawns/objects/objects.dart';
import 'package:wedolawns/widgets/job_item.dart';

class PropertyCreatePage extends StatefulWidget {
  const PropertyCreatePage({super.key});

  @override
  State<PropertyCreatePage> createState() => _PropertyCreatePageState();
}

class _PropertyCreatePageState extends State<PropertyCreatePage> {
  late PropertyCreateCubit _cubit;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _difficultyController = TextEditingController();

  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lonController = TextEditingController();

  final TextEditingController _estDurationController = TextEditingController();
  final TextEditingController _estWoolsackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = context.read<PropertyCreateCubit>();
    _latController.text = '0';
    _lonController.text = '0';

    _estDurationController.text = '0';
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
        return GestureDetector(
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                              child: TextFormField(
                                controller: _addressController,
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: TextFormField(
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
                                  SizedBox(
                                      width:
                                          10), // Add space between TextFields
                                  Expanded(
                                    child: TextFormField(
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
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _estDurationController,
                                      textInputAction: TextInputAction.next,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: "Est Duration",
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return "Required";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                      width:
                                          10), // Add space between TextFields
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
                            TextFormField(
                              controller: _difficultyController,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Difficulty",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Required";
                                }
                                return null;
                              },
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
                                    onAddJob: (name, description) {
                                      if (_cubit.addJob(name, description)) {
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
                              );
                            },
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _cubit.createProperty(
                              name: _addressController.text,
                              lat: _latController.text,
                              lon: _lonController.text,
                              difficulty: _difficultyController.text,
                              estDuration: _estDurationController.text,
                              estWoolsacks: _estWoolsackController.text,
                            );
                          }
                        },
                        child: Text("Create"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
