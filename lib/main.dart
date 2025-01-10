import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wedolawns/features/property/property_cubit.dart';
import 'package:wedolawns/features/property/property_page.dart';
import 'package:wedolawns/features/property_create/property_create_cubit.dart';
import 'package:wedolawns/features/property_create/property_create_page.dart';
import 'package:wedolawns/features/property_list/property_list_cubit.dart';
import 'package:wedolawns/features/property_list/property_list_page.dart';
import 'package:wedolawns/objects/property.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: 'judahmcnicholl@gmail.com',
    password: 'G%YTG@#f24g',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'We.Do.Lawns',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          ),
          inputDecorationTheme:
              const InputDecorationTheme(border: OutlineInputBorder()),
        ),
        home: const MyHomePage(),
        routes: {
          "/property_create": (context) => BlocProvider.value(
                value: PropertyCreateCubit(),
                child: const PropertyCreatePage(),
              )
        },
        onGenerateRoute: (settings) {
          if (settings.name == "/property") {
            Property property = settings.arguments as Property;
            return MaterialPageRoute(
              builder: (context) {
                return BlocProvider.value(
                  value: PropertyCubit(property),
                  child: const PropertyPage(),
                );
              },
            );
          }
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<PropertyListPageState> _propertyListPageKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("We.Do.Lawns"),
        centerTitle: true,
        leading: Icon(Icons.map_outlined),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.of(context).pushNamed("/property_create").then((value) {
              if (value == true) {
                _propertyListPageKey.currentState?.refetchData();
              }
            });
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: PropertyListCubit()),
        ],
        child: PropertyListPage(key: _propertyListPageKey),
      ),
    );
  }
}
