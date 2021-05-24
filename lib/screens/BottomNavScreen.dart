import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app8/bottom_nav_routes/Account.dart';
import 'package:flutter_app8/bottom_nav_routes/Cart.dart';
import 'package:flutter_app8/bottom_nav_routes/Categories.dart';
import 'package:flutter_app8/bottom_nav_routes/Home.dart';
import 'package:flutter_app8/generated/l10n.dart';
import 'package:flutter_app8/styles/buttonStyle.dart';
import 'package:flutter_app8/styles/styles.dart';
import 'package:flutter_app8/values/myConstants.dart';
import 'package:flutter_app8/bottom_nav_routes/Account.dart';
import 'package:flutter_app8/bottom_nav_routes/Cart.dart';
import 'package:flutter_app8/bottom_nav_routes/Categories.dart';
import 'package:flutter_app8/bottom_nav_routes/Home.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/web_symbols_icons.dart';

import 'dart:ui' as ui;
import 'package:intl/intl.dart' as intl;

class BottomNavHost extends StatefulWidget {
  static String name = 'BottomNavHost';
  static String searchQueryFun = '';
  static String catQueryFun = '';
  static int catsIndex = -1;
  final String searchQuery = '';
  final String catQuery;
  final int catIndex;
  final String searchQueryLink;

  BottomNavHost(this.searchQueryLink, this.catQuery, this.catIndex);

  @override
  _BottomNavHostState createState() => _BottomNavHostState();
}

class _BottomNavHostState extends State<BottomNavHost> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  String search = '';
  String catQry = '';
 late List<Widget> _pages;
  int index = -1;
  var _textDirection;
  late TabController _tabController;

  late AwesomeDialog awesomeDialog;

  PageController _pageController = PageController();

  bool keep = true ;
  @override
  void initState() {

    index = widget.catIndex;
    _tabController = TabController(vsync: this, length: 4);
    if (widget.searchQueryLink != '' || widget.catQuery != '') {
      print('catQueryhomecats3' + ' ' + widget.catQuery.toString());
      setState(() {
        _selectedIndex = 1;
        _pageController = PageController(initialPage: 1);
        search = widget.searchQueryLink;
        catQry = widget.catQuery;
        //  _pageController.jumpToPage(1);
        // _pageController.animateToPage(1, duration: Duration(milliseconds: 0), curve: Curves.easeOut);
      });
    }

    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _tabController.index = index;
      _selectedIndex = index;

    //  _pageController.jumpToPage(index,);
          //duration: Duration(milliseconds: 500), curve: Curves.easeOut);
      search = '';
      catQry = '';
      this.index = 0;
    });
  }

  void _goToCats(int index) {
    _pageController.animateToPage(1,
        duration: Duration(milliseconds: 500), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {

    if (_textDirection == null) {
      _textDirection =
          intl.Bidi.isRtlLanguage(Localizations.localeOf(context).languageCode)
              ? TextDirection.rtl
              : TextDirection.ltr;
    }
_pages = <Widget>[
  Home( ()=>goToCats()),
  Categories(catQry, search, index,new Key('ggg')),
  Account(),
  Cart(),
];
    getDialogue(context);
    print('catqryFunnnnnnn2'+ ' ' + catQry);
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          _onItemTapped(0);
        } else {
          awesomeDialog.show();
        }
        return false;
      },
      child: Scaffold(

        body:
        IndexedStack(
          // controller: _tabController,
          // physics: NeverScrollableScrollPhysics(),

          children: _pages,
index: _selectedIndex,
        ),


        /*Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),*/
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: S.of(context).home,
            ),
            BottomNavigationBarItem(
              icon: Icon(FontAwesome5.list),
              label: S.of(context).cats,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box_outlined),
              label: S.of(context).account,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: S.of(context).cart,
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: colorPrimary,
          unselectedItemColor: colorBorder,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  getDialogue(BuildContext context) {
    awesomeDialog = AwesomeDialog(
      context: context,
      animType: AnimType.SCALE,
      dialogType: DialogType.QUESTION,
      headerAnimationLoop: false,
      isDense: false,
      dismissOnTouchOutside: false,
      btnOk: MyButton(
          child: Text(S.of(context).yes),
          onClicked: () {
            //   Navigator.pop(context);
            SystemNavigator.pop();
          }),
      // showCloseIcon: true,

      title: S.of(context).exit,
      desc: '',
      btnCancel: MyButton(
        child: Text(S.of(context).no),
        onClicked: () => Navigator.pop(context),
      ),
    );
  }
   goToCats( )
  {

    setState(() {

      search = BottomNavHost.searchQueryFun;
      catQry = BottomNavHost.catQueryFun;
      this.index = BottomNavHost.catsIndex;
      keep = false;
      _tabController.index = 1;
      this._selectedIndex = 1;
      _pages.removeAt(1);
      _pages.insert(1,Categories(catQry, search, index,GlobalKey()));


    });

  }
}
