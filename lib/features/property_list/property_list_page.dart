import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedolawns/features/property_list/property_list_cubit.dart';
import 'package:wedolawns/objects/property.dart';

class PropertyListPage extends StatefulWidget {
  const PropertyListPage({super.key});

  @override
  State<PropertyListPage> createState() => PropertyListPageState();
}

class PropertyListPageState extends State<PropertyListPage> {
  late PropertyListCubit _cubit;
  @override
  void initState() {
    super.initState();
    _cubit = context.read<PropertyListCubit>();

    _cubit.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PropertyListCubit, PropertyListState>(
      buildWhen: (previous, current) {
        return current is PropertyListStateLoaded ||
            current is PropertyListStateInitial;
      },
      builder: (context, state) {
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
                  trailing: Icon(Icons.arrow_forward),
                  isThreeLine: false,
                  tileColor: const Color.fromARGB(57, 50, 99, 48),
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed("/property", arguments: property);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  refetchData() {
    setState(() {
      _cubit.initialize();
    });
  }
}
