import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:partnerapp/models/productModel.dart';

class ProductProvider extends ChangeNotifier {
  Firestore _db = Firestore.instance;
  bool isSaving = false;
  List<ProductModel> productList = [];
  ProductModel editProduct = ProductModel(
    name: '',
    image: [],
    description: '',
    gst: 0,
    mrp: '',
    price: '',
    quantity: '',
    docId: '',
  );

  void toggleIsSaving() {
    isSaving = !isSaving;
    notifyListeners();
  }

  Future<void> getProductList(String cat, String city, String id) async {
    toggleIsSaving();
    productList.clear();
    var data = await _db.collection('products').document(cat).collection(city).document(id).collection('items').getDocuments();
    for (var d in data.documents) {
      productList.add(ProductModel(
          name: d.data['name'],
          description: d.data['description'],
          image: List.from(d.data['image']),
          price: d.data['price'],
          mrp: d.data['mrp'],
          quantity: d.data['quantity'],
          gst: d.data['gst'],
          docId: d.data['docId']));
    }
    print(productList.length);
    toggleIsSaving();
    notifyListeners();
  }

  Future<void> addProduct(ProductModel product, String cat, String city, String id) async {
    toggleIsSaving();
    var res = await _db.collection('products').document(cat).collection(city).document(id).collection('items').add({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'mrp': product.mrp,
      'gst': product.gst,
      'image': product.image,
      'quantity': product.quantity,
      'colors':product.colors,
      'sizes':product.sizes
    });
    await _db.collection('products').document(cat).collection(city).document(id).collection('items').document(res.documentID).updateData({
      'docId': res.documentID,
    });
    toggleIsSaving();
    notifyListeners();
  }

  Future<void> editProductFunc(ProductModel product, String cat, String city, String id) async {
    toggleIsSaving();
    await _db.collection('products').document(cat).collection(city).document(id).collection('items').document(product.docId).updateData({
      'name': product.name,
      'description': product.description,
      'price': product.price,
      'mrp': product.mrp,
      'gst': product.gst,
      'image': product.image,
      'quantity': product.quantity,
    });
    toggleIsSaving();
    notifyListeners();
  }
}
