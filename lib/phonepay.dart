import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
 
  String checkSum = "";
 String saltKey = "099eb0cd-02cf-4e2a-8aca-3e6c6aff0399"; // Replace with your actual salt key
  String saltIndex = "1"; 
  String callbackUrl  = "https://www.google.com/";
  String body = "";
  Object? result;
  String apiEndPoint = "/pg/v1/pay";

  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    phonepeInti();
    body =  getCheckSum().toString();
    setState(() {
      
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height/1,
        child: 
        Center(
          child: ElevatedButton(onPressed: (){
              StartPGTransaction();          }, child: Text("Pay Now")) ,
        ),
      ),
    );
  }
  
  void phonepeInti() async{
    
    PhonePePaymentSdk.init('SANDBOX', "", "PGTESTPAYUAT", true)
        .then((val) => {
              setState(() {
                result = 'PhonePe SDK Initialized - $val';
              })
            })
        .catchError((error) {
      handleError(error);
      return <dynamic>{};
    });
  }
  
  void handleError(error) {
    setState(() {
      result = {'error':  error};
    });
  }

  void StartPGTransaction() async{
    try {
      var response = PhonePePaymentSdk.startTransaction(body, callbackUrl, checkSum, "");
      response.then((val) {
        setState(() {
        log(val.toString());
        if(val != null){
            String status = val['status'].toString();
            String error = val['status'].toString();
            if(status == "SUCCESS"){
              result = "Payment Done";
            }else{
              result = "Payment Failed - $status, Error-> $error";
            }
        }
        else{
          result = "Flow Incompleted";
        }                  
        });
      });
      
    } catch (error) {
       handleError(error);
    }
  }
//  "merchantId": "PGTESTPAYUAT",
//   "merchantTransactionId": "transaction_123",
//   "merchantUserId": "90223250",
  getCheckSum(){
  final requetData = {
  "merchantId": "PGTESTPAYUAT",
 "merchantTransactionId": "MT7850590068188104",
  "merchantUserId": "MUID123",
  "amount": 100,
  "mobileNumber": "9999999999",
  "callbackUrl": callbackUrl,
  "paymentInstrument": {
    "type": "PAY_PAGE",
    
  },
  };
  String base64Body = base64.encode(utf8.encode(json.encode(requetData)));
  checkSum = "${sha256.convert(utf8.encode(base64Body+apiEndPoint+saltKey)).toString()}###$saltIndex";
  return base64Body;
  }
}