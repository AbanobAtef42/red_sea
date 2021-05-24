import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_app8/generated/l10n.dart';
import 'package:flutter_app8/values/myConstants.dart';

class Styles
 {
   static TextStyle getTextDialogueStyle()
   {
     return TextStyle(color: Colors.white ,fontSize: textDialogueTitleSize);
   }
   static TextStyle getTextAdsStyle()
   {
     return TextStyle(
         color: Colors.black,
         fontSize: textLabelSize,

         fontWeight: FontWeight.bold);

   }
   static ButtonStyle getButtonStyle()
   {
     return ButtonStyle(

       backgroundColor:
       MaterialStateProperty.all<Color>(colorPrimary),
       shape: MaterialStateProperty.all(RoundedRectangleBorder(
           borderRadius: BorderRadiusDirectional.all(Radius.circular(10)))));

   }
   static ButtonStyle getCartButtonStyle()
   {
     return ButtonStyle(

         backgroundColor:
         MaterialStateProperty.all<Color>(colorPrimary),
         shape: MaterialStateProperty.all(RoundedRectangleBorder(
             borderRadius: BorderRadiusDirectional.all(Radius.circular(30)))));

   }
   static ButtonStyle getButtonCheckoutStyle()
   {
     return ButtonStyle(
         overlayColor:  MaterialStateProperty.resolveWith(
         (states) {
       return states.contains(MaterialState.pressed)
           ? Colors.black
           : null;
     }
     ),
         backgroundColor:
         MaterialStateProperty.all<Color>(Colors.white),
         shape: MaterialStateProperty.all(RoundedRectangleBorder(
           side: BorderSide(color: colorPrimary,width: 2.0),
             borderRadius: BorderRadiusDirectional.all(Radius.circular(10)))));

   }
   static Widget getButton( BuildContext context , Widget? child , VoidCallback? onClicked,ButtonStyle buttonStyle)
   {
      return SizedBox(
       width: MediaQuery.of(context).size.width / 1.18,
       height: MediaQuery.of(context).size.height / 19,
       child: ElevatedButton(

         child: child,
         onPressed: onClicked,
         style: buttonStyle,
       ),
     );

   }
   static TextStyle getTextAccountStyle()
   {
     return TextStyle(
         color: Colors.black,
         fontSize: accountTextSize,
         fontWeight: FontWeight.w400,
            );
   }
   static TextAlign getAccountTextAlign()
   {
     return TextAlign.start;
   }
   static TextTheme getAccountTextTheme(BuildContext context)
   {
     return Theme.of(context).primaryTextTheme;
   }
   static TextStyle getTextGreyStyle(BuildContext context)
   {
    return TextStyle(color: Colors.grey[700],fontSize: Theme.of(context).textTheme.headline3!.fontSize!/1.2);
   }
   static AppBar getAppBarStyle(BuildContext context , String title, IconData icon)
   {
     return AppBar(
       centerTitle: true,
       backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: Padding(
          padding: const EdgeInsetsDirectional.only(start :12.0),
          child: IconButton(

              icon: Icon(Icons.arrow_back,color: Colors.black,size: 35,),
          onPressed: ()=> Navigator.pop(context),),
        ),
       toolbarHeight: toolbarHeight,
       title: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children:[
             Icon(icon,color: Colors.white,size: 35,),

             SizedBox(width: 8.0,),
             Text(

               title,
               style: TextStyle(color: Colors.white),
             ),

           ]),
     );
   }
   static AppBar getAppBarStyleSearch(BuildContext context , String title, IconData icon , Icon actionIcon , void callback())
   {
     return AppBar(
       centerTitle: true,
       title: Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children:[
             Icon(icon,color: Colors.white,size: 35,),
             SizedBox(width: 8.0,),
             Text(
                 title
             ),
             Spacer(flex: 4,),
             IconButton(icon: actionIcon, onPressed:()=>callback),
             Spacer(flex: 1,),
           ]),
     );
   }



 }