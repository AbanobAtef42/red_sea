import 'dart:async';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app8/generated/l10n.dart';
import 'package:flutter_app8/models/modelUser.dart';
import 'package:flutter_app8/providers/providerUser.dart';
import 'package:flutter_app8/screens/loginScreen.dart';
import 'package:flutter_app8/styles/buttonStyle.dart';
import 'package:flutter_app8/styles/textFieldStyle.dart';
import 'package:flutter_app8/styles/textWidgetStyle.dart';
import 'package:flutter_app8/validations/validations.dart';
import 'package:flutter_app8/values/api.dart';
import 'package:flutter_app8/values/myApplication.dart';
import 'package:flutter_app8/values/myConstants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  final String? title;

  RegisterScreen({
    this.title,
  });

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passController = new TextEditingController();
  final TextEditingController nameController = new TextEditingController();
  final TextEditingController lNameController = new TextEditingController();
  final TextEditingController confirmPassController =
      new TextEditingController();
  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController addressController = new TextEditingController();
  /*var focusNodeMail = FocusNode();
  var focusNodeName = FocusNode();
  var focusNodeLName = FocusNode();
  var focusNodePhone = FocusNode();
  var focusNodeAddress = FocusNode();
  var focusNodePass = FocusNode();
  var focusNodePassCon = FocusNode();*/
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _visible = false;

  bool isAlwaysShown = true;

  double textFieldsSpacer = 8.0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    scrollBarConfig();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        elevation: 0,
        toolbarHeight: toolbarHeight,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: 25.0,
          ),
          onPressed: () => Navigator.pop(context)),



        backgroundColor: Colors.white,
        title:
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[ Text('Red Sea',style: TextStyle(color: Colors.black,fontSize: 16.0),) ,SizedBox(width: 8.0,),
              Image.asset("assets/redsea2.png",height: 40.0,), ]),),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                Container(
                  //height: MediaQuery.of(context).padding.top,
                  color: Colors.white,
                ),
                Container(
                  height: 100,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Column(children: [

                    Row(
                      children: [
                        SizedBox(
                          width: 12.0,
                        ),
                       /* Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(60.0)),
                            onTap: () => Navigator.pop(context),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.only(start: 8.0),
                              child: Icon(
                                CupertinoIcons.back,
                                color: Colors.black,
                                size: 35,
                              ),
                            ),
                          ),
                        ),

                        Spacer(),*/
                        /*Padding(
                          padding: const EdgeInsets.only(
                              top: 30.0),
                          child: MyTextWidgetLabel(
                              S.of(context).registerLabel,
                              "label",
                              colorBorder,
                              14.0),
                        ),*/
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Visibility(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height /
                                registerTopViewHeight,
                            width: MediaQuery.of(context).size.height /
                                registerTopViewHeight,
                            child: Theme(
                              data: Theme.of(context)
                                  .copyWith(accentColor: Colors.black),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          visible: _visible,
                        ),

                      ],
                    ),
                  ]),
                ),
                Expanded(
                  child: RawScrollbar(
                    thumbColor: colorPrimary,
                    isAlwaysShown: isAlwaysShown,
                    child: SingleChildScrollView(
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight:
                                    Radius.circular(columnRegisterBorderRadius),
                                topLeft: Radius.circular(
                                    columnRegisterBorderRadius)),
                            color: Colors.white),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            /*Padding(
                              padding: const EdgeInsets.only(
                                  top: textRegisterLabelPadding),
                              child: MyTextWidgetLabel(
                                  S.of(context).registerLabel,
                                  "label",
                                  colorBorder,
                                  textLabelSize),
                            ),*/
                            SizedBox(
                                height: 10.0),
                            MyTextField(
                                nameController,
                                S.of(context).name,
                                Icons.person,
                                false,
                                " ",
                                true,
                                TextInputType.name),
                            SizedBox(
                                height: textFieldsSpacer),
                            MyTextField(
                                lNameController,
                                S.of(context).lName,
                                Icons.person,
                                false,
                                " ",
                                true,
                                TextInputType.name),
                            SizedBox(
                                height: textFieldsSpacer),
                            MyTextField(
                                emailController,
                                S.of(context).email,
                                Icons.email,
                                false,
                                " ",
                                true,
                                TextInputType.emailAddress),
                            SizedBox(
                                height: textFieldsSpacer),
                            MyTextField(
                                passController,
                                S.of(context).password,
                                CupertinoIcons.eye_fill,
                                true,
                                "*",
                                true,
                                TextInputType.visiblePassword),
                            SizedBox(
                                height: textFieldsSpacer),
                            MyTextField(
                                confirmPassController,
                                S.of(context).confirmPassword,
                                CupertinoIcons.eye_fill,
                                true,
                                "*",
                                true,
                                TextInputType.visiblePassword),
                            SizedBox(
                                height: textFieldsSpacer),
                            MyTextField(
                                phoneController,
                                S.of(context).phone,
                                Icons.phone_android,
                                false,
                                " ",
                                true,
                                TextInputType.phone),
                            SizedBox(
                                height: textFieldsSpacer),
                            MyTextField(
                                addressController,
                                S.of(context).address,
                                Icons.location_on,
                                false,
                                " ",
                                false,
                                TextInputType.streetAddress),
                            SizedBox(
                                height: MediaQuery.of(context).size.height /
                                    textFieldButtonDivider),
                            MyButton(
                              onClicked: () => onButtonClick(),
                              child: Text(S.of(context).register),
                            ),
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 19.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _register(String name, String lName, String eMail, String password,
      String phone, String address) async {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    final FormState? form = _formKey.currentState;
    final Api api = Api();
    if (passController.text != confirmPassController.text) {
      /*Fluttertoast.showToast(
          msg: S.of(context).diffPasses,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/
      MyApplication.getDialogue(
          context, S.of(context).diffPasses, '', DialogType.ERROR);
      return;
    }
    if (form!.validate()) {
      setState(() {
        _visible = true;
      });
      ProviderUser.eMail = eMail;
      ProviderUser.password = password;
      ProviderUser.name = name;
      ProviderUser.lName = lName;
      ProviderUser.phone = phone;
      ProviderUser.address = address;
      final provider = Provider.of<ProviderUser>(context, listen: false);
      await provider.getPostRegisterData(context);

      setState(() {
        _visible = false;
      });

      if (provider.modelUser2 != null &&
          provider.modelUser2!.message == 'success') {
        Fluttertoast.showToast(
            msg: S.of(context).registered,
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: colorPrimary,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM);
//        User? user = provider.modelUser!.user;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => LoginScreen(
                    title: S.of(context).login,
                  )),
        );
      }
    } else {
      final snackBar = SnackBar(content: Text(S.of(context).fillIn));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  /*void validateAndSave() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      print('Form is valid');
    } else {
      print('Form is invalid');
    }
  }*/
  onButtonClick() async {
    Api.context = context;
    if (!_visible) {
      if (await MyApplication.checkConnection()) {
        _register(
            nameController.text.trim(),
            lNameController.text.trim(),
            emailController.text,
            passController.text,
            phoneController.text.trim(),
            addressController.text.trim());
      } else {
        /*Fluttertoast.showToast(
          msg: 'No Internet Connection',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/
        MyApplication.getDialogue(context, S.of(context).registerFailed,
            S.of(context).noInternet, DialogType.ERROR);
      }
    }
  }

  scrollBarConfig() {
    if (isAlwaysShown) {
      Timer.periodic(Duration(milliseconds: 2100), (timer) {
        if (this.mounted) {
          setState(() {
            isAlwaysShown = false;
          });
        }
      });
    }
  }
}
