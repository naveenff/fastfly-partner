import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:partnerapp/constants/styles.dart';
import 'package:partnerapp/provider/userProvider.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isSaving = false;
  File _image;
  final picker = ImagePicker();
  String imageUrl;

  Future getImage() async {
    setState(() {
      _isSaving = true;
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final pickedFile = await picker.getImage(source: ImageSource.gallery, maxWidth: 720, maxHeight: 720);
    setState(() {
      _image = File(pickedFile.path);
    });
    StorageReference reference = FirebaseStorage.instance.ref().child("profileImages/" + userProvider.userDetail.userName + DateTime.now().toString());
    StorageUploadTask uploadTask = reference.putFile(_image);
    String url = await (await uploadTask.onComplete).ref.getDownloadURL();
    setState(() {
      imageUrl = url;
    });
    await userProvider.updateUserImage(url);
    await userProvider.getUserDetail();
    setState(() {
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: kBlue3,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isSaving,
        child: SingleChildScrollView(
          child: Container(
            width: size.width,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(userProvider.userDetail.ownerImage ?? defaultUserPhoto),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: getImage,
                  child: Text(
                    'Update photo',
                    style: TextStyle(color: kBlue3, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 40),
                TextFormField(
                  readOnly: true,
                  initialValue: userProvider.userDetail.userName,
                  decoration: InputDecoration(
                    labelText: 'Name',
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
                ),
                SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  initialValue: userProvider.userDetail.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone',
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
                ),
                SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  initialValue: userProvider.userDetail.address,
                  decoration: InputDecoration(
                    labelText: 'Address',
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
                ),
                SizedBox(height: 20),
                TextFormField(
                  readOnly: true,
                  initialValue: userProvider.userDetail.city,
                  decoration: InputDecoration(
                    labelText: 'City',
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
                ),
//                SizedBox(height: 20),
//                GradientButton(
//                  onTapFunc: () async {
//                    setState(() {
//                      _isSaving = true;
//                    });
//                    //await userProvider.updateUserInfo(_name.value.text, _address.value.text);
//                    await userProvider.getUserDetail();
//                    setState(() {
//                      _isSaving = false;
//                    });
//                  },
//                  name: 'Save Changes',
//                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
