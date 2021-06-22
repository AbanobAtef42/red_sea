import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_app8/generated/l10n.dart';
import 'package:flutter_app8/models/ModelDropDown.dart';
import 'package:flutter_app8/providers/providerLanguage.dart';
import 'package:flutter_app8/providers/providerUser.dart';
import 'package:flutter_app8/screens/CustomerOrdersScreen.dart';
import 'package:flutter_app8/screens/FavsScreen.dart';
import 'package:flutter_app8/screens/PassWordResetScreen.dart';
import 'package:flutter_app8/screens/ProfiledataScreen.dart';
import 'package:flutter_app8/screens/loginScreen.dart';
import 'package:flutter_app8/styles/buttonStyle.dart';
import 'package:flutter_app8/styles/styles.dart';
import 'package:flutter_app8/styles/textFieldStyle.dart';
import 'package:flutter_app8/styles/textWidgetStyle.dart';
import 'package:flutter_app8/values/SharedPreferenceClass.dart';
import 'package:flutter_app8/values/myConstants.dart';

import 'package:intl/intl.dart' as intl;
import 'package:provider/provider.dart';

import '../main.dart';

class Account extends StatefulWidget {
  static String name = 'account';
  static double? statusBarHeight;
  static List<ModelDropDown>? list;
  static ModelDropDown? dropValue;
  static FocusNode? focusNode;

  const Account();

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  var _textDirection;
  final TextEditingController phoneController = new TextEditingController();
  final TextEditingController addressController = new TextEditingController();
  TextEditingController emailController = new TextEditingController();
  TextEditingController _nameController = new TextEditingController();
  ProviderUser? userNameProvider;
  ModelDropDown modelDropDown = new ModelDropDown(
      'عربي', Container(child: ImageIcon(AssetImage('images/arabic2.png'))));
  List<DropdownMenuItem<ModelDropDown>>? _dropdownMenuItems;
  List<ModelDropDown> _dropdownItems = [
    ModelDropDown(
        'عربي', Container(child: ImageIcon(AssetImage('images/arabic2.png')))),
    ModelDropDown(
        'عربي', Container(child: ImageIcon(AssetImage('images/arabic2.png'))))
  ];
  double accountItemSplashRadius = 15.0;
  GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    // Account.list.add(modelDropDown);

    super.initState();
    if (sharedPrefs.nameKey != null) {
      _nameController.text = sharedPrefs.nameKey;
    }
    print( 'User Idddd' +sharedPrefs.getCurrentUserId.toString());
    emailController.text = sharedPrefs.mailKey;
    phoneController.text = sharedPrefs.phoneKey;

    ModelDropDown modelDropDown = new ModelDropDown(
        'عربي', Container(child: ImageIcon(AssetImage('images/arabic2.png'))));

    //_selectedItem = _dropdownMenuItems[0].value;
//new ModelDropDown('عربي', Container(child: ImageIcon(AssetImage('images/arabic2.png')))) ,new ModelDropDown('English', Container(child:SvgPicture.asset('images/eng.svg')))
    _dropdownMenuItems = buildDropDownMenuItems(_dropdownItems);
    Account.focusNode = FocusNode(debugLabel: 'Button');
  }

  @override
  Widget build(BuildContext context) {
    print('build______________');
    if (Account.statusBarHeight == null) {
      Account.statusBarHeight = MediaQuery.of(context).padding.top;
    }
    if (userNameProvider == null) {
      userNameProvider = Provider.of<ProviderUser>(context, listen: true);
      // _nameController.text = userNameProvider!.userName!;
    }
    // if(userNameProvider!.userName != null) {
    _nameController.text = sharedPrefs.nameKey;
    // }
    var appLanguage = Provider.of<AppLanguage>(context);
    if (_textDirection == null) {
      _textDirection =
          intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode)
              ? TextDirection.rtl
              : TextDirection.ltr;
    }
    return Scaffold(
      /*appBar: AppBar(
        title: Text(
          account,
        ),
      ),*/

      body: Container(
        color: Colors.white,

        // Container(height: Account.statusBarHeight),
        child: Container(
          height: MediaQuery.of(context).size.height / 1,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 20.0),
              Container(
             //   height: MediaQuery.of(context).size.height / 3,
                child: new Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.height / 8,
                          child: Image.asset('images/user.png')),
                      SizedBox(height: 10.0),
                      Container(
                        color: colorSemiWhite2,
                        padding: EdgeInsets.all(8.0),
                        child: Consumer<ProviderUser>(
                            builder: (context, provider, child) {
                          String name;
                          /* if(provider.userName == '')
                            {
                               name =  (_nameController.text != '' ||
                                  _nameController.text != null)
                            ? _nameController.text
                                : '';
                               provider.setUserFullName('');
                            }*/
                          // else
                          // {

                          name = sharedPrefs.nameKey;
                          if (name.trim().length > 50) {
                            name = name.substring(0, 49) + '...';
                          }
                          //}
                          //
                          return Text(
                            name,
                            style: Styles.getTextAdsStyle(),
                            textAlign: TextAlign.center,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              IgnorePointer(
                ignoring: true,
                child: Column(children: [

                  MyTextField(emailController, S.of(context).email, Icons.email,
                      false, " ", true, TextInputType.emailAddress),
                  SizedBox(
                      height:
                          10.0),
                  MyTextField(phoneController, S.of(context).phone,
                      Icons.phone_android, false, " ", true, TextInputType.phone),

                  /*Positioned(
                  left: 50,
                  right: 50,
                  top: MediaQuery.of(context).size.height / 2.5 -
                      MediaQuery.of(context).size.height / 15,

                  // alignment: Alignment.bottomCenter,
                  child: Container(
                    //  height: MediaQuery.of(context).size.height / 1.5,
                    child: Column(
                      */ /*crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,*/ /*
                      children: [
                        SizedBox(
                            //height: MediaQuery.of(context).size.width / 7.5),
                            ),
                        Container(
                          height: MediaQuery.of(context).size.height / 7.3,
                          width: MediaQuery.of(context).size.width / 1.3,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: MediaQuery.of(context).size.height / 15,
                                  width: MediaQuery.of(context).size.width / 1.3,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              accountItemSplashRadius)),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ProfileData()),
                                      ),
                                      splashColor: colorAccountFocus,
                                      highlightColor: Colors.transparent,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                          ),
                                          Icon(
                                            CupertinoIcons.mail,
                                            color: colorAccountIcon,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                15,
                                          ),
                                          Text(
                                            S.of(context).perData,
                                            style: Styles.getTextAccountStyle(),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                    width: MediaQuery.of(context).size.width /
                                        accountDividerBy,
                                    child: new Divider(
                                      height: 1,
                                      thickness: 1.0,
                                      color: colorAccountIcon,
                                    )),
                                Container(
                                  height: MediaQuery.of(context).size.height / 15,
                                  width: MediaQuery.of(context).size.width / 1.3,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              accountItemSplashRadius)),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                PassWordReset()),
                                      ),
                                      splashColor: colorAccountFocus,
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                10,
                                          ),
                                          Icon(
                                            CupertinoIcons.lock,
                                            color: colorAccountIcon,
                                          ),
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                15,
                                          ),
                                          Text(
                                            S.of(context).password,
                                            style: Styles.getTextAccountStyle(),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                            //  height: MediaQuery.of(context).size.width / 20
                            ),
                        FractionalTranslation(
                          translation: Offset(0, 0.1),
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: MediaQuery.of(context).size.height / 3,
                              width: MediaQuery.of(context).size.width / 1.3,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: colorAccountIcon),
                                  borderRadius: BorderRadius.circular(15.0)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height:
                                        MediaQuery.of(context).size.height / 12.6,
                                    width:
                                        MediaQuery.of(context).size.width / 1.3,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                accountItemSplashRadius)),
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Orders()),
                                        ),
                                        splashColor: colorAccountFocus,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  10,
                                            ),
                                            Icon(
                                              Icons.menu,
                                              color: colorAccountIcon,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  15,
                                            ),
                                            Text(
                                              S.of(context).orders,
                                              style: Styles.getTextAccountStyle(),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width /
                                          accountDividerBy,
                                      child: new Divider(
                                        height: 1,
                                        thickness: 1.0,
                                        color: colorAccountIcon,
                                      )),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              accountItemSplashRadius)),
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Favourites()),
                                      ),
                                      splashColor: colorAccountFocus,
                                      child: Container(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                13,
                                        width: MediaQuery.of(context).size.width /
                                            1.3,
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  10,
                                            ),
                                            Icon(
                                              CupertinoIcons.heart,
                                              color: colorAccountIcon,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  15,
                                            ),
                                            Text(
                                              S.of(context).wish,
                                              style: Styles.getTextAccountStyle(),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width /
                                          accountDividerBy,
                                      child: new Divider(
                                        height: 1,
                                        thickness: 1.0,
                                        color: colorAccountIcon,
                                      )),
                                  Container(
                                    height:
                                        MediaQuery.of(context).size.height / 13,
                                    width:
                                        MediaQuery.of(context).size.width / 1.3,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                accountItemSplashRadius)),
                                        onTap: () => openDropdown(globalKey),
                                        splashColor: colorAccountFocus,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  10,
                                            ),
                                            Icon(
                                              CupertinoIcons.globe,
                                              color: colorAccountIcon,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  15,
                                            ),
                                            // Text(S.of(context).lang,style: Styles.getTextAccountStyle()),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  2.5,
                                              child: Align(
                                                alignment: AlignmentDirectional
                                                    .centerStart,
                                                child:
                                                    DropdownButton<ModelDropDown>(
                                                  key: globalKey,
                                                  underline: Text(''),
                                                  focusNode: Account.focusNode,
                                                  hint: Text(S.of(context).lang,
                                                      style: Styles
                                                          .getTextAccountStyle()),
                                                  // value: _selectedItem,
                                                  dropdownColor: colorPrimary,
                                                  isExpanded: true,
                                                  isDense: false,
                                                  onChanged: (value) {
                                                    if (value!.value == 'عربي') {
                                                      appLanguage.changeLanguage(
                                                          Locale("ar", ""));
                                                      MyApp.setLocale(context,
                                                          Locale("ar", ""));
                                                    } else {
                                                      appLanguage.changeLanguage(
                                                          Locale("en", "US"));
                                                      MyApp.setLocale(context,
                                                          Locale("en", "US"));
                                                    }
                                                  },
                                                  items: buildDropDownMenuItems([
                                                    ModelDropDown(
                                                        'عربي',
                                                        Container(
                                                            width: 30,
                                                            height: 30,
                                                            child: Image.asset(
                                                                'images/arb.png'))),
                                                    ModelDropDown(
                                                        'English',
                                                        Container(
                                                            width: 30,
                                                            height: 30,
                                                            child: Image.asset(
                                                                'images/egl.png')))
                                                  ]),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width /
                                          accountDividerBy,
                                      child: new Divider(
                                        height: 1,
                                        thickness: 1.0,
                                        color: colorAccountIcon,
                                      )),
                                  Container(
                                    height:
                                        MediaQuery.of(context).size.height / 12.6,
                                    width:
                                        MediaQuery.of(context).size.width / 1.3,
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                accountItemSplashRadius)),
                                        onTap: () {
                                          SharedPrefs().signedIn(false);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginScreen()),
                                          );

                                        },
                                        splashColor: colorAccountFocus,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  10,
                                            ),
                                            Icon(
                                              Icons.logout,
                                              color: colorAccountIcon,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  15,
                                            ),
                                            Text(
                                              S.of(context).signOut,
                                              style: Styles.getTextAccountStyle(),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),*/
                ]),
              ),
              SizedBox(height: 10.0,),
              Container(
                  padding: const EdgeInsetsDirectional.only(start: 22.0, bottom: 10.0),
                  child: MyTextWidgetLabel(S.of(context).lang, 'label', colorBorder, 12.0)),
              GestureDetector(
                onTap:()=> openDropdown(globalKey),
                child: Container(
                  width: MediaQuery.of(context)
                      .size
                      .width /
                      1.2,
                  padding: const EdgeInsetsDirectional.only(start: 40.0,end: 40.0),
                  decoration: BoxDecoration(color: Colors.grey[300],shape: BoxShape.rectangle,borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Align(
                    alignment: AlignmentDirectional
                        .centerStart,
                    child:
                    DropdownButton<ModelDropDown>(
                      key: globalKey,
                      underline: Text(''),
                      focusNode: Account.focusNode,
                      hint: Text(S.of(context).lang,
                          style: Styles
                              .getTextAccountStyle()),
                      // value: _selectedItem,
                      dropdownColor: colorPrimary,
                      isExpanded: true,
                      isDense: false,
                      onChanged: (value) {
                        if (value!.value == 'عربي') {
                          appLanguage.changeLanguage(
                              Locale("ar", ""));
                          MyApp.setLocale(context,
                              Locale("ar", ""));
                        } else {
                          appLanguage.changeLanguage(
                              Locale("en", "US"));
                          MyApp.setLocale(context,
                              Locale("en", "US"));
                        }
                      },
                      items: buildDropDownMenuItems([
                        ModelDropDown(
                            'عربي',
                            Container(
                                width: 30,
                                height: 30,
                                child: Image.asset(
                                    'images/arb.png'))),
                        ModelDropDown(
                            'English',
                            Container(
                                width: 30,
                                height: 30,
                                child: Image.asset(
                                    'images/egl.png')))
                      ]),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.0,),
              MyButton(onClicked: ()=> Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileData()),
              ),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[Icon(Icons.edit,color: Colors.white,),SizedBox(width: 8.0,), Text(S.of(context).editProfile),]),),
              SizedBox(height: 20.0,),
              MyButton(onClicked: ()=> Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PassWordReset()),
              ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[Icon(Icons.edit,color: Colors.white,),SizedBox(width: 8.0,), Text(S.of(context).editPass),]),),
              SizedBox(height: 20.0,),
             // Material(
               /* color: Colors.transparent,
                child: InkWell(
                  splashColor: colorPrimary,
                  onTap:(){
                    *//*Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginScreen()),
                );*//*},*/
                   MyButton(
                    onClicked: (){SharedPrefs().signedIn(false);
                    sharedPrefs.signedInThenOut(true);
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);},
                    /*padding: const EdgeInsetsDirectional.only(top: 16.0,bottom: 16.0),
                    width: MediaQuery.of(context).size.width /1.2,
                    decoration: BoxDecoration(color: Colors.grey[300],shape: BoxShape.rectangle,borderRadius: BorderRadius.all(Radius.circular(10.0))),*/
                    child: Center(child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        Icon(Icons.logout,color: Colors.white,) ,
                        Text(S.of(context).signOut,style: TextStyle(color: Colors.white,fontSize: 16.0,fontWeight: FontWeight.w600),)
                      ],)),
                  ),
                ]),


          ),
          ),
    );


        //  SizedBox(height: MediaQuery.of(context).size.width / 60),
        /*Container(
                height: MediaQuery.of(context).size.height / 3.5,
                width: MediaQuery.of(context).size.width / 1.3,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: colorAccountIcon),
                    borderRadius: BorderRadius.circular(15.0)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Row(
                        children: [
                          SizedBox(width: MediaQuery.of(context).size.width / 10,),
                          Icon(Icons.menu,color: colorAccountIcon,),
                          SizedBox(width: MediaQuery.of(context).size.width / 15,),
                          Text(orders,style: Styles.getTextAccountStyle(),)
                        ],

                      ),
                    ),
                    new Divider(height: 1,thickness: 1.0,color: colorAccountIcon,),
                    Container(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Row(
                        children: [
                          SizedBox(width: MediaQuery.of(context).size.width / 10,),
                          Icon(CupertinoIcons.heart,color: colorAccountIcon,),
                          SizedBox(width: MediaQuery.of(context).size.width / 15,),
                          Text(wish,style: Styles.getTextAccountStyle(),)
                        ],

                      ),
                    ),
                    new Divider(height: 1,thickness: 1.0,color: colorAccountIcon,),
                    Container(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Row(
                        children: [
                          SizedBox(width: MediaQuery.of(context).size.width / 10,),
                          Icon(CupertinoIcons.globe,color: colorAccountIcon,),
                          SizedBox(width: MediaQuery.of(context).size.width / 15,),
                          Text(lang,style: Styles.getTextAccountStyle(),)
                        ],

                      ),
                    ),
                    new Divider(height: 1,thickness: 1.0,color: colorAccountIcon,),
                    Container(
                      height: MediaQuery.of(context).size.height / 15,
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Row(
                        children: [
                          SizedBox(width: MediaQuery.of(context).size.width / 10,),
                          Icon(Icons.logout,color: colorAccountIcon,),
                          SizedBox(width: MediaQuery.of(context).size.width / 15,),
                          Text(S.of(context).password,style: Styles.getTextAccountStyle(),)
                        ],

                      ),
                    ),

                  ],
                ),
              )*/

  }

  List<DropdownMenuItem<ModelDropDown>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ModelDropDown>> items = [];
    for (ModelDropDown listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Row(
            children: <Widget>[
              Text(
                listItem.value,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: Styles.getTextAccountStyle().fontSize,
                    fontWeight: Styles.getTextAccountStyle().fontWeight),
              ),
              Spacer(),
              listItem.icon,
            ],
          ),
          value: listItem,
        ),
      );
    }
    return items;
  }

  onTap() {}
  void openDropdown(GlobalKey globalKey) {
    GestureDetector? detector;
    void searchForGestureDetector(BuildContext? element) {
      element!.visitChildElements((element) {
        if (element.widget is GestureDetector) {
          detector = element.widget as GestureDetector?;
          // return false;
        } else {
          searchForGestureDetector(element);
        }

        // return true;
      });
    }

    searchForGestureDetector(globalKey.currentContext!);

    assert(detector != null);

    detector!.onTap!();
  }
}
