import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:partnerapp/models/userModel.dart';

class UserProvider extends ChangeNotifier {
  Firestore _db = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String loginPhoneNumber = '';
  bool isVerified;
  double lat;
  double long;
  ShopOwnerModel userDetail = ShopOwnerModel(
    userName: '',
    pan: '',
    phone: '',
    shopName: '',
    address: '',
    city: '',
    coordinates: GeoPoint(0, 0),
    category: '',
    shopImage: '',
    description: '',
    gst: '',
    accountNo: '',
    ifscCode: '',
    isVerified: false,
    ownerImage: '',
    docImage: '',
    isAvailable: true,
    validTill: Timestamp.now(),
  );
  bool isLoading = false;
  bool isMember = true;

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  Future<void> updateUserImage(String url) async {
    await _db.collection('products').document(userDetail.category).collection(userDetail.city).document(userDetail.shopDocId).updateData({
      'owner_photo': url,
    });
  }

  void checkMembership() {
    var till = userDetail.validTill.toDate().add(Duration(days: 5));
    if (till.isBefore(DateTime.now())) {
      isMember = false;
    } else {
      isMember = true;
    }
  }

  Future<void> subscribeUser(bool annual) async {
    toggleIsLoading();
    var data = await _db.collection('shops').getDocuments();
    for (var d in data.documents) {
      if (d.data['phone'] == userDetail.phone) {
        await _db.collection('shops').document(d.documentID).updateData({
          'valid_till': annual ? userDetail.validTill.toDate().add(Duration(days: 365)) : userDetail.validTill.toDate().add(Duration(days: 30)),
        });
      }
    }
    await _db.collection('products').document(userDetail.category).collection(userDetail.city).document(userDetail.shopDocId).updateData({
      'valid_till': annual ? userDetail.validTill.toDate().add(Duration(days: 365)) : userDetail.validTill.toDate().add(Duration(days: 30)),
      'is_active': true,
    });
    getUserDetail();
    toggleIsLoading();
    notifyListeners();
  }

  Future<void> getUserDetail() async {
    toggleIsLoading();
    String cat;
    String city;
    var data = await _db.collection('shops').getDocuments();
    for (var d in data.documents) {
      if (d.data['phone'] == loginPhoneNumber) {
        cat = d.data['category'];
        city = d.data['city'];
      }
    }
    var res = await _db.collection('products').document(cat).collection(city).getDocuments();
    for (var r in res.documents) {
      if (r.data['phone'] == loginPhoneNumber) {
        userDetail = ShopOwnerModel(
          shopDocId: r.documentID,
          coordinates: r.data['coordinates'],
          userName: r.data['owner_name'],
          pan: r.data['pan_number'],
          phone: r.data['phone'],
          shopName: r.data['name'],
          address: r.data['address'],
          city: r.data['city'],
          category: r.data['category'],
          shopImage: r.data['image'],
          description: r.data['description'],
          gst: r.data['gst_number'],
          accountNo: r.data['account_no'],
          ifscCode: r.data['ifsc_code'],
          isVerified: isVerified,
          ownerImage: r.data['owner_photo'],
          docImage: r.data['doc_photo'],
          isAvailable: r.data['is_active'],
          validTill: r.data['valid_till'],
        );
      }
    }
    toggleIsLoading();
    notifyListeners();
  }

  Future<void> updateShopStatus() async {
    toggleIsLoading();
    await _db.collection('products').document(userDetail.category).collection(userDetail.city).document(userDetail.shopDocId).updateData({
      'is_active': !userDetail.isAvailable,
    });
    toggleIsLoading();
    getUserDetail();
    notifyListeners();
  }

  Future<bool> checkUser() async {
    print(loginPhoneNumber);
    var data = await _db.collection('shops').getDocuments();
    for (var d in data.documents) {
      if (d.data['phone'] == loginPhoneNumber) {
        return true;
      }
    }
    return false;
  }

  Future<void> checkUserVerification(String num) async {
    print(num);
    loginPhoneNumber = num;
    var data = await _db.collection('shops').getDocuments();
    for (var d in data.documents) {
      if (d.data['phone'] == num) {
        isVerified = d.data['verified'];
        break;
      }
    }
    notifyListeners();
  }
}
