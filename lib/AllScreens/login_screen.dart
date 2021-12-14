import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider_app/AllScreens/mainscreen.dart';
import 'package:rider_app/AllScreens/registration_screen.dart';
import 'package:rider_app/widgets/log_button.dart';
import 'package:rider_app/widgets/progress_dialog_widget.dart';
import 'package:rider_app/widgets/text_field_widget.dart';

import '../main.dart';

class LoginScreen extends StatelessWidget {
  static const screenName = 'Login Screen';

  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  TextEditingController emailEditingController = TextEditingController();
  TextEditingController passwordEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SizedBox(
                height: 35.0,
              ),
              Image(
                image: AssetImage('assets/images/logo.png'),
                height: 252.0,
                width: 390.0,
                alignment: Alignment.center,
              ),
              SizedBox(
                height: 1.0,
              ),
              Text(
                'Login as a rider',
                style: TextStyle(fontSize: 24.0, fontFamily: 'Brand Bold'),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 1.0,
                    ),
                    textFieldWidget(
                        controller: emailEditingController,
                        label: 'E-mail',
                        textInputType: TextInputType.emailAddress,
                        isObsecure: false),
                    SizedBox(
                      height: 1.0,
                    ),
                    textFieldWidget(
                      controller: passwordEditingController,
                      label: 'Password',
                      isObsecure: true,
                    ),
                    SizedBox(
                      height: 6.0,
                    ),
                    LogButton(
                      text: 'Login',
                      onPressed: () {
                        validateLogin(context);
                      },
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RegistrationScreen.screenName,
                    (route) => false,
                  );
                },
                child: Text('Do not have an Accoun? Register here'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void validateLogin(BuildContext context) {
    if (!(emailEditingController.text.contains('@'))) {
      displayToastMessage('E-mail is not valid');
    } else if (passwordEditingController.text.length < 7) {
      displayToastMessage('Password must be at least 6 characters');
    } else {
      loginAndAuthenticateUser(context);
    }
  }

  void loginAndAuthenticateUser(BuildContext context) async { 
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ProgressDialog(message: 'Authenticating, Please wait',);
      },
    );
    UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.signInWithEmailAndPassword(
          email: emailEditingController.text,
          password: passwordEditingController.text);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
    if (userCredential != null) {
      usersReference.child(userCredential.user.uid).once().then(
        (DataSnapshot snapshot) {
          if (snapshot.value != null) {
            displayToastMessage('You are logged in');
            Navigator.pushNamedAndRemoveUntil(
                context, MainScreen.screenName, (route) => false);
          } else {
            Navigator.pop(context);
            _firebaseAuth.signOut();
            displayToastMessage('login failed');
          }
        },
      );
    } else {
      displayToastMessage('Error occured while signing in');
    }
  }
 
  void displayToastMessage(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_SHORT);
  }
}
