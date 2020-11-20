import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ShopOwnerModel {
  String userName;
  String phone;
  String shopName;
  String address;
  String city;
  String category;
  String shopImage;
  String description;
  String pan;
  String gst;
  String shopDocId;
  String accountNo;
  String ifscCode;
  bool isVerified;
  String ownerImage;
  String docImage;
  bool isAvailable;
  Timestamp validTill;
  GeoPoint coordinates;

  ShopOwnerModel({
    this.validTill,
    @required this.coordinates,
    this.isAvailable,
    this.city,
    this.shopDocId,
    this.isVerified,
    this.ownerImage,
    this.docImage,
    this.userName,
    this.category,
    this.shopImage,
    this.gst,
    this.shopName,
    this.description,
    this.address,
    this.accountNo,
    this.ifscCode,
    this.pan,
    this.phone,
  });
}
