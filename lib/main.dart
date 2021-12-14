import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/AllScreens/login_screen.dart';
import 'package:rider_app/AllScreens/mainscreen.dart';
import 'package:rider_app/AllScreens/registration_screen.dart';
import 'package:rider_app/AllScreens/search_screen.dart';
import 'package:rider_app/providers/app_data.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference usersReference =
    FirebaseDatabase.instance.reference().child('users');

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider.value(value: AppData())],
      child: MaterialApp(
        title: 'Taxi Rider App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: FirebaseAuth.instance.currentUser == null
            ? LoginScreen.screenName
            : MainScreen.screenName, //LoginScreen.screenName,
        debugShowCheckedModeBanner: false,
        routes: {
          RegistrationScreen.screenName: (context) => RegistrationScreen(),
          LoginScreen.screenName: (context) => LoginScreen(),
          MainScreen.screenName: (context) => MainScreen(),
          SearchScreen.screenName: (context) => SearchScreen(),
        },
      ),
    );
  }
}
