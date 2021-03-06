import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app8/generated/l10n.dart';
import 'package:flutter_app8/icons/my_flutter_app_icons.dart';
import 'package:flutter_app8/models/ModelCats.dart';
import 'package:flutter_app8/models/ModelProducts.dart';
import 'package:flutter_app8/models/ModelSetting.dart';
import 'package:flutter_app8/providers/providerHome.dart';
import 'package:flutter_app8/providers/providerUser.dart';
import 'package:flutter_app8/screens/BottomNavScreen.dart';
import 'package:flutter_app8/screens/FavsScreen.dart';
import 'package:flutter_app8/screens/ProductDetailScreen.dart';
import 'package:flutter_app8/screens/customwidgets/stateFulWrapper.dart';
import 'package:flutter_app8/screens/customwidgets/stateFulWrapperCats.dart';
import 'package:flutter_app8/styles/buttonStyle.dart';
import 'package:flutter_app8/styles/styles.dart';
import 'package:flutter_app8/styles/textWidgetStyle.dart';
import 'package:flutter_app8/values/SharedPreferenceClass.dart';
import 'package:flutter_app8/values/api.dart';
import 'package:flutter_app8/values/myApplication.dart';
import 'package:flutter_app8/values/myConstants.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'Cart.dart';

class Categories extends StatelessWidget {
  final String catQuery;
  final String searchQuery;
  final int catIndex;
  final bool signedInOut;
  final String sourceRoute;
  static const int _pageSize = 10;
  static ProviderHome? _providerHome;
  static ProviderUser? _providerUser;
  static String name = 'category';

  static String catQuery2 = '';
  static String searchQuery2 = '';
  static List<Datum> allItems = [];

  static ModelCats? modelCats;
  static ModelProducts? modelProducts;
  static ModelProducts? modelProducts2;
  static double? listPadding;
/*String catQuery = '';
  String trendQuery = '';
  String searchQuery = '';*/
  static double? statusBarHeight;
  static bool dataLoaded = false;
  static bool listen = true;
  static int index1 = 0;
  static Icon _searchIcon = new Icon(Icons.search);
  static FocusNode? focusNode = FocusNode();
// IconButton _searchIconButton = new IconButton();
  final TextEditingController textEditingController =
      new TextEditingController();
  static ProviderHome? provider;

  static bool loading = false;
  static bool adsSlow = false;
  static bool catsSlow = false;
  static bool prosSlow = false;
  static bool internet = true;

  static var x = 0;

  static ScrollController _scrollController = ScrollController();
  static int pageKey = 1;

   PagingController<int, Datum> _pagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, Datum> _pagingControllerCats =
      PagingController(firstPageKey: 1);
  final PagingController<int, Datum> _pagingControllerSearch =
      PagingController(firstPageKey: 0);

  static bool isAlwaysShown = true;

  static bool internetp = true;

  static ModelSetting? modelSettings;

  static late List<GlobalKey<State<StatefulWidget>>> tags;

  static bool isReadOnly = false;

  static bool showCursor = true;

  static late List<bool> _isFavorited;
  //static late List<PagingController<int,Datum>> _pagingControllers;
  static late List<int> _favoriteIds;
  final Box<Datum>? boxFavs = Hive.box(sharedPrefs.mailKey + dataBoxNameFavs);

  int pagingIndex = 0;
  Categories(this.catQuery, this.searchQuery, this.catIndex, this.signedInOut,
      this.sourceRoute);

  void initState(BuildContext context) {
    _isFavorited = [];
    _favoriteIds = [];
    catQuery2 = catQuery;
    searchQuery2 = searchQuery;

    provider = Provider.of<ProviderHome>(context, listen: false);
    focusNode = new FocusNode();
    isAlwaysShown = true;

    print('catQueryhomecats' + ' ' + catQuery);

    if (searchQuery != '') {
      textEditingController.text = searchQuery.toString();
    }

    /*if (catIndex == -1) {
      index1 = catIndex;
    }
    else
      {
        index1 = 0;
      }*/
    index1 = catIndex;
    modelSettings =
        Provider.of<ProviderUser>(context, listen: false).modelSettings;

    modelProducts =
        Provider.of<ProviderHome>(context, listen: false).modelProductsCats;

    modelCats = Provider.of<ProviderHome>(context, listen: false).modelCats2;
    if (modelCats == null || modelSettings == null || modelProducts == null) {
      //_getProducts(context, -1, pageKey);

    }
    pageKey = 1;
//_pagingControllers = [PagingController<int, Datum>(firstPageKey: 1)];
    _getCats(context);
    _getPriceUnit(context, 'admin.\$');
    _fetchPage(1, context, true);

    /*_pagingControllerCats.addPageRequestListener((pageKey) {
      print('execpagingcats' + pageKey.toString());
      _fetchPageCats(this.pageKey);
    });
    _pagingController.addPageRequestListener((pageKey) {
      print('execpaging' + pageKey.toString());
      _fetchPage(pageKey);
    });

    _pagingControllerSearch.addPageRequestListener((pageKey) {
      _fetchPageSearch(pageKey);
    });*/
    if (signedInOut && sourceRoute == 'l') {
      print('building.....    $pageKey');
      _providerHome!.isLastPage = false;
      pageKey = 1;
      index1 = 0;
      //onListItemTap(modelCats, 0, context, _providerHome);
       _fetchPage(1, context, true);
      // _getCats(context);
    }
    _scrollController.addListener(() {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });

    MyApplication.initCache();
  }

  void onListItemTap(ModelCats? modelCats, int index, BuildContext context,
      ProviderHome? providerHome) async {
    /*final provider = Provider.of<ProviderHome>(context);
    provider.getCatIndex(index);*/
//Timer(Duration(seconds: ))
    //  Provider.of<ProviderHome>(context,listen: false).modelProductsCats.data.clear();
    FocusNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
    //   provider = Provider.of<ProviderHome>(context, listen: false);

    modelProducts = provider!.modelProductsCats;
    if (index1 !=
        index && allItems.isNotEmpty && _pagingController.value.status != PagingStatus.loadingFirstPage /*(_pagingController.value.status == PagingStatus.completed || _pagingController.value.status != PagingStatus.loadingFirstPage )*/) {

      index1 = index;
      searchQuery2 = '';
      catQuery2 = index == 0 ? '' : modelCats!.data![index - 1].slug!;
     // _pagingController = PagingController(firstPageKey: 1);

      // _pagingControllerMain = _pagingControllerCats;

      loading = true;
      pageKey = 1;
      allItems.clear();
      // this.modelCats = provider.modelCats;
      //modelProducts = new ModelProducts();

      _providerHome!.isLastPageCats = false;
     // _providerHome!.isLoadedCats = false;
      _providerHome!.notifyListeners();
      //_providerHome!.setIsLoaded(false);
      // print('catQuery2' + modelCats!.data![index].slug!);

      _fetchPage(1, context, true);
      _pagingController.refresh();

    }
    //_getProducts(context, index1, pageKey);
  }

  _getCats(BuildContext context) async {
    // final provider = Provider.of<ProviderHome>(context, listen: false);
    if (!await MyApplication.checkConnection()) {
      await Provider.of<ProviderHome>(context, listen: false).getCats2();

      modelCats = _providerHome!.modelCats2;
      internet = false;
      _providerHome!.notifyListeners();
    } else {
      await Provider.of<ProviderHome>(context, listen: false).getCats2();

      modelCats = _providerHome!.modelCats2;
      _providerHome!.notifyListeners();
    }
  }

  onSubmitted(String query, BuildContext context) async {
    if (query.trim().isEmpty) {
      FocusScope.of(context).requestFocus(focusNode);
      return;
    }
    //  setState(()  {
    if (!await MyApplication.checkConnection()) {
      MyApplication.getDialogue(
          context, S.of(context).noInternet, '', DialogType.ERROR);
    } else {
      //   provider = Provider.of<ProviderHome>(context, listen: false);
      searchQuery2 = query;
      print('query' + query);
      //   x = 0;
      //   this._searchIcon = new Icon(Icons.close);
      // modelProducts = null;
      //
      // provider = Provider.of<ProviderHome>(context, listen: false);

      modelProducts = provider!.modelProductsCats;

      textEditingController.text = searchQuery.toString();
      searchQuery2 = query;
      loading = true;
      pageKey = 1;
      catQuery2 = '';

      //

      // });

      _pagingController.refresh();
      // _getProducts(context, -1,pageKey);
    }
  }

  onIconHeartClick(Datum modelProducts, int index, BuildContext context) {
    print('fffffffffffdddd' + index.toString());
    List<Datum?> datums = boxFavs!.values
        .where((element) => element.id == modelProducts.id)
        .toList();
    if (datums.length == 0) {
      print('ffffffffffffff');
      boxFavs!.add(modelProducts);
      Provider.of<ProviderHome>(context, listen: false).notifyListeners();
    } else {
      // setState(() {
      /*this._iconHeart = new Icon(
          CupertinoIcons.heart_fill,
          color: Colors.grey,
        );*/

      Iterable<dynamic> key = boxFavs!.keys
          .where((element) => boxFavs!.get(element)!.id == modelProducts.id);
      boxFavs!.delete(key.toList()[0]);
      Provider.of<ProviderHome>(context, listen: false).notifyListeners();
      // });
    }
  }

  retryButtonWidget(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: MyButton(
          onClicked: () async {
            if (await MyApplication.checkConnection()) {
              internet = true;
              catQuery2 = '';
              searchQuery2 = '';
            }
            _getPriceUnit(context, 'admin.\$');
            _getCats(context);
            _getProducts(context, -1, pageKey);
            // _pagingController.refresh();

            //  _getProducts(context, -1, 1);
          },
          child: Row(
            children: [
              Text(
                S.of(context).retry,
                style: TextStyle(fontSize: 14.0),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0),
                child: Icon(Icons.refresh),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          )),
    );
  }

  _getPriceUnit(BuildContext context, String key) async {
    print('exe price');
    ProviderUser.settingKey = key;
    //  provider2 = Provider.of<ProviderUser>(context, listen: false);
    if (!await MyApplication.checkConnection()) {
      // await Provider.of<ProviderUser>(context, listen: false).getSettingsData();
      // setState(() {
      if (sharedPrefs.exertedPriceUnitKey.isEmpty) {
        // setState(() {
        _providerUser!.modelSettings = null;
        internet = false;
        modelSettings = _providerUser!.modelSettings;
        _providerUser!.notifyListeners();
        // });
      } else {
        print('shared setting price');
        _providerUser!.modelSettings = new ModelSetting();

        List<Datum2> datums = [];
        datums.add(Datum2(value: sharedPrefs.exertedPriceUnitKey));
        _providerUser!.modelSettings!.data = datums;
        modelSettings = _providerUser!.modelSettings;
        _providerUser!.notifyListeners();
      }
      //   modelSettings = Provider.of<ProviderUser>(context, listen: false).modelSettings;
      //  });
    } else {
      print('exeinternetprice');
      if (sharedPrefs.priceUnitKey == '') {
        await Provider.of<ProviderUser>(context, listen: false)
            .getSettingsData();

        // if (this.mounted) {
        // setState(() {
        //   modelSettings = Provider.of<ProviderUser>(context, listen: false).modelSettings;
        if (Provider.of<ProviderUser>(context, listen: false)
                .modelSettings!
                .data !=
            null) {
          SharedPrefs().priceUnit(
              _providerUser!.modelSettings!.data![0].value.toString());
          SharedPrefs().exertedPriceUnit(
              _providerUser!.modelSettings!.data![0].value.toString());
          modelSettings = _providerUser!.modelSettings;
          _providerUser!.notifyListeners();
        }
        // print(modelSettings!.data.toString()+'--------');
        // });
        // }
      } else {
        // setState(() {
        print('shared setting price');
        _providerUser!.modelSettings = new ModelSetting();
        List<Datum2> datums = [];
        datums.add(Datum2(value: sharedPrefs.priceUnitKey));
        _providerUser!.modelSettings!.data = datums;
        modelSettings = _providerUser!.modelSettings;
        _providerUser!.notifyListeners();
        // });
      }
    }
  }

  _getProducts(BuildContext context, int index, int page) async {
    Api.context = context;
    Api.productPage = page;
    print('catqur2' + catQuery2.toString());
    print('searchqur2' + searchQuery2);
    await Provider.of<ProviderHome>(context, listen: false)
        .getProductsCats(catQuery2, searchQuery2, '');

    /*if(this.mounted && index == -1){
       modelProducts = new ModelProducts();
     }*/
    print('catttttt' + catQuery2);
    if (index == -1 ||
        (modelCats != null && catQuery2 == modelCats!.data![index].slug)) {
      if (!await MyApplication.checkConnection()) {
        modelProducts = _providerHome!.modelProductsCats;
        internetp = false;
        loading = false;

        return _providerHome!.modelProductsCats!.data;
      } else {
        internetp = true;
        Timer.periodic(Duration(milliseconds: 0), (timer) {
          loading = false;

          modelProducts = _providerHome!.modelProductsCats;
          /*if(modelProducts == null)
          {
            modelProducts = new ModelProducts();
          }*/
        });
        return _providerHome!.modelProductsCats!.data;
      }
    }
    // return _providerHome!.modelProductsCats!.data;
    //  modelProducts2 = modelProducts;
    /* setState(() {
         provider = Provider.of<ProviderHome>(context,listen: false);
       });*/
  }

  scrollBarConfig() {
    if (isAlwaysShown) {
      Timer.periodic(Duration(milliseconds: 2100), (timer) {
        isAlwaysShown = false;
        //   _providerHome!.notifyListeners();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('building.....cats');
    if (_providerHome == null) {
      _providerHome = Provider.of<ProviderHome>(context, listen: false);
    }
    if (_providerUser == null) {
      _providerUser = Provider.of<ProviderUser>(context, listen: false);
    }

    // TODO: implement build
    return StatefulWrapper(
      onInit: () => initState(context),
      child: Scaffold(
        /*appBar: AppBar(
                  title: Text(cats,
                ),*/
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          toolbarHeight: toolbarHeight,
          actions: [
            IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.black,
                ),
                onPressed: () => _showSearch(context)),
            IconButton(
              icon: Icon(
                CupertinoIcons.heart_fill,
                color: Colors.black,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Favourites()),
              ),
            ),
          ],
          leading: IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.black,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Cart()),
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Red Sea',
              style: TextStyle(color: Colors.black, fontSize: 16.0),
            ),
            SizedBox(
              width: 8.0,
            ),
            Image.asset(
              "assets/redsea2.png",
              height: 40.0,
            )
          ]),
        ),
        /*AppBar(
          centerTitle: true,
          toolbarHeight: toolbarHeight,
          automaticallyImplyLeading: false,
          title: GestureDetector(
            onTap: _showSearch,
            child: Container(
              width: MediaQuery.of(context).size.width / 1.2,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: Theme(
                data: ThemeData(disabledColor: Colors.black),
                child: TextFormField(
                  enabled: false,
                  controller: textEditingController,
                  style: Styles.getTextAdsStyle(),

                  //  onTap: () => this._searchIcon = new Icon(Icons.close),
                  focusNode: focusNode,

                  textInputAction: TextInputAction.search,

                  // controller: _filter,
                  decoration: new InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    prefixIcon: new IconButton(
                        icon: Icon(Icons.search), onPressed: () => _showSearch()),
                    hintText: S.of(context).searchInFlk,
                  ),
                ),
              ),
            ),
          ),
        ), */ //_buildBar(context) as PreferredSizeWidget?,
        body: RawScrollbar(
          thumbColor: colorPrimary,
          isAlwaysShown: isAlwaysShown,
          controller: _scrollController,
          radius: Radius.circular(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 0,
              ),
              getScreenUi(context),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showSearch(BuildContext context) async {
    FocusScope.of(context).requestFocus(focusNode);
    await showSearch(
      context: context,
      delegate:
          TheSearch(contextPage: context, controller: textEditingController),
      query: textEditingController.text.toString(),
    );
  }

  Icon onIconHeartStart(Datum modelProduct, int index) {
    bool isFavourite = _isFavorited[index];
    // print('fffffffffffdddd');
    List<Datum?> datums = boxFavs!.values
        .where((element) => element.id == modelProduct.id)
        .toList();
    if (datums.length > 0) {
      _isFavorited[index] = true;
    }

    if (_isFavorited[index]) {
      // print('ffffffffffffff');

      Icon _iconHeart = new Icon(
        CupertinoIcons.heart_fill,
        color: Colors.red,
      );

      return _iconHeart;

      //});
    } else {
      Icon _iconHeart = new Icon(
        CupertinoIcons.heart_fill,
        color: Colors.grey,
      );

      return _iconHeart;
    }
  }

  _getIndexedStack(BuildContext context) {
    modelSettings =
        Provider.of<ProviderUser>(context, listen: true).modelSettings;
    modelProducts =
        Provider.of<ProviderHome>(context, listen: true).modelProductsCats;
    modelCats = Provider.of<ProviderHome>(context, listen: true).modelCats2;
    if (modelCats == null || modelSettings == null || modelProducts == null) {
      return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          CircularProgressIndicator(),
        ]),
      );
    }
    List<Widget> pages = List.generate(
        modelCats!.data!.length, (index) => getAppWidget(context));
    // getAppWidget(context);
    return IndexedStack(
      children: pages,
      index: index1,
    );
  }

  Widget getAppWidget(BuildContext context) {
    /*Fluttertoast.showToast(
        msg: '22 : _getAppWidget ',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: colorPrimary,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        fontSize: textLabelSize);*/
    modelSettings =
        Provider.of<ProviderUser>(context, listen: true).modelSettings;
    modelProducts =
        Provider.of<ProviderHome>(context, listen: true).modelProductsCats;
    modelCats = Provider.of<ProviderHome>(context, listen: true).modelCats2;
    if (modelCats == null || modelSettings == null || modelProducts == null) {
      return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          CircularProgressIndicator(),
        ]),
      );
    }

    /* setState(() {
        provider = Provider.of<ProviderHome>(context,listen: false);
        loading = false;
      });*/
    // loading = false;
    List cats = _providerHome!.modelCats2!.data == null
        ? []
        : _providerHome!.modelCats2!.data!;

   // _pagingControllers.addAll( List.generate(cats.length-1, (index) => PagingController<int,Datum>(firstPageKey: 1)));

/*setState(() {
  provider = Provider.of<ProviderHome>(context, listen: true);
});*/
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: MediaQuery.of(context).size.height / 15,
            width: MediaQuery.of(context).size.width,
            child: ListView.builder(
                itemCount: cats.length + 1,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  if (index == index1) {
                    return GestureDetector(
                      onTap: () =>
                          onListItemTap(modelCats, index, context, provider),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: BoxDecoration(
                              color: colorPrimary,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30.0))),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 16.0,
                                  right: 16.0,
                                  top: 1.0,
                                  bottom: 1.0),
                              child: Center(
                                  child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Center(
                                          child: Text(
                                        index == 0
                                            ? 'All'
                                            : cats[index - 1].name,
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      )))),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return GestureDetector(
                    onTap: () =>
                        onListItemTap(modelCats, index, context, provider),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: 8.0, right: 8.0, top: 4.0, bottom: 4.0),
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: Center(
                                    child: Text(
                                  index == 0 ? 'All' : cats[index - 1].name,
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 14),
                                ))),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ),
        Container(
          height: 1.0,
          color: Colors.grey,
          width: MediaQuery.of(context).size.width / 1.1,
        ),
        _getProductWidget(_providerHome!.modelProductsCats, context),
      ],
    );
  }

  retryButtonListWidget(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: MyButton(
          onClicked: () async {
            pageKey = 1;
            _pagingController.refresh();
          },
          child: Row(
            children: [
              Text(
                S.of(context).retry,
                style: TextStyle(fontSize: 14.0),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0),
                child: Icon(Icons.refresh),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          )),
    );
  }

  _buildItem(Datum modelProducts, int index, BuildContext context) {
    String name = modelProducts.name!;
    if (name.length > 13) {
      name = name.substring(0, 12) + '...';
    }
    if (index == _providerHome!.modelProducts!.data!.length-1) {
      _providerHome!.isLoadedCats = true;
     // _providerHome!.notifyListeners();
    }
   // pagingIndex = ++index;

    _isFavorited.insert(index, false);
    return Container(
      margin:
          EdgeInsetsDirectional.only(start: listPadding!, end: listPadding!),
      // width: MediaQuery.of(context).size.width/1.2,
      //height: MediaQuery.of(context).size.height / 2.9,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: [
            Stack(children: [
              Padding(
                padding: const EdgeInsets.all(0.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0.0),
                  child: Hero(
                    tag: modelProducts.name.toString() +
                        modelProducts.slug.toString(),
                    child: CachedNetworkImage(
                      placeholder: (con, str) =>
                          Image.asset('images/plcholder.jpeg'),
                      imageUrl: modelProducts.images!.isNotEmpty
                          ? 'https://flk.sa/' + modelProducts.images![0]
                          : 'jj',
                      fit: BoxFit.cover,
                      // width: MediaQuery.of(context).size.width / 3.7,
                      height: MediaQuery.of(context).size.height / 5,
                    ),
                  ),
                ),
              ),
              getDiscRate(modelProducts),
              Positioned(
                left: 15,
                top: 15,
                child: GestureDetector(
                  onTap: () {
                    onIconHeartClick(modelProducts, index, context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border()),
                    child: onIconHeartStart(modelProducts, index),
                  ),
                ),
              ),
            ]),
            Container(
              // color: Colors.grey[50],
              decoration: new BoxDecoration(
                  color: Colors.transparent,
                  border: Border(
                      right: BorderSide(),
                      left: BorderSide(),
                      bottom: BorderSide())),
              padding: EdgeInsetsDirectional.only(top: 12.0, bottom: 18.0),
              child: Column(
                /*mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,*/
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                        end: listPadding!, start: listPadding!),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          // width: MediaQuery.of(context).size.width / 1.8,
                          child: Hero(
                            tag: modelProducts.name.toString(),
                            child: Material(
                              child: Text(
                                name,
                                style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .textTheme
                                        .headline3!
                                        .fontSize),
                              ),
                            ),
                          ),
                        ),
                        Spacer(
                          flex: 1,
                        ),
                        rateWidget(modelProducts, context),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  SizedBox(
                    //  width: MediaQuery.of(context).size.width - MediaQuery.of(context).size.width / 2.8,
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: listPadding!,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // rateWidget(modelProducts),
                          /*Spacer(
                          flex: 1,
                        ),*/
                          Row(children: [
                            Text(
                              modelProducts.price! +
                                  ' ' +
                                  modelSettings!.data![0].value!,
                              style: TextStyle(fontSize: 14.0),
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            getDiscountWidget(modelProducts),
                          ])
                        ],
                      ),
                    ),
                  ),
                  /*Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Styles.getButton(
                        context,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              S.of(context).cartAdd,
                              style: TextStyle(fontSize: 14.0),
                            ),
                            SizedBox(
                              width: 8.0,
                            ),
                            Icon(Icons.add_shopping_cart)
                          ],
                        ),
                            () {},
                        Styles.getCartButtonStyle()),
                  )*/
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _getProductWidget(ModelProducts? modelProducts, BuildContext context) {
    //loading = provider.loadedCats;
    // List<Datum> list = modelProducts.data;
    /*  setState(() {
      provider = Provider.of<ProviderHome>(context,listen: false);
    });*/
    if (listPadding == null) {
      listPadding = MediaQuery.of(context).size.width / 25;
    }

    if (!internetp && modelProducts == null) {
      hideScrollBar();
      print('noooooooooooooooooo');
      return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 3,
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: colorPrimary,
                  )),
            ),
            Container(
                width: MediaQuery.of(context).size.width / 2,
                child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(S.of(context).noInternet))),
          ],
        ),
      );
    } else if (modelProducts != null && modelProducts.path == 'slint') {
      /*Fluttertoast.showToast(
          msg: S.of(context).slowInternet,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/
      hideScrollBar();
      return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 4,
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    MyFlutterApp.slow_internet,
                    color: colorPrimary,
                  )),
            ),
            retryButtonWidget(context),
            Container(
                width: MediaQuery.of(context).size.width / 2,
                child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(S.of(context).slowInternet))),
          ],
        ),
      );
    }

    if (loading) {
      hideScrollBar();
      return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Align(
              alignment: Alignment.bottomCenter,
              child: CircularProgressIndicator()),
        ),
      );
    }

    /* if (modelProducts.data != null &&
        modelProducts.data!.length == 0 &&
        false) {
      hideScrollBar();
    }*/

    final List<String> imgList = [
      'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
      'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
      'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
      // 'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
      // 'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
      // 'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
    ];

    scrollBarConfig();

    return SizedBox(
      height: MediaQuery.of(context).size.height / 1.5,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollNotification) {
          //  _pagingController.addPageRequestListener((pageKey) {
          if (scrollNotification is ScrollEndNotification &&
              scrollNotification.metrics.extentAfter == 0 && scrollNotification.metrics.pixels == scrollNotification.metrics.maxScrollExtent &&
              !_providerHome!.isLastPageCats && _pagingController.value.status != PagingStatus.loadingFirstPage) {
            // _providerHome!.setPageKey(++_providerHome!.pageKey);
            int key = _providerHome!.pageKey;
            print('pageKeyProvider  $key');
            allItems.clear();
            _fetchPage(++pageKey, context, false);
          }
          // });
          return true;
        },
        child: RefreshIndicator(
          onRefresh: () => Future.sync(
            () {
              pageKey = 1;
              _fetchPage(pageKey, context, true);
              // _pagingController.refresh();
            },
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 10.0, left: 10.0, top: 10.0),
            child: RawScrollbar(
              thumbColor: colorPrimary,
              isAlwaysShown: isAlwaysShown,
              controller: _scrollController,
              radius: Radius.circular(8.0),
              child: SingleChildScrollView(
                child: PagedGridView<int, Datum>(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 100 / 170,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                  ),
                  pagingController: _pagingController,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  //  physics: NeverScrollableScrollPhysics(),
                  builderDelegate: PagedChildBuilderDelegate<Datum>(
                      itemBuilder: (context, modelProducts, index) {
                    List<String> itemTags = [];

                    String name = modelProducts.name!;
                    if (name.length > 22) {
                      name = name.substring(0, 22) + '...';
                    }
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: colorPrimary,
                        onTap: () => Navigator.push(
                          context,
                          PageRouteBuilder<Null>(
                              pageBuilder: (BuildContext context,
                                  Animation<double> animation,
                                  Animation<double> secondaryAnimation) {
                                return AnimatedBuilder(
                                    animation: animation,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Opacity(
                                        opacity: animation.value,
                                        child: ProductDetail(
                                          modelProducts: modelProducts,
                                          tags: itemTags,
                                        ),
                                      );
                                    });
                              },
                              transitionDuration: Duration(milliseconds: 500)),
                        ),
                        child: _buildItem(modelProducts, index, context),
                      ),
                    );
                  }, firstPageErrorIndicatorBuilder: (context) {
                    // _providerHome!.isLoadedCats = true;
                    return Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.height / 4,
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: Icon(
                                  Icons.error_outline_outlined,
                                  color: Colors.red,
                                )),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width / 1.4,
                              child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                        text:
                                            S.of(context).anUnknownErrorOccuredn +
                                                '\n',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6!
                                            .copyWith(
                                                height: 1,
                                                fontWeight: FontWeight.bold),
                                        children: [
                                          TextSpan(
                                              text: S
                                                      .of(context)
                                                      .plzChknternetConnection +
                                                  '\n' +
                                                  S.of(context).tryAgain,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .headline6!
                                                  .copyWith(height: 2))
                                        ]),
                                  ))),
                          SizedBox(
                            height: 12.0,
                          ),
                          retryButtonListWidget(context),
                        ],
                      ),
                    );
                  }, noItemsFoundIndicatorBuilder: (_) {
                    _providerHome!.isLoadedCats = true;
                    return Container(
                      height: MediaQuery.of(context).size.height / 1.5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width / 2,
                            height: MediaQuery.of(context).size.height / 3,
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: Icon(
                                  Icons.search_off_outlined,
                                  color: colorPrimary,
                                )),
                          ),
                          Container(
                              width: MediaQuery.of(context).size.width / 2,
                              child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: Text(S.of(context).noResults))),
                        ],
                      ),
                    );
                  },
                    /*newPageProgressIndicatorBuilder: (_)
                    {
                      _providerHome!.isLoadedCats = false;
                      return  SizedBox(
                        height: 30.0,
                          width: 30.0,
                          child: CircularProgressIndicator());

                    }*/
                  ),
                ),
              ),
            ),
          ),
          /*PagedListView<int, Datum>(
            pagingController: _pagingController,
            shrinkWrap: true,
            builderDelegate: PagedChildBuilderDelegate<Datum>(
              itemBuilder: (context, modelProducts, index) {
                dataLoaded = true;

                List<String> itemTags = [];
                */ /*itemTags.add(products[index].slug.toString());
                  itemTags.add(products[index].name.toString());*/ /*
                String name = modelProducts.name!;
                if (name.length > 22) {
                  name = name.substring(0, 22) + '...';
                }
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: colorPrimary,
                    onTap: () => Navigator.push(
                      context,
                      PageRouteBuilder<Null>(
                          pageBuilder: (BuildContext context,
                              Animation<double> animation,
                              Animation<double> secondaryAnimation) {
                            return AnimatedBuilder(
                                animation: animation,
                                builder: (BuildContext context, Widget? child) {
                                  return Opacity(
                                    opacity: animation.value,
                                    child: ProductDetail(
                                      modelProducts: modelProducts,
                                      tags: itemTags,
                                    ),
                                  );
                                });
                          },
                          transitionDuration: Duration(milliseconds: 500)),
                    ),
                    child: Container(
                      // width: MediaQuery.of(context).size.width/1.2,
                      height: MediaQuery.of(context).size.height / 4.5,
                      child: Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: Row(
                          children: [
                            AspectRatio(
                              aspectRatio: 4.5 / 6,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Hero(
                                    tag: modelProducts.name.toString() +
                                        modelProducts.slug.toString(),
                                    child: CachedNetworkImage(
                                      placeholder: (context, s) =>
                                          Icon(Icons.camera),
                                      imageUrl: modelProducts.images!.isNotEmpty
                                          ? 'https://flk.sa/' +
                                              modelProducts.images![0]
                                          : 'jj',
                                      fit: BoxFit.cover,
                                      // width: MediaQuery.of(context).size.width / 3.7,
                                      height:
                                          MediaQuery.of(context).size.height / 5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                */ /*mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,*/ /*
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width -
                                        MediaQuery.of(context).size.width / 2.8,
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          end: listPadding!,
                                          top: listPadding! * 1.2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.8,
                                            child: Hero(
                                              tag: modelProducts.name.toString(),
                                              child: Material(
                                                child: Text(
                                                  modelProducts.name!,
                                                  style: TextStyle(
                                                      fontSize: Theme.of(context)
                                                          .textTheme
                                                          .headline3!
                                                          .fontSize),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Spacer(
                                            flex: 1,
                                          ),
                                          Icon(Icons.add_circle_outline,
                                              color: colorPrimary, size: 14.0),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Spacer(
                                    flex: 1,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width -
                                        MediaQuery.of(context).size.width / 2.8,
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.only(
                                          end: listPadding!,
                                          bottom: listPadding! * 1.2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          rateWidget(modelProducts),
                                          Spacer(
                                            flex: 1,
                                          ),
                                          Column(children: [
                                            Text(
                                              modelProducts.price! +
                                                  ' ' +
                                                  modelSettings!.data![0].value!,
                                              style: TextStyle(fontSize: 14.0),
                                            ),
                                            getDiscountWidget(modelProducts),
                                          ])
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              firstPageErrorIndicatorBuilder: (context){
                return Container(
                  height: MediaQuery.of(context).size.height / 1.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.height / 4,
                        child: FittedBox(
                            fit: BoxFit.contain,
                            child: Icon(
                              Icons.error_outline_outlined,
                              color: Colors.red,
                            )),
                      ),

                      Container(
                          width: MediaQuery.of(context).size.width / 1.4,
                          child: FittedBox(
                              fit: BoxFit.contain,
                              child: RichText( textAlign: TextAlign.center,text: TextSpan(text: S.of(context).anUnknownErrorOccuredn + '\n', style: Theme.of(context).textTheme.headline6!.copyWith(
                                height: 1,fontWeight: FontWeight.bold
                              ),children:[ TextSpan(text:S.of(context).plzChknternetConnection+ '\n' + S.of(context).tryAgain,style: Theme.of(context).textTheme.headline6!.copyWith(height: 2) )]),))),
                      SizedBox(height: 12.0,),
                      retryButtonListWidget(),
                    ],
                  ),
                );
              },
              noItemsFoundIndicatorBuilder: (_) => Container(
                height: MediaQuery.of(context).size.height / 1.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height / 3,
                      child: FittedBox(
                          fit: BoxFit.contain,
                          child: Icon(
                            Icons.search_off_outlined,
                            color: colorPrimary,
                          )),
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(S.of(context).noResults))),
                  ],
                ),
              ),
//firstPageProgressIndicatorBuilder: (_)=> Container(),
            ),
          ),*/
        ),
      ),
    );
    // } else {
    //    return Container();
    // }

    /*return Container(
      height: MediaQuery.of(context).size.height / 1.3,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: new Align(
            alignment: Alignment.bottomCenter,
            child: CircularProgressIndicator(

            )),
      ),
    );*/
  }

  getScreenUi(BuildContext context) {
    if ((!internet && (modelCats == null || modelProducts == null)) ||
        (modelCats != null &&
                    modelCats!.path == 'noint' &&
                    (modelProducts == null) ||
                (modelProducts != null && modelProducts!.path == 'noint')) &&
            !dataLoaded) {
      hideScrollBar();
      /*Fluttertoast.showToast(
          msg: S.of(context).noInternet,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/
      return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 4,
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: colorPrimary,
                  )),
            ),
            retryButtonWidget(context),
            Container(
                width: MediaQuery.of(context).size.width / 2,
                child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      S.of(context).noInternet,
                      style: TextStyle(height: 3),
                    ))),
          ],
        ),
      );
    } else if ((modelCats != null && modelProducts != null) &&
        (modelCats!.path == 'slint' || modelProducts!.path == 'slint') &&
        !dataLoaded) {
      hideScrollBar();
      /*Fluttertoast.showToast(
          msg: S.of(context).slowInternet,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/
      return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height / 4,
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    MyFlutterApp.slow_internet,
                    color: colorPrimary,
                  )),
            ),
            retryButtonWidget(context),
            Container(
                width: MediaQuery.of(context).size.width / 2,
                child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(S.of(context).slowInternet,
                        style: TextStyle(height: 3)))),
          ],
        ),
      );
    }

    return getAppWidget(context);
    // return _getIndexedStack(context);
  }

  Future<void> _fetchPage(
      int pageKey, BuildContext context, bool refresh) async {
    int index = index1;
    if (catQuery == '') {
      index = 0;
    }


    try {
      print('pagekeyssss  $pageKey');
      // print('pagekeyssss this' + this.pageKey.toString());

      final newItems = await _getProducts(context, index - 1, pageKey);
      allItems.addAll(newItems);
      _providerHome!.setIsLoaded(true);
//Timer(Duration(seconds: 2),()=> allItems.addAll(newItems) );

      /*_pagingController.value = PagingState(
          nextPageKey: pageKey++,
          itemList: newItems );
*/final isLastPage = newItems.length < _pageSize;
      if (refresh && !isLastPage) {
      //  allItems.addAll(newItems);
        _pagingController.value =
            PagingState(nextPageKey: ++pageKey, itemList: newItems);
       // allItems.addAll(newItems);

        //_pagingController.itemList = newItems;
      } else
      if(isLastPage && refresh){
        _pagingController.appendLastPage(newItems);
      //  _providerHome!.setIsLastPageCats(true);
        print('exec lala');
      }
      // _isFavorited.addAll(List.filled(newItems.length, false));

      if (isLastPage && !refresh) {
        // allItems.addAll(newItems);
        _pagingController.appendLastPage(newItems);
        // _providerHome!.setPageKey(1);
        _providerHome!.setIsLastPageCats(true);
      } else if (!refresh) {
        allItems.addAll(newItems);
        //_providerHome!.setPageKey(++_providerHome!.pageKey);
        //_providerHome!.setPageKey(++pageKey);
        final nextPageKey = _providerHome!.pageKey;
        print('execmorethan1   $nextPageKey');
        if (pageKey == 1) {
          allItems.clear();
          allItems.addAll(newItems);
          _pagingController.value =
              PagingState(nextPageKey: ++pageKey, itemList: newItems);
        } else {
          _pagingController.appendPage(newItems, nextPageKey.toInt());
        }
      }
      // _providerHome!.setPageKey(++pageKey);
    } catch (error) {
      _pagingController.error = error;
      /*Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/
    }
  }

  //static bool listen = true;

  /*@override
  _CategoriesState createState() => _CategoriesState();*/
}

/*@override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }*/

rateWidget(Datum modelProducts, BuildContext context) {
  if (modelProducts.rate != null) {
    return Row(
      children: [
        FittedBox(
          fit: BoxFit.contain,
          child: Icon(
            Icons.star_rate_rounded,
            color: Colors.yellow[700],
            size: 20.0,
          ),
        ),
        FittedBox(
          fit: BoxFit.contain,
          child: Text(modelProducts.rate!,
              style: TextStyle(
                fontSize: 14.0,
              )),
        )
      ],
    );
  } else {
    return Text('');
  }
}

/*_getProducts(BuildContext context) async {
    Fluttertoast.showToast(
        msg: '11 : _getProductWidget ',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: colorPrimary,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        fontSize: textLabelSize);
   // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      provider = Provider.of<ProviderHome>(context,listen: false);
      Provider.of<ProviderHome>(context,listen: false)
          .getProducts('', '', searchQuery);
      modelProducts = provider.modelProducts;
   // ProductWidget('', '', '');
   // });

   // if (provider.loaded) {
    //  modelProducts =  Provider.of<ProviderHome>(context,listen: false).modelProducts;
   // ProductWidget('', '', '');
  //  }
  }*/

/*getProductWidget2() {

  Consumer<ProviderHome>(
    builder: (_, snapShot, __) =>
        FutureBuilder<ModelProducts>(
            future: provider.modelProductsCats,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } else if (snapshot.hasData) {
                  // modelProducts.data.clear();
                  // List products = provider.modelProductsCats.
                  final List<String> imgList = [
                    'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
                    'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
                    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
                    // 'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
                    // 'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
                    // 'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
                  ];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: MediaQuery
                          .of(context)
                          .size
                          .height / 1.3,
                      child: ListView.separated(
                        itemCount: snapshot.data.data.length,
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        // physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width,
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 5,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Image.network(
                                      imgList[0],
                                      fit: BoxFit.cover,
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width / 3.5,
                                      height: MediaQuery
                                          .of(context)
                                          .size
                                          .width / 2,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Container(
                                            width:
                                            MediaQuery
                                                .of(context)
                                                .size
                                                .width / 2.5,
                                            child: Text(
                                                snapshot.data.data[index].name),
                                          ),
                                          Spacer(
                                            flex: 1,
                                          ),
                                          rateWidget(snapshot.data, index),
                                        ],
                                      ),
                                    ),
                                    Spacer(
                                      flex: 1,
                                    ),
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(
                                          top: 16.0, bottom: 16.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        crossAxisAlignment: CrossAxisAlignment
                                            .start,
                                        children: [
                                          Icon(
                                            Icons.add_circle_outline,
                                            color: colorPrimary,
                                          ),
                                          Spacer(
                                            flex: 1,
                                          ),
                                          Text(snapshot.data.data[index].price),
                                          //  rateWidget(modelProducts, index),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => new Divider(),
                      ),
                    ),
                  );
                } else {
                  return Text("No results");
                }
              } else if (snapshot.connectionState ==
                  ConnectionState.none) {
                return Container();
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
  );
}*/
rateWidget2(ModelProducts modelProducts, int index) {
  if (modelProducts.data![index].rate != null) {
    return Row(
      children: [
        Icon(
          Icons.star_rate_rounded,
          color: colorPrimary,
        ),
        Text(modelProducts.data![index].rate!),
      ],
    );
  }
}

/*Widget _buildBar(BuildContext context) {
    return new AppBar(
        centerTitle: true,

        automaticallyImplyLeading: false,
        toolbarHeight: toolbarHeight,
        title: Container(
          width: MediaQuery.of(context).size.width / 1.2,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: TextFormField(
            controller: textEditingController,
            style: Styles.getTextAdsStyle(),
            focusNode: focusNode,

            //  onTap: () => this._searchIcon = new Icon(Icons.close),
            //onChanged: (str) => onChanged(str),
            onFieldSubmitted: (str) => onSubmitted(str,context),
            textInputAction: TextInputAction.search,
            // controller: _filter,
            decoration: new InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              prefixIcon: new IconButton(
                  icon: _searchIcon,
                  onPressed: () =>
                      _searchPressed(textEditingController, focusNode!)),
              hintText: S.of(context).search,
            ),
          ),
        ));
  }*/

/*void onChanged(String newVal) {
    if (newVal != '') {
      setState(() {
        this._searchIcon = new Icon(Icons.close);
      });
    } else {
      setState(() {
        this._searchIcon = new Icon(Icons.search);
      });
    }
  }*/

/*_searchPressed(
      TextEditingController textEditingController, FocusNode focusNode) {
    // setState(() {
    if (this._searchIcon.icon == Icons.search) {
      */ /*setState(() {
       // this._searchIcon = new Icon(Icons.close);
      });*/ /*
      print('searchhhhhhhhhhhh');
      focusNode.requestFocus();
      //  this._searchIconButton = new IconButton(icon: _searchIcon, onPressed: onPressed);
      */ /* this._appBarTitle =
            Container(
              width: MediaQuery.of(context).size.width/1.2,
              decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.all(Radius.circular(8.0))),
              child: TextField(
              style: Styles.getTextDialogueStyle(),
           onSubmitted: onSubmitted(),
           // controller: _filter,
              decoration: new InputDecoration(

                  prefixIcon: new Icon(Icons.search),
                  hintText: searchHere
              ),

        ),
            );*/ /*
    } else {
      setState(() {
        this._searchIcon = new Icon(Icons.search);
        searchQuery = '';
        catQuery = '';
        showCursor = false;
        isReadOnly = true;
      });
      // if(FocusScope.of(context).hasFocus) {
      // focusNode.unfocus();
      //}

      textEditingController.clear();
      loading = true;
      _pagingController.refresh();
      //_getProducts(context, -1,pageKey);
      // this._appBarTitle = new Text( 'Search Example' );

    }
    //  });
  }*/

onPressed() {}

hideScrollBar() {
  /*setState(() {
      isAlwaysShown = false;
    });*/
}

/*Future<void> _fetchPage(int pageKey) async {
    try {
      int index = index1;
      if (catQuery == '') {
        index = 0;
      }
      print('index + $index');
      final newItems = await _getProducts(context, index-1, pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = ++this.pageKey;

        _pagingController.appendPage(newItems, nextPageKey.toInt());
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }*/

/*Future<void> _fetchPageSearch(int pageKey) async {
    try {
      final newItems = await _getProducts(context, -1, pageKey);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingControllerSearch.appendLastPage(newItems);
      } else {
        final nextPageKey = ++this.pageKey;

        _pagingControllerSearch.appendPage(newItems, nextPageKey.toInt());
      }
    } catch (error) {
      _pagingControllerSearch.error = error;
    }
  }*/

Widget getDiscountWidget(Datum modelProduct) {
  return (modelProduct != null &&
          modelProduct.discount != 'null' &&
          int.parse(modelProduct.discount.toString()) != 0)
      ? Text(
          (double.parse(modelProduct.price!) +
                  double.parse(modelProduct.discount!))
              .toString(),
          style: TextStyle(
              fontSize: 14.0,
              decoration: TextDecoration.lineThrough,
              decorationColor: Colors.red,
              decorationThickness: 2,
              decorationStyle: TextDecorationStyle.solid,
              height: 1.2),
          textAlign: TextAlign.center,
        )
      : Text('');
}

getDiscRate(Datum modelProduct) {
  if (modelProduct != null &&
      modelProduct.discount != 'null' &&
      int.parse(modelProduct.discount.toString()) != 0) {
    double disc = ((double.parse(modelProduct.discount!)) /
            double.parse(modelProduct.price!)) *
        100;
    int disc2 = disc.toInt();
    return Positioned(
      right: 0,
      top: 40,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0))),
        child: Text(
          '$disc2' + '%',
          style: TextStyle(color: Colors.white, fontSize: 12.0),
        ),
      ),
    );
  } else {
    return Text('');
  }
}

class TheSearch extends SearchDelegate<String?> {
  TheSearch({this.contextPage, this.controller});

  BuildContext? contextPage;
  TextEditingController? controller;

  // final suggestions1 = ["https://www.google.com"];

  /*@override
  String get searchFieldLabel => S.of(context).search;*/

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
        selectedRowColor: colorPrimary,
        textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.white,
            selectionHandleColor: Colors.black,
            selectionColor: Colors.black),
        hintColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
        textTheme: TextTheme(headline2: TextStyle(color: Colors.white)));
  }

  @override
  String get searchFieldLabel => '';

  @override
  Widget buildLeading(BuildContext context) {
    return Center(
      child: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        },
      ),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.trim().isEmpty) {
      FocusScope.of(context).requestFocus();
    } else {
      //  controller!.text = query.toString();
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        Provider.of<ProviderHome>(context, listen: false).setIsLoaded(true);
       // Provider.of<ProviderHome>(context, listen: false).setIsLastPageCats(false);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BottomNavHost(query, '', -1, false, 'l')));

        //  BottomNavHost.of(context).goToCats();
        StatefulWrapper.of(context).rebuild();
      });
    }
    return (Container());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
