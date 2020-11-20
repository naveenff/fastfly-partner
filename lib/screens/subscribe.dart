import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:partnerapp/constants/keys.dart';
import 'package:partnerapp/constants/styles.dart';
import 'package:partnerapp/provider/userProvider.dart';
import 'package:partnerapp/widgets/gradientButton.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Subscribe extends StatefulWidget {
  @override
  _SubscribeState createState() => _SubscribeState();
}

class _SubscribeState extends State<Subscribe> {
  String api = kRazorPayKey;
  FirebaseAuth _auth = FirebaseAuth.instance;
  Razorpay _razorpay;
  bool annual = false;

  void openCheckOut(int amount) async {
    FirebaseUser _user = await _auth.currentUser();
    var options = {
      'key': api,
      'amount': amount * 100,
      'name': 'FastFly',
      'description': 'Membership payment',
      'prefill': {
        'contact': _user.phoneNumber,
      },
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    Fluttertoast.showToast(msg: 'Payment Success');
    Provider.of<UserProvider>(context, listen: false).subscribeUser(annual);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: 'Payment Failed, Try Again');
  }

  void _handleExternalWallet(ExternalWalletResponse response) async {
    Fluttertoast.showToast(msg: 'External Wallet' + response.walletName);
  }

  @override
  void initState() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    super.initState();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Membership'),
        backgroundColor: kBlue2,
      ),
      body: ModalProgressHUD(
        inAsyncCall: userProvider.isLoading,
        child: Container(
          padding: EdgeInsets.all(40),
          child: Column(
            children: [
              Text(
                'Your membership is valid till : ' +
                    userProvider.userDetail.validTill.toDate().day.toString() +
                    '/' +
                    userProvider.userDetail.validTill.toDate().month.toString() +
                    '/' +
                    userProvider.userDetail.validTill.toDate().year.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: kBlue2,
                ),
              ),
              SizedBox(height: 40),
              Container(
                width: MediaQuery.of(context).size.width,
                child: GradientButton(
                  name: 'Renew for 1 month @ ₹ 99',
                  onTapFunc: () {
                    setState(() {
                      annual = false;
                    });
                    openCheckOut(99);
                  },
                ),
              ),
              SizedBox(height: 40),
              Container(
                width: MediaQuery.of(context).size.width,
                child: GradientButton(
                  name: 'Renew for 1 year @ ₹ 999',
                  onTapFunc: () {
                    setState(() {
                      annual = true;
                    });
                    openCheckOut(999);
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
