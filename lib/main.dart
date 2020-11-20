import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:partnerapp/functions/otpVerify.dart';
import 'package:partnerapp/provider/orderProvvider.dart';
import 'package:partnerapp/provider/productProvider.dart';
import 'package:partnerapp/provider/userProvider.dart';
import 'package:partnerapp/screens/addProducts.dart';
import 'package:partnerapp/screens/contact.dart';
import 'package:partnerapp/screens/editProduct.dart';
import 'package:partnerapp/screens/home.dart';
import 'package:partnerapp/screens/login.dart';
import 'package:partnerapp/screens/mapScreen.dart';
import 'package:partnerapp/screens/orderDetails.dart';
import 'package:partnerapp/screens/orders.dart';
import 'package:partnerapp/screens/pending.dart';
import 'package:partnerapp/screens/profile.dart';
import 'package:partnerapp/screens/register.dart';
import 'package:partnerapp/screens/splash.dart';
import 'package:partnerapp/screens/subscribe.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage : $message");
//        final snackBar = SnackBar(
//          content: Text(message['notification']['title']),
//          action: SnackBarAction(
//            label: "Done",
//            onPressed: () => null,
//          ),
//        );
//        Scaffold.of(context).showSnackBar(snackBar);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: ListTile(
              title: Text(message['notification']['title']),
              subtitle: Text(message['notification']['body']),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume : $message");
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch : $message");
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(),
        ),
      ],
      child: MaterialApp(
        home: AnimatedSplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          'login': (context) => Login(),
          'home': (context) => Home(),
          'register': (context) => Register(),
          'otp': (context) => OtpVerify(),
          'pending': (context) => Pending(),
          'addProduct': (context) => AddProducts(),
          'editProduct': (context) => EditProduct(),
          'profile': (context) => Profile(),
          'orders': (context) => Orders(),
          'orderDetails': (context) => OrderDetails(),
          'contact': (context) => Contact(),
          'membership': (context) => Subscribe(),
          'map': (context) => MapScreen(),
        },
      ),
    );
  }
}
