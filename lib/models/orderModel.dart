import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  String buyerName;
  String buyerPhone;
  String buyerAddress;
  String itemMRP;
  String itemName;
  String itemPrice;
  int orderQuantity;
  String productQuantity;
  Timestamp orderTime;
  bool completed;
  String orderDocID;
  String shopOrderDocID;

  OrderModel({
    this.productQuantity,
    this.shopOrderDocID,
    this.orderDocID,
    this.orderTime,
    this.buyerAddress,
    this.buyerName,
    this.buyerPhone,
    this.itemMRP,
    this.itemName,
    this.itemPrice,
    this.orderQuantity,
    this.completed,
  });
}
