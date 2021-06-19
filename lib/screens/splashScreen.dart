import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app8/screens/StartShoppingScreen.dart';
import 'package:flutter_app8/screens/loginScreen.dart';
import 'package:flutter_app8/values/SharedPreferenceClass.dart';
import 'package:flutter_app8/values/myConstants.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'BottomNavScreen.dart';

class SplashScreen extends StatefulWidget {
  static String name = 'splash';
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  @override
  void dispose() {
    // TODO: implement dispose
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }
  @override
  void initState() {
    SharedPrefs().priceUnit('');
   // SystemChrome.setEnabledSystemUIOverlays([]);
    //  SharedPrefs().exertedPriceUnit('');
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    animation = Tween(begin: 0.0, end: 250.0).animate(controller)
      ..addListener(() {
        setState(() {
// the state that has changed here is the animation object’s value
        });
      });
  //  controller.forward();

    Timer(Duration(seconds: 3), () {
      /*if (sharedPrefs.getCurrentUserAppOpenTime) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => StartShopping()));
      }
      else*/ if(sharedPrefs.getCurrentUserSignedInStatus)
      {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BottomNavHost('','',-1)));
      }
      else{
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String assetName = 'images/splash.jpeg';
    Image svg = new Image.asset(
      assetName, filterQuality: FilterQuality.high,fit: BoxFit.cover,
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
             children: [

             Container(
               height: MediaQuery.of(context).size.height ,
               child: Container(

                   decoration: BoxDecoration(image: new DecorationImage(


                       alignment: Alignment.center, image: new AssetImage(
                     assetName,
                   ))),


            ),
             ),

        ]),
      ),
    );
  }
}
