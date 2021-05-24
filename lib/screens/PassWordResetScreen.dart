import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app8/generated/l10n.dart';
import 'package:flutter_app8/providers/providerUser.dart';
import 'package:flutter_app8/styles/buttonStyle.dart';
import 'package:flutter_app8/styles/styles.dart';
import 'package:flutter_app8/styles/textFieldStyle.dart';
import 'package:flutter_app8/styles/textWidgetStyle.dart';
import 'package:flutter_app8/values/myApplication.dart';
import 'package:flutter_app8/values/myConstants.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/maki_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart' as intl;
import 'package:shared_preferences/shared_preferences.dart';

import '../values/myConstants.dart';

class PassWordReset extends StatefulWidget {
  @override
  _PassWordResetState createState() => _PassWordResetState();
}

class _PassWordResetState extends State<PassWordReset> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  double _ignored = 0.0;
  final TextEditingController passController = new TextEditingController();
  final TextEditingController passConController = new TextEditingController();

  var _textDirection;
  @override
  Widget build(BuildContext context) {
    return getAppWidget();
  }

  getAppWidget() {
    if (_textDirection == null) {
      _textDirection =
          intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode)
              ? TextDirection.rtl
              : TextDirection.ltr;
    }
    return Directionality(
      textDirection: _textDirection,
      child: Scaffold(
        appBar:
            Styles.getAppBarStyle(context, S.of(context).editPass, Icons.edit),
        body: Container(
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: _formKey,
            child: Center(
              child: SingleChildScrollView(
                child: Column(children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 6,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height /
                                registerTopViewHeight,
                            width: MediaQuery.of(context).size.height /
                                registerTopViewHeight,
                            child: CircularProgressIndicator(),
                          ),
                          opacity: _ignored,
                        ),
                        Icon(Maki.restaurant,size: 120.0,)
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width / 1.18,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                  text: S.of(context).editPass + '\n',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          height: 2,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                          fontStyle: FontStyle.normal),
                                  children: [
                                    TextSpan(
                                        text: S.of(context).enterNewPassword,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                                height: 2,
                                                color: colorBorder,
                                                fontSize: 19.0,
                                                fontStyle: FontStyle.normal))
                                  ]),
                            )),
                        SizedBox(height: 18.0),
                        MyTextField(
                            passController,
                            S.of(context).password,
                            CupertinoIcons.eye_fill,
                            true,
                            "*",
                            true,
                            TextInputType.visiblePassword),
                        SizedBox(
                            height: MediaQuery.of(context).size.height /
                                textFieldsDivider),
                        MyTextField(
                            passConController,
                            S.of(context).confirmPassword,
                            CupertinoIcons.eye_fill,
                            true,
                            "*",
                            false,
                            TextInputType.visiblePassword),
                        SizedBox(
                            height: MediaQuery.of(context).size.height /
                                textFieldButtonDividerLogin),
                        MyButton(
                          onClicked: () => onButtonClick(),
                          child: Text(S.of(context).update),
                        ),
                        SizedBox(
                            height: MediaQuery.of(context).size.height /
                                textFieldButtonDividerLogin /
                                2),
                        SizedBox(
                            height: MediaQuery.of(context).size.height / 4),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onButtonClick() async {
    if (_ignored == 0) {
      if (await MyApplication.checkConnection()) {
        resetPassWord(passController.text);
      } else {
        /*Fluttertoast.showToast(
          msg: S.of(context).noInternet,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/
        MyApplication.getDialogue(context, S.of(context).passwordResetFailed,
            S.of(context).noInternet, DialogType.ERROR);
      }
    }
  }

  resetPassWord(String password) async {
    FocusScopeNode currentFocus = FocusScope.of(context);

    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    final FormState? form = _formKey.currentState;

    if (passController.text != passConController.text) {
      /*Fluttertoast.showToast(
          msg: S.of(context).diffPasses,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/
      MyApplication.getDialogue(context, S.of(context).passwordResetFailed,
          S.of(context).diffPasses, DialogType.ERROR);
      return;
    }
    if (form!.validate()) {
      setState(() {
        _ignored = 1.0;
      });
      ProviderUser.password = password;
      final provider = Provider.of<ProviderUser>(context, listen: false);
      await provider.getPostPassWordData(context);
      setState(() {
        _ignored = 0.0;
      });
      if (provider.modelUserPass != null &&
          provider.modelUserPass!.message == 'تم تحديث كلمة المرور') {
        /*Fluttertoast.showToast(
            msg: S.of(context).PassUpdated,
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: colorPrimary,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM);*/
        MyApplication.getDialogue(
            context, S.of(context).PassUpdated, '', DialogType.SUCCES);
      }
    }
  }
}
