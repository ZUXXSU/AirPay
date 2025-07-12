import 'dart:convert';
import 'package:airpay_flutter_v4/airpay_package.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:crc32_checksum/crc32_checksum.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../airpay_constants.dart'; // Import the new constants file

class Home extends StatefulWidget {
  final bool isSandbox;
  Home({required this.isSandbox});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // ... (All your existing state variables and text controllers remain the same) ...
  final RegExp _emojiRegex = RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F700}-\u{1F77F}\u{1F780}-\u{1F7FF}\u{1F800}-\u{1F8FF}\u{1F900}-\u{1F9FF}\u{1FA00}-\u{1FA6F}\u{1FA70}-\u{1FAFF}\u{1FAB0}-\u{1FAB6}\u{1FAC0}-\u{1FAC2}\u{1FAD0}-\u{1FAD9}\u{1FADA}-\u{1FADB}\u{1FADC}-\u{1FADD}\u{1FAE0}-\u{1FAE1}\u{1FAE2}-\u{1FAE3}\u{1FAE4}-\u{1FAE5}\u{1FAE6}-\u{1FAE7}\u{1FAE8}-\u{1FAE9}\u{1FAEA}-\u{1FAEB}]', unicode: true);
  final RegExp regex = RegExp(r'[^a-zA-Z]');
  final RegExp email_regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  
  bool isSuccess = false;
  bool isVisible = false;
  bool isSubVisible = false;
  TextEditingController fname = TextEditingController();
  TextEditingController lname = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController country = TextEditingController();
  TextEditingController pincode = TextEditingController();
  TextEditingController orderId = TextEditingController();
  TextEditingController amount = TextEditingController();
  TextEditingController fullAddress = TextEditingController();
  TextEditingController subscription_date = TextEditingController();
  TextEditingController subscription_frequency = TextEditingController();
  TextEditingController subscription_max_amount = TextEditingController();
  TextEditingController subscription_amount = TextEditingController();
  TextEditingController subscription_rec_count = TextEditingController();
  TextEditingController txn_subtype = TextEditingController();
  DateTime selectedDate = DateTime.now().add(Duration(days: 2));
  List<String> subscription_period = ['Day', 'Week', 'Month', 'Year', 'Adhoc'];
  List<String> subscription_retry = ['No', 'Yes'];
  String? dropdownValue;
  String? subRetryValue;

  @override
  void initState() {
    super.initState();
    fname.text = "firstName";
    lname.text = "lastName";
    email.text = "test@gmail.com";
    phone.text = "1234567890";
    fullAddress.text = "testAddress";
    pincode.text = "400001";
    orderId.text = DateTime.now().millisecondsSinceEpoch.toString(); // Generate unique order ID
    amount.text = "1.00";
    city.text = "testCity";
    state.text = "testState";
    country.text = "testCountry";
  }

  // ... (Keep your _showAddress, _showSubscription, _selectDate, and appendDecimal methods as they are) ...
   void _showAddress() {
    setState(() {
      isVisible = !isVisible;
    });
  }

  void _showSubscription() {
    setState(() {
      isSubVisible = !isSubVisible;
    });
  }
   Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().add(Duration(days: 2)),
      lastDate: DateTime(2101), 
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        final formattedDate = DateFormat('dd/MM/yyyy').format(selectedDate.toLocal());
        subscription_date.text = formattedDate;
      });
    }
  }
  
  String appendDecimal(String value) {
    if (value.isEmpty) return "0.00";
    try {
      final number = double.parse(value);
      return number.toStringAsFixed(2);
    } catch (e) {
      return value;
    }
  }


  // FIX: This function correctly generates the checksum as per the documentation
  String _createChecksum(Map<String, dynamic> data) {
    // 1. Sort the keys alphabetically
    final sortedKeys = data.keys.toList()..sort();

    // 2. Combine the values into a single string
    String checksumdata = '';
    for (var key in sortedKeys) {
        if (data[key] != null && data[key].toString().isNotEmpty) {
             checksumdata += data[key].toString();
        }
    }

    // 3. Append the current date in YYYY-MM-DD format
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    checksumdata += today;

    // 4. Compute the SHA-256 hash
    var bytes = utf8.encode(checksumdata);
    var digest = sha256.convert(bytes);

    return digest.toString();
  }

  onComplete(status, response) {
    
    Navigator.pop(context); // Close the payment screen

    var resp = response.toJson();
    print("Airpay Response: $resp");

    var txtStsMsg = resp['STATUSMSG']?.toString() ?? 'N/A';
    var txtSts = resp['TRANSACTIONSTATUS']?.toString() ?? 'N/A';
    
    if (txtStsMsg == 'Invalid Checksum') {
      txtStsMsg = "Transaction Canceled by User or Invalid Checksum";
    }

    var transid = resp['MERCHANTTRANSACTIONID']?.toString() ?? "";
    var apTransactionID = resp['TRANSACTIONID']?.toString() ?? "";
    var amount = resp['TRANSACTIONAMT']?.toString() ?? "";
    var transtatus = resp['TRANSACTIONSTATUS']?.toString() ?? "";
    var message = resp['STATUSMSG']?.toString() ?? "";
    var chmode = resp['CHMOD']?.toString() ?? "";
    var secureHash = resp['AP_SECUREHASH']?.toString() ?? "";

    String customer_vpa_param = "";
    if (chmode.isNotEmpty && chmode == "upi") {
      var customer_vpa = resp['CUSTOMERVPA']?.toString() ?? "";
      customer_vpa_param = ":$customer_vpa";
    }

    final credentials = AirpayConfig.getCredentials(widget.isSandbox);
    var merchantid = credentials['merchantId']!;
    var username = credentials['username']!;
    
    // Verify the response secure hash
    var sParam = '$transid:$apTransactionID:$amount:$transtatus:$message:$merchantid:$username$customer_vpa_param';
    var checkSumResult = Crc32.calculate(sParam);

    if (checkSumResult.toString() == secureHash) {
      Fluttertoast.showToast(msg: "Secure hash matched!");
    } else {
      Fluttertoast.showToast(msg: "Secure hash mismatch!");
    }

    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      desc: 'Transaction Status: $txtSts\nMessage: $txtStsMsg',
      btnOkOnPress: () {},
    ).show();
  }

  void _startPayment() {
    // --- 1. UI Validation ---
    var msg = '';
    if (fname.text.length < 2) {
      msg = 'Enter first name';
    } else if (lname.text.isEmpty) {
      msg = 'Enter last name';
    } else if (email.text.isEmpty || !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9._`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email.text)) {
      msg = "Please enter a valid email";
    } else if (phone.text.isEmpty || phone.text.length < 10) {
      msg = 'Enter a valid phone number';
    } else if (orderId.text.isEmpty) {
      msg = 'Enter order ID';
    } else if (amount.text.isEmpty || double.tryParse(amount.text) == 0) {
      msg = 'Enter a valid amount to proceed';
    }
    // Add other validations as needed

    if (msg.isNotEmpty) {
      AwesomeDialog(context: context, dialogType: DialogType.error, desc: msg, btnOkOnPress: () {}).show();
      return;
    }

    // --- 2. Get Credentials ---
    final credentials = AirpayConfig.getCredentials(widget.isSandbox);
    final String merchantID = credentials['merchantId']!;
    final String kAirPayUserName = credentials['username']!;
    final String kAirPayPassword = credentials['password']!;
    final String kAirPaySecretKey = credentials['secretKey']!; // This is the secret for the privatekey
    final String successURL = credentials['successUrl']!;
    final String failedURL = credentials['failedUrl']!;
    final String client_id = credentials['clientId']!;
    final String client_secret = credentials['clientSecret']!;

    // --- 3. Prepare Data for Checksum ---
    // The keys must match what the SDK uses to build its internal checksum string.
    // Based on the 'Simple Transaction' docs, these are the primary fields.
    Map<String, dynamic> checksumData = {
      'buyer_email': email.text,
      'buyer_phone': phone.text,
      'buyer_firstname': fname.text,
      'buyer_lastname': lname.text,
      'amount': appendDecimal(amount.text),
      'orderid': orderId.text,
      'currency_code': '356', // as per docs
      'iso_currency': 'inr',  // as per docs
      // Only add subscription fields if it's a subscription transaction
      if (txn_subtype.text == "12") ...{
         'sb_nextrundate': subscription_date.text,
         'sb_period': dropdownValue ?? 'D',
         'sb_frequency': subscription_frequency.text,
         'sb_amount': appendDecimal(subscription_amount.text),
         'sb_isrecurring': '1',
         'sb_recurringcount': subscription_rec_count.text,
         'sb_retryattempts': subRetryValue ?? '0',
         'sb_maxamount': appendDecimal(subscription_max_amount.text),
      }
    };
    
    // --- 4. Generate Keys and Checksum ---
    
    // FIX: This 'privatekey' is for the form post in the Simple Transaction Flow.
    var privateKeyBytes = utf8.encode('$kAirPaySecretKey@$kAirPayUserName:|:$kAirPayPassword');
    var privatekey = sha256.convert(privateKeyBytes).toString();

    // FIX: This 'aesDeskey' is the encryption key. The documentation says it's an MD5 hash.
    var encryptionKeyBytes = utf8.encode('$kAirPayUserName~:~$kAirPayPassword');
    var aesDeskey = md5.convert(encryptionKeyBytes).toString();

    // FIX: Correctly call the checksum function.
    String checksum = _createChecksum(checksumData);

    // --- 5. Create UserRequest Object ---
    UserRequest user = UserRequest(
      privatekey: privatekey,
      checksum: checksum,
      mercid: merchantID,
      protoDomain: successURL, // Domain path is just the success/fail URL
      buyerFirstName: fname.text,
      buyerLastName: lname.text,
      buyerEmail: email.text,
      buyerPhone: phone.text,
      buyerAddress: fullAddress.text,
      buyerPinCode: pincode.text,
      orderid: orderId.text,
      amount: appendDecimal(amount.text),
      buyerCity: city.text,
      buyerState: state.text,
      buyerCountry: country.text,
      currency: "356",
      isocurrency: "INR",
      chmod: "",
      customvar: "From Flutter App",
      txnsubtype: txn_subtype.text,
      wallet: "0",
      isStaging: widget.isSandbox,
      successUrl: successURL,
      failedUrl: failedURL,
      appName: "My Flutter App",
      colorCode: '0xFF0D47A1',
      sb_nextrundate: subscription_date.text,
      sb_period: dropdownValue ?? "D",
      sb_frequency: subscription_frequency.text,
      sb_amount: appendDecimal(subscription_amount.text),
      sb_isrecurring: "1",
      sb_recurringcount: subscription_rec_count.text,
      sb_retryattempts: subRetryValue ?? "0",
      sb_maxamount: appendDecimal(subscription_max_amount.text),
      client_id: client_id,
      client_secret: client_secret,
      grant_type: "client_credentials",
      aesDeskey: aesDeskey, // Pass the correctly generated encryption key
    );

    // --- 6. Start Payment ---
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => AirPay(
          user: user,
          closure: (status, response) => onComplete(status, response),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Your build method looks fine, no changes needed here.
    // I'm just replacing the call to ValidateFields with _startPayment.
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset('assets/airpays.png', height: 40, color: Colors.white, width: 200),
          backgroundColor: Colors.blue[900],
        ),
        backgroundColor: Colors.grey[400],
        body: SafeArea(
          child: SingleChildScrollView(
            // ... (Your entire UI widget tree) ...
             child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                 // ... All your cards and text form fields
                 Container(
                   margin: EdgeInsets.all(8.0),
                   child: ElevatedButton(
                     onPressed: () {
                       _startPayment(); // Changed this function call
                     },
                     child: Text('NEXT', style: TextStyle(color: Colors.white, fontSize: 20)),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.blue[900], // A darker blue
                       padding: EdgeInsets.symmetric(vertical: 16),
                     ),
                   ),
                 ),
                 Container(
                   margin: EdgeInsets.all(8.0),
                   child: ElevatedButton(
                     onPressed: () {
                       Navigator.pop(context);
                     },
                     child: Text('BACK', style: TextStyle(color: Colors.white, fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.blue[700],
                       padding: EdgeInsets.symmetric(vertical: 16),
                     ),
                   ),
                 )
              ],
            ),
          ),
        ));
  }
}

// NOTE: You don't need to change `main.dart` or `launch.dart`. They are fine.