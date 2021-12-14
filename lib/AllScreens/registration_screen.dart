import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/AllScreens/login_screen.dart';
import 'package:rider_app/AllScreens/mainscreen.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/widgets/log_button.dart';
import 'package:rider_app/widgets/progress_dialog_widget.dart';
import 'package:rider_app/widgets/text_field_widget.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegistrationScreen extends StatelessWidget {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  static const screenName = 'Registration Screen';

  TextEditingController nameEditingController = TextEditingController();
  TextEditingController emailEditingController = TextEditingController();
  TextEditingController phoneEditingController = TextEditingController();
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
                'Register as a rider',
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
                        label: 'Name', controller: nameEditingController),
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
                      controller: phoneEditingController,
                      label: 'Phone number',
                      textInputType: TextInputType.phone,
                    ),
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
                      text: 'Register',
                      onPressed: () {
                        validateRegistration(context);
                      },
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    LoginScreen.screenName,
                    (route) => false,
                  );
                },
                child: Text('Already have an Account? Login here'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void registerUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return ProgressDialog(
          message: 'Registering, please wait',
        );
      },
    );
    UserCredential userCredential;
    try {
      userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: emailEditingController.text,
          password: passwordEditingController.text);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
    if (userCredential != null) {
      Map userDataMap = {
        "name": nameEditingController.text.trim(),
        "email": emailEditingController.text.trim(),
        "password": passwordEditingController.text.trim(),
      };
      usersReference.child(userCredential.user.uid).set(userDataMap);
      displayToastMessage('Congratuations, account is successfully created');
      Navigator.pushNamedAndRemoveUntil(
          context, MainScreen.screenName, (route) => false);
    } else {
      Navigator.pop(context);
      displayToastMessage('User has not been created!');
    }
  }

  void validateRegistration(BuildContext context) {
    if (nameEditingController.text.length < 4) {
      displayToastMessage('Name must be more than 3 characters');
    } else if (!(emailEditingController.text.contains('@'))) {
      displayToastMessage('E-mail is not valid');
    } else if (phoneEditingController.text.isEmpty) {
      displayToastMessage('Phone number should be provided');
    } else if (passwordEditingController.text.length < 7) {
      displayToastMessage('Password must be at least 6 characters');
    } else {
      registerUser(context);
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
