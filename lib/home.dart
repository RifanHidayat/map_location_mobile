import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';

import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var latitude = "", longitude = "", currentAddress = "";
  Position? currentPosition;
  var isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Latitude : ${latitude}",
              textAlign: TextAlign.center,
            ),
            Text("Longitude : ${longitude}", textAlign: TextAlign.center),
            Text("Current Address : ${currentAddress}",
                textAlign: TextAlign.center),
            const SizedBox(
              height: 20,
            ),
            isLoading == true
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: () {
                      getCurrentLocation();
                      sendData();
                    },
                    child: const Text('Send Data'),
                  ),
          ],
        ),
      ),
    );
  }

  getCurrentLocation() {
    Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        currentPosition = position;
        latitude = currentPosition!.latitude.toString();
        longitude = currentPosition!.longitude.toString();
      });

      getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }

  getAddressFromLatLng() async {
    try {
      List<Placemark> p = await Geolocator().placemarkFromCoordinates(
          currentPosition?.latitude, currentPosition?.longitude);

      Placemark place = p[0];

      setState(() {
        currentAddress =
            "${place.locality}, ${place.postalCode}, ${place.country}";
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendData() async {
    final base_url = "http://192.168.43.91:8000";
    setState(() {
      isLoading = true;
    });
    try {
      var response = await http.post(Uri.parse("${base_url}/location"), body: {
        "address": currentAddress,
        "latitude": latitude.toString(),
        "longitude": longitude.toString()
      });
      var data = jsonDecode(response.body);
      print(data);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
            msg: data['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          isLoading = false;
        });
      } else {
        Fluttertoast.showToast(
            msg: data['message'],
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(
          msg: e.toString(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0);
      setState(() {
        isLoading == false;
      });
    }
    // if (isTrack == true)  {
    // await FirebaseFirestore.instance
    //     .collection('location')
    //     .doc('1')
    //     .update({
    //   "address": currentAddress,
    //   "latitude": latitude.toString(),
    //   "longitude": longitude.toString()
    // }).then((result) {
    //   print("new USer true");
    // }).catchError((onError) {
    //   print("onError ${onError}");
    // });
    // // } else {
    // //   print("no tra");
    // // }
  }
}
