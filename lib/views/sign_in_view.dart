import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stockapp/global.dart' as globals;


final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();

/// The view for signing in
class SignInView extends StatefulWidget {
  @override
  SignInState createState() => new SignInState();
}

/// Controls the State of the SignInView
class SignInState extends State<SignInView> {
  TextEditingController emailController;
  TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = new TextEditingController();
    passwordController = new TextEditingController();
  }

  /// Signs the user in using google
  Future<FirebaseUser> _signInWithGoogle() async {
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final FirebaseUser user = await _auth.signInWithGoogle(
      idToken: googleAuth.idToken,
      accessToken: googleAuth.accessToken,
    );

    print("signed in " + user.displayName);
    globals.user = user;
    globals.uid = user.uid;
    Navigator.of(context).pushReplacementNamed('/home');

    return user;
  }

  /// Signs the user in with email
  Future<FirebaseUser> _signInWithEmail() async {
    String email = emailController.text;
    List<String> providers = await _auth.fetchProvidersForEmail(email: email);

    providers.forEach((String p) {print(p);});

    FirebaseUser user;

    try {
      /// Attempts to sign the user in
      user = await _auth.signInWithEmailAndPassword(
          email: email, password: passwordController.text);
    } catch(e){
      /// Creates a new user if sign in fails
      user = await _auth.createUserWithEmailAndPassword(email: email, password: passwordController.text);
    }

    print("signed in " + user.displayName);
    Navigator.of(context).pushReplacementNamed('/home');
    
    return user;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Sign in Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * .05,
            ),
            Card(
              child: ExpansionTile(
                title: Text('Google'),
                children: <Widget>[
                  MaterialButton(
                    child: Text('Sign In'),
                    onPressed: _signInWithGoogle,
                    color: Colors.grey,
                  )
                ],
              ),
            ),
            Card(
              child: ExpansionTile(
                title: Text('Email'),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 100.0,
                        child: Text('email'),
                      ),
                      Flexible(
                        child: TextField(
                          onChanged: (String text) {
                            emailController.text = text;
                          },
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        width: 100.0,
                        child: Text('password'),
                      ),
                      Flexible(
                        child: TextField(
                          obscureText: true,
                          onChanged: (String text) {
                            passwordController.text = text;
                          },
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  RaisedButton(
                    child: Text('Sign In'),
                    onPressed: _signInWithEmail,
                    color: Colors.grey,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
