import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:partnerapp/constants/styles.dart';

class Pending extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Your details are being verified, We will update you once it\'s done',
              style: TextStyle(
                fontSize: 24,
                color: kBlue3,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 50),
            Icon(
              FontAwesomeIcons.hourglassHalf,
              size: 100,
              color: kBlue3,
            ),
          ],
        ),
      ),
    );
  }
}
