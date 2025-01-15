import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:wedolawns/features/property/property_cubit.dart';
import 'package:wedolawns/features/property/property_page.dart';
import 'package:wedolawns/features/property_create/property_create_cubit.dart';
import 'package:wedolawns/features/property_create/property_create_page.dart';
import 'package:wedolawns/features/property_list/property_list_cubit.dart';
import 'package:wedolawns/features/property_list/property_list_page.dart';
import 'package:wedolawns/objects/property.dart';
import 'package:wedolawns/widgets/select_location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: null);
  runApp(Phoenix(child: MyApp()));
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
        inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
      ),
      home: const LoaderOverlay(
        child: MyHomePage(),
      ),
      routes: {
        "/property_create": (context) => BlocProvider.value(
              value: PropertyCreateCubit(),
              child: const PropertyCreatePage(),
            ),
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
        if (settings.name == "/location") {
          GeoPoint? passedGeoPoint = settings.arguments as GeoPoint?;
          return MaterialPageRoute(builder: (context) {
            return SelectLocationPage(
              currentLocation: passedGeoPoint,
            );
          });
        }
        return null;
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: PropertyListCubit()),
        ],
        child: FirebaseAuth.instance.currentUser == null
            ? Scaffold(
                appBar: AppBar(
                  title: Text("Sign in"),
                ),
                body: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Form(
                        key: _formKey,
                        child: AutofillGroup(
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: TextFormField(
                                  controller: _usernameController,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: [AutofillHints.email],
                                  decoration: InputDecoration(
                                    labelText: "Username",
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
                                child: TextFormField(
                                  controller: _passwordController,
                                  textInputAction: TextInputAction.next,
                                  autofillHints: [AutofillHints.password, AutofillHints.newPassword],
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureText ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: _obscureText,
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
                      ),
                      OutlinedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              FocusManager.instance.primaryFocus?.unfocus();
                              context.loaderOverlay.show();
                              UserCredential credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                                email: _usernameController.text,
                                password: _passwordController.text,
                              );
                              context.loaderOverlay.hide();
                              if (credential.user != null) {
                                setState(() {});
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Oops"),
                                      content: Text("Sign in credentials may be incorrect, try again"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(false); // Close the dialog
                                          },
                                          child: Text("Ok"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              context.loaderOverlay.hide();
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Oops"),
                                    content: Text(e.message ?? ""),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(false); // Close the dialog
                                        },
                                        child: Text("Ok"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                        child: Text("Sign in"),
                      ),
                    ],
                  ),
                ),
              )
            : PropertyListPage(),
      ),
    );
  }
}
