import 'dart:io';

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

class AddProducts extends StatefulWidget {
  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final _form = GlobalKey<FormState>();
  bool _isSaving = false;
  File _image;
  final picker = ImagePicker();
  List<String> imageUrl = [];
  List<String> selectedSize = [];
  List<bool> sizeValues = [];
  List<String> colors = [];
  List<Widget> productColors = [];
  String productName = '';
  String color = '';

  TextEditingController _name = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _mrp = TextEditingController();
  TextEditingController _gst = TextEditingController();
  TextEditingController _price = TextEditingController();
  TextEditingController _quantity = TextEditingController();
  TextEditingController colorsController = new TextEditingController();

  Future<String> getImageCamera() async {
    setState(() {
      _isSaving = true;
    });
    final pickedFile = await picker.getImage(source: ImageSource.camera, maxWidth: 500, maxHeight: 500);
    final user = Provider.of<UserProvider>(context, listen: false).userDetail;
    setState(() {
      _image = File(pickedFile.path);
    });
    StorageReference reference =
        FirebaseStorage.instance.ref().child("${user.shopName}/${_name.text}/" + DateTime.now().toString());
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
    StorageReference reference =
        FirebaseStorage.instance.ref().child("${user.shopName}/${_name.text}/" + DateTime.now().toString());
    StorageUploadTask uploadTask = reference.putFile(_image);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      _isSaving = false;
    });
    return url;
  }

  @override
  void initState() {
    super.initState();
    imageUrl.insert(0, '');
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final user = Provider.of<UserProvider>(context).userDetail;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new product'),
        backgroundColor: kBlue2,
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
                    onChanged: (val) {
                      setState(() {
                        productName = val;
                        print(productName);
                      });
                    },
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Pick available sizes below',
                      style: TextStyle(color: kBlue3, fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                  // SizedBox(height: 20),
                  // FittedBox(
                  //   fit: BoxFit.scaleDown,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //     children: <Widget>[
                  //       Checkbox(value: selectedSize.contains('XS'), onChanged: (value) => changeSelectedSize('XS')),
                  //       Text('XS'),
                  //       Checkbox(value: selectedSize.contains('S'), onChanged: (value) => changeSelectedSize('S')),
                  //       Text('S'),
                  //       Checkbox(value: selectedSize.contains('M'), onChanged: (value) => changeSelectedSize('M')),
                  //       Text('M'),
                  //       Checkbox(value: selectedSize.contains('L'), onChanged: (value) => changeSelectedSize('L')),
                  //       Text('L'),
                  //       Checkbox(value: selectedSize.contains('XL'), onChanged: (value) => changeSelectedSize('XL')),
                  //       Text('XL'),
                  //     ],
                  //   ),
                  // ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'Add upto 4 product colors',
                      style: TextStyle(color: kBlue3, fontWeight: FontWeight.w500, fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Container(
                            child: TextFormField(
                              textAlign: TextAlign.center,
                              controller: colorsController,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'enter the available colors',
                                  hintStyle: TextStyle(color: Colors.grey)),
                              // validator: (value) {
                              //   if (value.isEmpty) {
                              //     return 'please enter available colors';
                              //   }
                              //   return null;
                              // },
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: MaterialButton(
                          minWidth: 40,
                          elevation: 0,
                          color: kBlue2,
                          onPressed:
                              // imageUrl.contains('')
                              //     ? () {
                              //         Fluttertoast.showToast(msg: 'Color ${colors[0]} has no image');
                              //       }
                              //     :

                              () async {
                            print(imageUrl.length);
                            imageUrl.insert(0, '');
                            if (colors.contains(colorsController.text)) {
                              colorsController.clear();
                              Fluttertoast.showToast(msg: 'color ${colorsController.text} already added');
                            } else {
                              setState(() {
                                colors.insert(0, colorsController.text);
                                productColors.add(productColor());
                              });
                              Fluttertoast.showToast(msg: 'color ${colorsController.text} added');
                            }
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                          child: Text(
                            'Add color',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Present Colors: ', style: TextStyle(color: kBlue3, fontWeight: FontWeight.w500, fontSize: 16)),
                      // Container(
                      //   height: 20,
                      //   width: 200,
                      //   child: Visibility(
                      //     visible: colors.length > 0,
                      //     child: Center(
                      //       child: ListView.builder(
                      //         shrinkWrap: true,
                      //         primary: false,
                      //         scrollDirection: Axis.horizontal,
                      //         itemCount: colors.length,
                      //         itemBuilder: (BuildContext context, int index) {
                      //           return Text(
                      //             '${colors[index]}, ',
                      //             style: TextStyle(color: Colors.black),
                      //           );
                      //         },
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 10),
                  productColor(),
                  // Text(
                  //   'Upload up to 4 product Colors',
                  //   style: TextStyle(color: kBlue3, fontWeight: FontWeight.w500, fontSize: 16),
                  // ),
                  SizedBox(height: 10),

                  // imageUrl.length <= 0
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //         children: [
                  //           Text('IMG 1', style: TextStyle(color: kBlue3, fontWeight: FontWeight.w700)),
                  //           RaisedButton.icon(
                  //             onPressed: () async {
                  //               String link = await getImageCamera();
                  //               setState(() {
                  //                 imageUrl.add(link);
                  //               });
                  //             },
                  //             icon: Icon(Icons.camera_alt, color: Colors.white),
                  //             label: Text('Camera', style: TextStyle(color: Colors.white)),
                  //             color: kBlue2,
                  //           ),
                  //           RaisedButton.icon(
                  //             onPressed: () async {
                  //               String link = await getImageGallery();
                  //               setState(() {
                  //                 imageUrl.add(link);
                  //               });
                  //             },
                  //             icon: Icon(Icons.image, color: Colors.white),
                  //             label: Text('Gallery', style: TextStyle(color: Colors.white)),
                  //             color: kBlue2,
                  //           ),
                  //         ],
                  //       )
                  //     : Container(
                  //         child: Image(
                  //           image: NetworkImage(imageUrl[0]),
                  //         ),
                  //       ),
                  // SizedBox(height: 10),
                  // imageUrl.length <= 1
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //         children: [
                  //           Text('IMG 2', style: TextStyle(color: kBlue3, fontWeight: FontWeight.w700)),
                  //           RaisedButton.icon(
                  //             onPressed: () async {
                  //               String link = await getImageCamera();
                  //               setState(() {
                  //                 imageUrl.add(link);
                  //               });
                  //             },
                  //             icon: Icon(Icons.camera_alt, color: Colors.white),
                  //             label: Text('Camera', style: TextStyle(color: Colors.white)),
                  //             color: kBlue2,
                  //           ),
                  //           RaisedButton.icon(
                  //             onPressed: () async {
                  //               String link = await getImageGallery();
                  //               setState(() {
                  //                 imageUrl.add(link);
                  //               });
                  //             },
                  //             icon: Icon(Icons.image, color: Colors.white),
                  //             label: Text('Gallery', style: TextStyle(color: Colors.white)),
                  //             color: kBlue2,
                  //           ),
                  //         ],
                  //       )
                  //     : Container(
                  //         child: Image(
                  //           image: NetworkImage(imageUrl[1]),
                  //         ),
                  //       ),
                  // SizedBox(height: 10),
                  // imageUrl.length <= 2
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //         children: [
                  //           Text('IMG 3', style: TextStyle(color: kBlue3, fontWeight: FontWeight.w700)),
                  //           RaisedButton.icon(
                  //             onPressed: () async {
                  //               String link = await getImageCamera();
                  //               setState(() {
                  //                 imageUrl.add(link);
                  //               });
                  //             },
                  //             icon: Icon(Icons.camera_alt, color: Colors.white),
                  //             label: Text('Camera', style: TextStyle(color: Colors.white)),
                  //             color: kBlue2,
                  //           ),
                  //           RaisedButton.icon(
                  //             onPressed: () async {
                  //               String link = await getImageGallery();
                  //               setState(() {
                  //                 imageUrl.add(link);
                  //               });
                  //             },
                  //             icon: Icon(Icons.image, color: Colors.white),
                  //             label: Text('Gallery', style: TextStyle(color: Colors.white)),
                  //             color: kBlue2,
                  //           ),
                  //         ],
                  //       )
                  //     : Container(
                  //         child: Image(
                  //           image: NetworkImage(imageUrl[2]),
                  //         ),
                  //       ),
                  // SizedBox(height: 10),
                  // imageUrl.length <= 3
                  //     ? Row(
                  //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //         children: [
                  //           Text('IMG 4', style: TextStyle(color: kBlue3, fontWeight: FontWeight.w700)),
                  //           RaisedButton.icon(
                  //             onPressed: () async {
                  //               String link = await getImageCamera();
                  //               setState(() {
                  //                 imageUrl.add(link);
                  //               });
                  //             },
                  //             icon: Icon(Icons.camera_alt, color: Colors.white),
                  //             label: Text('Camera', style: TextStyle(color: Colors.white)),
                  //             color: kBlue2,
                  //           ),
                  //           RaisedButton.icon(
                  //             onPressed: () async {
                  //               String link = await getImageGallery();
                  //               setState(() {
                  //                 imageUrl.add(link);
                  //               });
                  //             },
                  //             icon: Icon(Icons.image, color: Colors.white),
                  //             label: Text('Gallery', style: TextStyle(color: Colors.white)),
                  //             color: kBlue2,
                  //           ),
                  //         ],
                  //       )
                  //     : Container(
                  //         child: Image(
                  //           image: NetworkImage(imageUrl[3]),
                  //         ),
                  //       ),
                  SizedBox(height: 20),
                  Container(
                    width: size.width,
                    child: GradientButton(
                      name: 'Add product to shop',
                      onTapFunc: () async {
                        if (_form.currentState.validate() &&
                            imageUrl.length > 0 &&
                            colors.length > 0 &&
                            selectedSize.length > 0) {
                          ProductModel newProd = ProductModel(
                            name: _name.value.text,
                            description: _description.value.text,
                            price: _price.value.text,
                            mrp: _mrp.value.text,
                            gst: int.parse(_gst.value.text),
                            image: imageUrl,
                            quantity: _quantity.value.text,
                            sizes: selectedSize,
                            colors: colors,
                            docId: '',
                          );
                          await productProvider.addProduct(newProd, user.category, user.city, user.shopDocId);
                          Fluttertoast.showToast(msg: 'Product added, Successfully !');
                          Navigator.pushNamed(context, 'home');
                        } else if (imageUrl.length == 0) {
                          Fluttertoast.showToast(msg: 'You need to upload at least 1 image.');
                        } else if (colors.length == 0) {
                          Fluttertoast.showToast(msg: 'You need to pick at least one color.');
                        } else if (selectedSize.length == 0) {
                          Fluttertoast.showToast(msg: 'You need to pick at least one size.');
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

  Widget productColor() {
    return ListView.builder(
      primary: false,
      reverse: false,
      shrinkWrap: true,
      itemCount: colors.length,
      itemBuilder: (BuildContext context, int index) {
        return ExpansionTile(
          title: Text(
            productName.length < 1 ? colors[index] : productName + ' (${colors[index]})' + '',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          children: [
            imageUrl.length <= 0 || imageUrl[index] == ''
                ? Column(
                    children: [
                      Text(colors[index], style: TextStyle(color: kBlue3, fontWeight: FontWeight.w700)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          RaisedButton.icon(
                            onPressed: () async {
                              String link = await getImageCamera();
                              setState(() {
                                imageUrl.add(link);
                                imageUrl.remove('');
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
                                imageUrl.insert(0, link);
                                sizeValues.add(false);
                                imageUrl.remove('');
                              });
                              imageUrl.remove('');
                              print(imageUrl.length);
                            },
                            icon: Icon(Icons.image, color: Colors.white),
                            label: Text('Gallery', style: TextStyle(color: Colors.white)),
                            color: kBlue2,
                          ),
                        ],
                      ),
                    ],
                  )
                : Container(
                    child: Column(
                      children: [
                        Image(
                          image: NetworkImage(imageUrl[index]),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Checkbox(value: selectedSize.contains('XS'), onChanged: (value) => changeSelectedSize('XS')),
                              Text('XS'),
                              Checkbox(value: selectedSize.contains('S'), onChanged: (value) => changeSelectedSize('S')),
                              Text('S'),
                              Checkbox(value: selectedSize.contains('M'), onChanged: (value) => changeSelectedSize('M')),
                              Text('M'),
                              Checkbox(value: selectedSize.contains('L'), onChanged: (value) => changeSelectedSize('L')),
                              Text('L'),
                              Checkbox(value: selectedSize.contains('XL'), onChanged: (value) => changeSelectedSize('XL')),
                              Text('XL'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        );
      },
    );
  }

  void changeSelectedSize(String size) {
    if (selectedSize.contains(size)) {
      setState(() {
        selectedSize.remove(size);
      });
      print(selectedSize);
    } else {
      setState(() {
        selectedSize.insert(0, size);
      });
      print(selectedSize);
    }
  }
}
