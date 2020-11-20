import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partnerapp/constants/styles.dart';
import 'package:partnerapp/provider/userProvider.dart';
import 'package:provider/provider.dart';

class AnimatedSplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => new SplashScreenState();
}

class SplashScreenState extends State<AnimatedSplashScreen> with SingleTickerProviderStateMixin {
  FirebaseAuth _auth = FirebaseAuth.instance;
  AnimationController animationController;
  Animation<double> animation;

  void navigationPage() async {
    FirebaseUser user = await _auth.currentUser();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (user != null) {
      await userProvider.checkUserVerification(user.phoneNumber);
      if (userProvider.isVerified == true) {
        Navigator.pushNamed(context, 'home');
      } else if (userProvider.isVerified == false) {
        Navigator.pushNamed(context, 'pending');
      } else {
        Navigator.pushNamed(context, 'register');
      }
    } else {
      Navigator.pushNamed(context, 'login');
    }
  }

  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigationPage);
  }

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(vsync: this, duration: new Duration(seconds: 2));
    animation = new CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    animation.addListener(() => this.setState(() {}));
    animationController.forward();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/logo.png',
                    width: animation.value * 250,
                    height: animation.value * 250,
                  ),
                ),
                Text(
                  'FastFly Partner App',
                  style: kSplashTextStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
