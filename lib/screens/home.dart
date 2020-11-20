import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:partnerapp/constants/styles.dart';
import 'package:partnerapp/provider/productProvider.dart';
import 'package:partnerapp/provider/userProvider.dart';
import 'package:partnerapp/widgets/gradientButton.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseMessaging _fcm = FirebaseMessaging();
  Firestore _db = Firestore.instance;

  Future<bool> _onLogoutPressed() {
    return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Are you sure?',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              content: Text(
                'Do you want to logout',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text('YES'),
                  onPressed: () {
                    _auth.signOut();
                    Navigator.pushNamed(context, 'login');
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Are you sure?',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              content: Text(
                'Do you want to exit the app',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text('NO'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FlatButton(
                  child: Text('YES'),
                  onPressed: () {
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                )
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _saveDeviceToken() async {
    final user = Provider.of<UserProvider>(context, listen: false).userDetail;
    String fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      var tokens = _db.collection('products').document(user.category).collection(user.city).document(user.shopDocId).collection('tokens').document(fcmToken);

      await tokens.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
        'platform': Platform.operatingSystem // optional
      });
    }
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await Provider.of<UserProvider>(context, listen: false).getUserDetail();
      final user = Provider.of<UserProvider>(context, listen: false).userDetail;
      Provider.of<UserProvider>(context, listen: false).checkMembership();
      await Provider.of<ProductProvider>(context, listen: false).getProductList(user.category, user.city, user.shopDocId);
      _saveDeviceToken();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(userProvider.userDetail.shopName ?? 'Shop Name'),
        backgroundColor: kBlue2,
        actions: [
          InkWell(
            child: userProvider.userDetail.isAvailable ? Icon(Icons.visibility) : Icon(Icons.visibility_off),
            onTap: () {
              userProvider.userDetail.isAvailable ? Fluttertoast.showToast(msg: 'Shop is open, Double tap to close') : Fluttertoast.showToast(msg: 'Shop is closed, Double tap to open');
            },
            onDoubleTap: () {
              userProvider.updateShopStatus();
            },
          ),
          SizedBox(width: 20),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          right: false,
          top: false,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(userProvider.userDetail.userName, style: kDrawerUserNameTextStyle),
                          Text(userProvider.userDetail.category, style: kDrawerUserInfoTextStyle),
                          Text(userProvider.userDetail.address, style: kDrawerUserInfoTextStyle),
                          Text(userProvider.userDetail.city, style: kDrawerUserInfoTextStyle),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(userProvider.userDetail.ownerImage ?? defaultUserPhoto),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kBlue3,
                    kBlue2,
                    kBlue1,
                  ],
                )),
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.handHoldingUsd),
                title: Text('Membership'),
                onTap: () {
                  Navigator.pushNamed(context, 'membership');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.shoppingBag),
                title: Text('Orders'),
                onTap: () {
                  Navigator.pushNamed(context, 'orders');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.addressCard),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pushNamed(context, 'profile');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.phoneAlt),
                title: Text('Contact Us'),
                onTap: () {
                  Navigator.pushNamed(context, 'contact');
                },
              ),
              ListTile(
                leading: Icon(FontAwesomeIcons.signOutAlt),
                title: Text('Logout'),
                onTap: _onLogoutPressed,
              ),
            ],
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: ModalProgressHUD(
          inAsyncCall: userProvider.isLoading,
          child: userProvider.isMember
              ? Container(
                  padding: EdgeInsets.all(20),
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      var product = productProvider.productList[index];
                      return Card(
                        elevation: 5,
                        margin: EdgeInsets.only(bottom: 20),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              product.image.isEmpty
                                  ? Container()
                                  : Image(
                                      image: NetworkImage(product.image[0]),
                                      width: 100,
                                      height: 100,
                                    ),
                              Expanded(
                                child: Container(
                                  height: 75,
                                  padding: EdgeInsets.only(left: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(product.name),
                                      Text("₹ " + product.mrp, style: kRedPriceTextStyle),
                                      Text("₹ " + product.price, style: kBluePriceTextStyle),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  productProvider.editProduct = product;
                                  Navigator.pushNamed(context, 'editProduct');
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        kBlue3,
                                        kBlue2,
                                        kBlue1,
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: productProvider.productList.isEmpty ? 0 : productProvider.productList.length,
                  ),
                )
              : Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Text(
                        "Membership Expired",
                        style: TextStyle(fontSize: 20, color: kBlue2, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 40),
                      GradientButton(
                        name: 'Renew Now',
                        onTapFunc: () {
                          Navigator.pushNamed(context, 'membership');
                        },
                      )
                    ],
                  ),
                ),
        ),
      ),
      floatingActionButton: userProvider.userDetail.isAvailable
          ? Padding(
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: FloatingActionButton.extended(
                backgroundColor: kBlue2,
                onPressed: () {
                  Navigator.pushNamed(context, 'addProduct');
                },
                label: Text('  Add new product', style: kUserInfoTextStyle),
                icon: Icon(
                  FontAwesomeIcons.plusCircle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            )
          : Container(),
    );
  }
}
