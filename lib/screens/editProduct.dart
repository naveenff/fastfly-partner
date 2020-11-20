import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:partnerapp/constants/styles.dart';
import 'package:partnerapp/models/productModel.dart';
import 'package:partnerapp/provider/productProvider.dart';
import 'package:partnerapp/provider/userProvider.dart';
import 'package:partnerapp/widgets/gradientButton.dart';
import 'package:provider/provider.dart';

class EditProduct extends StatefulWidget {
  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _form = GlobalKey<FormState>();
  bool _isSaving = false;
  File _image;
  final picker = ImagePicker();
  List<String> imageUrl = [];
  Firestore _db = Firestore.instance;

  TextEditingController _name = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _mrp = TextEditingController();
  TextEditingController _gst = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _quantity = TextEditingController();

  Future<String> getImageCamera() async {
    setState(() {
      _isSaving = true;
    });
    final pickedFile = await picker.getImage(source: ImageSource.camera, maxWidth: 500, maxHeight: 500);
    final user = Provider.of<UserProvider>(context, listen: false).userDetail;
    setState(() {
      _image = File(pickedFile.path);
    });
    StorageReference reference = FirebaseStorage.instance.ref().child("${user.shopName}/${_name.text}/" + DateTime.now().toString());
    StorageUploadTask uploadTask = reference.putFile(_image);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      _isSaving = false;
    });
    return url;
  }

  Future<String> getImageGallery() async {
    setState(() {
      _isSaving = true;
    });
    final pickedFile = await picker.getImage(source: ImageSource.gallery, maxWidth: 500, maxHeight: 500);
    final user = Provider.of<UserProvider>(context, listen: false).userDetail;
    setState(() {
      _image = File(pickedFile.path);
    });
    StorageReference reference = FirebaseStorage.instance.ref().child("${user.shopName}/${_name.text}/" + DateTime.now().toString());
    StorageUploadTask uploadTask = reference.putFile(_image);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      _isSaving = false;
    });
    return url;
  }

  @override
  void initState() {
    final product = Provider.of<ProductProvider>(context, listen: false).editProduct;
    _name.text = product.name;
    imageUrl = product.image;
    _price.text = product.price;
    _mrp.text = product.mrp;
    _description.text = product.description;
    _quantity.text = product.quantity;
    _gst.text = product.gst.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final user = Provider.of<UserProvider>(context).userDetail;
    final size = MediaQuery.of(context).size;
    final product = Provider.of<ProductProvider>(context).editProduct;
    print(product.image.length);
    return Scaffold(
      appBar: AppBar(
        title: Text('Update details'),
        backgroundColor: kBlue2,
        actions: [
          InkWell(
            onTap: () {
              Fluttertoast.showToast(msg: 'Double Tap to add products to offers page');
            },
            onDoubleTap: () async {
              setState(() {
                _isSaving = true;
              });
              await _db.collection('offers').document(user.category).collection(user.city).add({
                'quantity': 1,
                'product_category': user.category,
                'seller_doc_id': user.shopDocId,
                'seller_coordinates': user.coordinates,
                'mrp': product.mrp,
                'image': product.image,
                'seller_name': user.shopName,
                'gst': product.gst,
                'product_name': product.name,
                'price': product.price,
                'product_quantity': product.quantity,
                'seller_address': user.address,
                'seller_city': user.address,
              });
              setState(() {
                _isSaving = false;
              });
              Fluttertoast.showToast(msg: 'Product Added to offers');
            },
            child: Icon(Icons.local_offer),
          ),
          SizedBox(
            width: 20,
          ),
          InkWell(
            child: Icon(Icons.delete_forever),
            onTap: () {
              Fluttertoast.showToast(msg: 'Double Tap to delete this product from shop');
            },
            onDoubleTap: () async {
              setState(() {
                _isSaving = true;
              });
              await _db.collection('products').document(user.category).collection(user.city).document(user.shopDocId).collection('items').document(product.docId).delete();
              Fluttertoast.showToast(msg: 'Item Deleted!');
              setState(() {
                _isSaving = false;
              });
              Navigator.pushNamed(context, 'home');
            },
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isSaving || productProvider.isSaving,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: _name,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: TextStyle(
                        color: kPrimaryColor,
                      ),
                      hintText: 'Enter product name',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue1,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                    ),
                    validator: (nameValue) {
                      if (nameValue.isEmpty) {
                        return 'This field is mandatory';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _description,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(
                        color: kPrimaryColor,
                      ),
                      hintText: 'Enter your business description',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue1,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                    ),
                    validator: (nameValue) {
                      if (nameValue.isEmpty) {
                        return 'This field is mandatory';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _mrp,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Product MRP',
                      labelStyle: TextStyle(
                        color: kPrimaryColor,
                      ),
                      hintText: 'Enter product MRP',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue1,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                    ),
                    validator: (nameValue) {
                      if (nameValue.isEmpty) {
                        return 'This field is mandatory';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _price,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Product Price',
                      labelStyle: TextStyle(
                        color: kPrimaryColor,
                      ),
                      hintText: 'Enter product sales price',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue1,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                    ),
                    validator: (nameValue) {
                      if (nameValue.isEmpty) {
                        return 'This field is mandatory';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _gst,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'GST',
                      labelStyle: TextStyle(
                        color: kPrimaryColor,
                      ),
                      hintText: 'Enter GST % in number',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue1,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                    ),
                    validator: (nameValue) {
                      if (nameValue.isEmpty) {
                        return 'This field is mandatory';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _quantity,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(
                        color: kPrimaryColor,
                      ),
                      hintText: 'Enter product quantity',
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue1,
                          width: 3,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(
                          color: kBlue3,
                          width: 3,
                        ),
                      ),
                    ),
                    validator: (nameValue) {
                      if (nameValue.isEmpty) {
                        return 'This field is mandatory';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 20),
                        child: Column(
                          children: [
                            Image(
                              image: NetworkImage(imageUrl[index]),
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text('Update IMG ${(index + 1).toString()}', style: TextStyle(color: kBlue3, fontWeight: FontWeight.w700)),
                                RaisedButton.icon(
                                  onPressed: () async {
                                    String link = await getImageCamera();
                                    setState(() {
                                      imageUrl[index] = link;
                                    });
                                  },
                                  icon: Icon(Icons.camera_alt, color: Colors.white),
                                  label: Text('Camera', style: TextStyle(color: Colors.white)),
                                  color: kBlue2,
                                ),
                                RaisedButton.icon(
                                  onPressed: () async {
                                    String link = await getImageGallery();
                                    setState(() {
                                      imageUrl[index] = link;
                                    });
                                  },
                                  icon: Icon(Icons.image, color: Colors.white),
                                  label: Text('Gallery', style: TextStyle(color: Colors.white)),
                                  color: kBlue2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                    itemCount: imageUrl.length,
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: size.width,
                    child: GradientButton(
                      name: 'Save Product Details',
                      onTapFunc: () async {
                        if (_form.currentState.validate() && imageUrl.isNotEmpty) {
                          ProductModel newProd = ProductModel(
                            name: _name.value.text,
                            description: _description.value.text,
                            price: _price.value.text,
                            mrp: _mrp.value.text,
                            gst: int.parse(_gst.value.text),
                            image: imageUrl,
                            quantity: _quantity.value.text,
                            docId: productProvider.editProduct.docId,
                          );
                          await productProvider.editProductFunc(newProd, user.category, user.city, user.shopDocId);
                          Fluttertoast.showToast(msg: 'Product updated, Successfully !');
                          Navigator.pushNamed(context, 'home');
                        } else {
                          Fluttertoast.showToast(msg: 'Please fill all the details.');
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
