import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app8/generated/l10n.dart';
import 'package:flutter_app8/validations/validations.dart';
import 'package:flutter_app8/values/colors.dart';
import 'package:flutter_app8/values/myConstants.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController? textEditingController;
  final String labelText;
  final IconData icon;
  final bool isObscure;
  final bool isHasNextFocus;
  final String obsCharacter;
  final TextInputType textInputType;

  MyTextField(
      this.textEditingController,
      this.labelText,
      this.icon,
      this.isObscure,
      this.obsCharacter,
      this.isHasNextFocus,
      this.textInputType);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField>
    with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  IconButton? _iconButton;
  IconData _icon = CupertinoIcons.eye_fill;
  bool _isObscure = true;

  int i = 0;

  FocusNode focusNode = FocusNode();

  double borderRadius = 10.0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    animation = Tween(begin: 0.0, end: MediaQuery.of(context).size.width / 1.15)
        .animate(controller)
          ..addListener(() {
            setState(() {
// the state that has changed here is the animation object’s value
            });
          });
    controller.forward();
    if (widget.icon == CupertinoIcons.eye_fill) {
      _iconButton = IconButton(
        icon: new Icon(_icon),
        onPressed: () => onPressed(),
      );
      // _isObscure = widget.isObscure;
    } else {
      _iconButton = IconButton(
        icon: new Icon(widget.icon),
        onPressed: () => onPressed(),
      );
      _isObscure = widget.isObscure;
    }

    if (widget.isHasNextFocus) {
      return Container(
        width: animation.value,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.1,
          //height: MediaQuery.of(context).size.height / 12,
          child: Stack(children: [
            Padding(
              padding: EdgeInsets.fromLTRB(5, 25, 5, 10),
              child: TextFormField(
                // enableInteractiveSelection: true,
                controller: widget.textEditingController,
                obscureText: _isObscure,
                obscuringCharacter: widget.obsCharacter,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                textInputAction: TextInputAction.next,
                // onTap: unFocus,
                /* onChanged:(val) {

                  widget.textEditingController.text = val; },*/
                focusNode: focusNode,
                onFieldSubmitted: (_) => focusNode.nextFocus(),

                /*widget.textEditingController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: widget.textEditingController.value.text.length,isDirectional: true)*/

                keyboardType: widget.textInputType,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  fillColor: Colors.grey[300],
                  filled: true,
                  contentPadding: EdgeInsetsDirectional.only(
                    start: 40,
                    top: 30.0,
                    /*end: textFieldContentPaddingHorizontal,
                          top: textFieldContentPaddingVertical,*/
                    /*bottom: textFieldContentPaddingVertical*/
                  ),
                  labelText: widget.labelText,
                  /* labelStyle: TextStyle(
                        color: focusNode.hasFocus ? colorPrimary : Colors.black
                    ),*/

                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius))),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius))),
                  labelStyle: TextStyle(
                    fontSize: 14,
                    color: colorBorder,
                  ),
                  hintStyle: TextStyle(fontSize: 14, color: colorBorder),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  suffixIcon: Padding(
                    padding: EdgeInsetsDirectional.only(
                        end: textFieldContentPaddingHorizontal),
                    child: _iconButton,
                  ),
                ),

                validator: (String? value) {
                  if (widget.labelText == S.of(context).email) {
                    return Validations.validateEmail(value!, context);
                  } else {
                    return Validations.validateField(value!, context);
                  }
                },
              ),
            ),
            Container(
              //position label
              margin: EdgeInsets.fromLTRB(7, 0, 0, 8),
              padding: EdgeInsets.fromLTRB(4, 0, 4,
                  8), // input outline default seems using 4.0 as padding from their source
              child: Text(
                widget.labelText,
                style: TextStyle(
                  fontSize: 12,
                  color: focusNode.hasFocus ||
                          widget.textEditingController!.text.trim().isNotEmpty
                      ? Colors.black
                      : Colors.transparent,
                ),
              ),
              color: Colors.transparent, //just to cover the intercepted border
            )
          ]),
        ),
      );
    } else {
      return Container(
        width: animation.value,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 1.25,
          // height: MediaQuery.of(context).size.height / 12,
          child: Center(
            child: Stack(children: [
              Padding(
                padding: EdgeInsets.fromLTRB(5, 25, 5, 5),
                child: TextFormField(
                  controller: widget.textEditingController,
                  obscureText: _isObscure,

                  textAlignVertical: TextAlignVertical.center,
                  obscuringCharacter: widget.obsCharacter,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  textInputAction: TextInputAction.done,
                  keyboardType: widget.textInputType,
                  /*onChanged:(val) {

                    widget.textEditingController.text = val; },*/
                  //onTap: () => unFocus(),
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    fillColor: Colors.grey[300],
                    filled: true,
                    alignLabelWithHint: false,
                    contentPadding: EdgeInsetsDirectional.only(
                      start: 40.0,
                      end: textFieldContentPaddingHorizontal,
                      top: 30.0,
                      /*  bottom: textFieldContentPaddingVertical*/
                    ),
                    labelText: widget.labelText,
                    labelStyle: TextStyle(
                         fontSize: 14.0, color: colorBorder),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            BorderRadius.all(Radius.circular(borderRadius))),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius:
                            BorderRadius.all(Radius.circular(borderRadius))),
                    suffixIcon: Padding(
                      padding: EdgeInsetsDirectional.only(
                          end: textFieldContentPaddingHorizontal),
                      child: _iconButton,
                    ),
                  ),
                  validator: (String? value) {
                    if (widget.labelText == S.of(context).email) {
                      return Validations.validateEmail(value!, context);
                    } else {
                      return Validations.validateField(value!, context);
                    }
                  },
                ),
              ),
              Container(
                //position label
                margin: EdgeInsets.fromLTRB(7, 0, 0, 0),
                padding: EdgeInsets.fromLTRB(4, 0, 8,
                    0), // input outline default seems using 4.0 as padding from their source
                child: Text(
                  widget.labelText,
                  style: TextStyle(
                    fontSize: 12,
                    color: focusNode.hasFocus ||
                            widget.textEditingController!.text.isNotEmpty
                        ? Colors.black
                        : Colors.transparent,
                  ),
                ),
                color:
                    Colors.transparent, //just to cover the intercepted border
              )
            ]),
          ),
        ),
      );
    }
  }

  void unFocus() {
    if (!focusNode.hasFocus) {
      //  Fluttertoast.showToast(msg: 'noFocus');
      i = 0;
    } else {
      // Fluttertoast.showToast(msg: 'Focus');
    }

    if (i == 0 && widget.textEditingController!.text.isNotEmpty) {
      widget.textEditingController!.selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.textEditingController!.value.text.length);
      i = 1;
    } else {
      widget.textEditingController!.selection = TextSelection(
          baseOffset: widget.textEditingController!.value.text.length,
          extentOffset: widget.textEditingController!.value.text.length);
      i = 0;
    }
  }

  onPressed() {
    if (widget.textInputType == TextInputType.visiblePassword) {
      if (_icon == CupertinoIcons.eye_fill) {
        setState(() {
          _icon = CupertinoIcons.eye_slash_fill;
          _isObscure = false;
        });
      } else {
        setState(() {
          _icon = CupertinoIcons.eye_fill;
          _isObscure = true;
        });
      }
    }
  }

  onTextChange(String val, TextEditingController textEditingController) {
    textEditingController.text = val;
  }
}
