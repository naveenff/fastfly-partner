import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:partnerapp/models/orderModel.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> ordersList = [];
  Firestore _db = Firestore.instance;
  bool isLoading = false;
  OrderModel detailOrder;

  void toggleIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  Future<void> getOrders(String cat, String city, String id) async {
    ordersList.clear();
    toggleIsLoading();
    var data = await _db.collection('products').document(cat).collection(city).document(id).collection('orders').getDocuments();
    for (var d in data.documents) {
      ordersList.add(OrderModel(
        buyerName: d.data['buyer_name'],
        buyerAddress: d.data['buyerAddress'],
        buyerPhone: d.data['buyer_number'],
        itemMRP: d.data['item_MRP'],
        itemName: d.data['item_name'],
        itemPrice: d.data['item_price'],
        productQuantity: d.data['product_quantity'],
        orderQuantity: d.data['order_quantity'],
        orderTime: d.data['time'],
        completed: d.data['completed'] ?? false,
        orderDocID: d.data['order_doc_id'],
        shopOrderDocID: d.documentID,
      ));
    }
    ordersList.sort((b, a) {
      return a.orderTime.compareTo(b.orderTime);
    });
    toggleIsLoading();
    notifyListeners();
  }

  Future<void> markOrder(String id, String cat, String city, String shopOrderDocId, String shopId) async {
    toggleIsLoading();
    await _db.collection('orders').document(id).updateData({
      'order_status': 'Ready to Ship',
    });
    await _db.collection('products').document(cat).collection(city).document(shopId).collection('orders').document(shopOrderDocId).updateData({
      'completed': true,
    });
    toggleIsLoading();
    notifyListeners();
  }
}
