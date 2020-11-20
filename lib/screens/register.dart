import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:partnerapp/constants/styles.dart';
import 'package:partnerapp/provider/userProvider.dart';
import 'package:partnerapp/widgets/gradientButton.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  Firestore _db = Firestore.instance;
  final _form = GlobalKey<FormState>();

  File _image;
  final picker = ImagePicker();
  String imageUrl = '';
  String profileImageUrl = '';
  String docImageUrl = '';
  String checkImageUrl = '';
  bool _isSaving = false;

  TextEditingController _businessName = TextEditingController();
  TextEditingController _name = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _address = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _gst = TextEditingController();
  TextEditingController _pan = TextEditingController();
  TextEditingController _accNum = TextEditingController();
  TextEditingController _ifsc = TextEditingController();
  TextEditingController _margin = TextEditingController();

  Future<String> _imgFromCamera() async {
    final image = await picker.getImage(source: ImageSource.camera, imageQuality: 10);
    setState(() {
      _image = File(image.path);
    });
    setState(() {
      _isSaving = true;
    });
    StorageReference reference = FirebaseStorage.instance.ref().child("shopImages/${_name.text}/" + DateTime.now().toString());
    StorageUploadTask uploadTask = reference.putFile(_image);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      _isSaving = false;
    });
    return url;
  }

  Future<String> _imgFromGallery() async {
    final image = await picker.getImage(source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = File(image.path);
    });
    setState(() {
      _isSaving = true;
    });
    StorageReference reference = FirebaseStorage.instance.ref().child("shopImages/${_name.text}/" + DateTime.now().toString());
    StorageUploadTask uploadTask = reference.putFile(_image);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      _isSaving = false;
    });
    return url;
  }

  String dropCity = 'Delhi';
  List<String> cityList = ['Delhi', 'Mumbai', 'Chennai'];
  String dropCategory = 'Shopping';
  List<String> categoryList = ['Shopping', 'Electronics', 'Food', 'Gifts and Flowers', 'Grocery', 'Medicines', 'Meat and Fish'];

  Future<void> getLocationList() async {
    setState(() {
      _isSaving = true;
    });
    cityList.clear();
    var data = await _db.collection('locations').getDocuments();
    for (var d in data.documents) {
      cityList.add(d.data['name']);
    }
    setState(() {
      dropCity = cityList[0];
      _isSaving = false;
    });
  }

  Future<void> register() async {
    setState(() {
      _isSaving = true;
    });
    Fluttertoast.showToast(msg: 'Saving details, Please wait.');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await _db.collection('shops').add({
      'owner_name': _name.value.text,
      'phone': userProvider.loginPhoneNumber,
      'owner_photo': profileImageUrl,
      'business_name': _businessName.value.text,
      'category': dropCategory,
      'description': _description.value.text,
      'city': dropCity,
      'address': _address.value.text,
      'shop_photo': imageUrl,
      'gst_number': _gst.value.text,
      'pan_number': _pan.value.text,
      'doc_photo': docImageUrl,
      'account_no': _accNum.value.text,
      'ifsc_code': _ifsc.value.text,
      'verified': false,
      'valid_till': DateTime.now(),
      'is_active': false,
      'margin': _margin.value.text,
      'coordinates': GeoPoint(userProvider.lat, userProvider.long),
      'cancelled_check': checkImageUrl,
    });
    await _db.collection('products').document(dropCategory).collection(dropCity).add({
      'owner_name': _name.value.text,
      'phone': userProvider.loginPhoneNumber,
      'owner_photo': profileImageUrl,
      'name': _businessName.value.text,
      'category': dropCategory,
      'description': _description.value.text,
      'city': dropCity,
      'address': _address.value.text,
      'image': imageUrl,
      'gst_number': _gst.value.text,
      'pan_number': _pan.value.text,
      'doc_photo': docImageUrl,
      'account_no': _accNum.value.text,
      'ifsc_code': _ifsc.value.text,
      'valid_till': DateTime.now(),
      'is_active': false,
      'coordinates': GeoPoint(userProvider.lat, userProvider.long),
    });
    Fluttertoast.showToast(msg: 'Successfully Registered');
    setState(() {
      _isSaving = false;
      Navigator.pushNamed(context, 'home');
    });
  }

  void getLocCor() async {
    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    Provider.of<UserProvider>(context, listen: false).lat = position.latitude;
    Provider.of<UserProvider>(context, listen: false).long = position.longitude;
    print(position.latitude);
    print(position.longitude);
  }

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      getLocationList();
      _phone.text = Provider.of<UserProvider>(context, listen: false).loginPhoneNumber;
    });
    getLocCor();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        leading: InkWell(
          onTap: () {
            _auth.signOut();
            Navigator.pushNamed(context, 'login');
          },
          child: Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isSaving,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text('FastFly Partner Program', style: kSplashTextStyle),
                SizedBox(height: 30),
                Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Step 1 : Tell us about yourself.", style: kRegisterLabelText),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _name,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Owner Name',
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                          ),
                          hintText: 'Enter your name',
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
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone number',
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                          ),
                          hintText: 'Enter your phone number',
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
                      profileImageUrl.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload your photo',
                                  style: TextStyle(fontSize: 14, color: kBlue3, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    RaisedButton.icon(
                                      onPressed: () {
                                        setState(() async {
                                          profileImageUrl = await _imgFromCamera();
                                        });
                                      },
                                      icon: Icon(Icons.camera_alt, color: Colors.white),
                                      label: Text('Camera', style: TextStyle(color: Colors.white)),
                                      color: kBlue2,
                                    ),
                                    RaisedButton.icon(
                                      onPressed: () {
                                        setState(() async {
                                          profileImageUrl = await _imgFromGallery();
                                        });
                                      },
                                      icon: Icon(Icons.image, color: Colors.white),
                                      label: Text('Gallery', style: TextStyle(color: Colors.white)),
                                      color: kBlue2,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  child: Image(
                                    image: NetworkImage(profileImageUrl),
                                  ),
                                ),
                                SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    setState(() async {
                                      profileImageUrl = await _imgFromGallery();
                                    });
                                  },
                                  child: Text(
                                    'Change Photo',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: kBlue3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(height: 20),
                      Text('Step 2 : Tell us about your business.', style: kRegisterLabelText),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _businessName,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Business Name',
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                          ),
                          hintText: 'Enter your business name',
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
                      DropdownButtonFormField(
                        isExpanded: false,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: InputBorder.none,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: kBlue1, width: 3),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: kBlue3, width: 3),
                          ),
                        ),
                        value: dropCategory,
                        items: categoryList.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            dropCategory = value;
                          });
                          print(value);
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
                        controller: _margin,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Margin',
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                          ),
                          hintText: 'Enter your deal margin %',
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
                      imageUrl.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload your store image',
                                  style: TextStyle(fontSize: 14, color: kBlue3, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    RaisedButton.icon(
                                      onPressed: () {
                                        setState(() async {
                                          imageUrl = await _imgFromCamera();
                                        });
                                      },
                                      icon: Icon(Icons.camera_alt, color: Colors.white),
                                      label: Text('Camera', style: TextStyle(color: Colors.white)),
                                      color: kBlue2,
                                    ),
                                    RaisedButton.icon(
                                      onPressed: () {
                                        setState(() async {
                                          imageUrl = await _imgFromGallery();
                                        });
                                      },
                                      icon: Icon(Icons.image, color: Colors.white),
                                      label: Text('Gallery', style: TextStyle(color: Colors.white)),
                                      color: kBlue2,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  child: Image(
                                    image: NetworkImage(imageUrl),
                                  ),
                                ),
                                SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    setState(() async {
                                      imageUrl = await _imgFromGallery();
                                    });
                                  },
                                  child: Text(
                                    'Change Photo',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: kBlue3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(height: 20),
                      DropdownButtonFormField(
                        isExpanded: false,
                        decoration: InputDecoration(
                          labelText: 'City',
                          border: InputBorder.none,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: kBlue1, width: 3),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide(color: kBlue3, width: 3),
                          ),
                        ),
                        value: dropCity,
                        items: cityList.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: 13,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            dropCity = value;
                          });
                          print(value);
                        },
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _address,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                          ),
                          hintText: 'Enter your business address',
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
                      Container(
                        width: size.width,
                        child: GradientButton(
                          name: 'Set Shop Address',
                          onTapFunc: () {
                            Navigator.pushNamed(context, 'map');
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Text('Step 3 : Update your tax details.', style: kRegisterLabelText),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _gst,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'GST Number',
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                          ),
                          hintText: 'Enter your GST number',
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
                        controller: _pan,
                        decoration: InputDecoration(
                          labelText: 'PAN Number',
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                          ),
                          hintText: 'Enter your PAN number',
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
                      docImageUrl.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload your documents',
                                  style: TextStyle(fontSize: 14, color: kBlue3, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    RaisedButton.icon(
                                      onPressed: () {
                                        setState(() async {
                                          docImageUrl = await _imgFromCamera();
                                        });
                                      },
                                      icon: Icon(Icons.camera_alt, color: Colors.white),
                                      label: Text('Camera', style: TextStyle(color: Colors.white)),
                                      color: kBlue2,
                                    ),
                                    RaisedButton.icon(
                                      onPressed: () {
                                        setState(() async {
                                          docImageUrl = await _imgFromGallery();
                                        });
                                      },
                                      icon: Icon(Icons.image, color: Colors.white),
                                      label: Text('Gallery', style: TextStyle(color: Colors.white)),
                                      color: kBlue2,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  child: Image(
                                    image: NetworkImage(docImageUrl),
                                  ),
                                ),
                                SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    setState(() async {
                                      docImageUrl = await _imgFromGallery();
                                    });
                                  },
                                  child: Text(
                                    'Change Photo',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: kBlue3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(height: 20),
                      Text('Step 4 : Update your bank details.', style: kRegisterLabelText),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: _accNum,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: 'Account Number',
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                          ),
                          hintText: 'Enter your account number',
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
                        controller: _ifsc,
                        decoration: InputDecoration(
                          labelText: 'IFSC code',
                          labelStyle: TextStyle(
                            color: kPrimaryColor,
                          ),
                          hintText: 'Enter your IFSC code',
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
                      checkImageUrl.isEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upload a cancelled check',
                                  style: TextStyle(fontSize: 14, color: kBlue3, fontWeight: FontWeight.w500),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    RaisedButton.icon(
                                      onPressed: () {
                                        setState(() async {
                                          checkImageUrl = await _imgFromCamera();
                                        });
                                      },
                                      icon: Icon(Icons.camera_alt, color: Colors.white),
                                      label: Text('Camera', style: TextStyle(color: Colors.white)),
                                      color: kBlue2,
                                    ),
                                    RaisedButton.icon(
                                      onPressed: () {
                                        setState(() async {
                                          checkImageUrl = await _imgFromGallery();
                                        });
                                      },
                                      icon: Icon(Icons.image, color: Colors.white),
                                      label: Text('Gallery', style: TextStyle(color: Colors.white)),
                                      color: kBlue2,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Container(
                                  child: Image(
                                    image: NetworkImage(checkImageUrl),
                                  ),
                                ),
                                SizedBox(height: 10),
                                InkWell(
                                  onTap: () {
                                    setState(() async {
                                      checkImageUrl = await _imgFromGallery();
                                    });
                                  },
                                  child: Text(
                                    'Change Photo',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: kBlue3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      SizedBox(height: 20),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: GradientButton(
                          name: 'Submit',
                          onTapFunc: () {
                            if (imageUrl.isEmpty || profileImageUrl.isEmpty || docImageUrl.isEmpty || checkImageUrl.isEmpty) {
                              Fluttertoast.showToast(msg: 'Please upload all the details.');
                            } else if (_form.currentState.validate()) {
                              register();
                            } else {
                              Fluttertoast.showToast(msg: 'Please fill all the details.');
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
