import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app8/bottom_nav_routes/Cart.dart';

import 'package:flutter_app8/generated/l10n.dart';

import 'package:flutter_app8/icons/my_flutter_app_icons.dart';
import 'package:flutter_app8/models/ModelAds.dart';
import 'package:flutter_app8/models/ModelCats.dart';
import 'package:flutter_app8/models/ModelProducts.dart';
import 'package:flutter_app8/models/ModelSetting.dart';

import 'package:flutter_app8/providers/providerHome.dart';
import 'package:flutter_app8/providers/providerUser.dart';
import 'package:flutter_app8/screens/BottomNavScreen.dart';
import 'package:flutter_app8/screens/FavsScreen.dart';

import 'package:flutter_app8/screens/ProductDetailScreen.dart';

import 'package:flutter_app8/screens/customwidgets/CarouselSlider.dart';
import 'package:flutter_app8/screens/customwidgets/keepAliveWidget.dart';
import 'package:flutter_app8/screens/customwidgets/stateFulWrapper.dart';
import 'package:flutter_app8/styles/buttonStyle.dart';
import 'package:flutter_app8/styles/styles.dart';

import 'package:flutter_app8/values/SharedPreferenceClass.dart';
import 'package:flutter_app8/values/api.dart';
import 'package:flutter_app8/values/myApplication.dart';
import 'package:flutter_app8/values/myConstants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:url_launcher/url_launcher.dart';

class Home extends StatelessWidget {
  static var name = 'home';

  /*static ModelAds modelAds;
  static double statusBarHeight;
  static ModelCats modelCats;

  static ModelProducts modelProducts;*/

  final bool signedInOut;
  final String sourceRoute;

  ProviderUser? _providerUser;

  Home(this.signedInOut, this.sourceRoute);

  /*@override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {*/
  int _current = 0;
  ModelAds? modelAds;
  double? statusBarHeight;
  ModelCats? modelCats;
  double? listPadding;
  ModelProducts? modelProducts;
  final CarouselController _carouselController = CarouselController();
  Icon _iconHeart = Icon(
    CupertinoIcons.heart_fill,
    color: Colors.grey,
    size: 25,
  );
  FocusNode focusNode = FocusNode();
  ScrollController _scrollController = new ScrollController();
  static const int _pageSize = 10;
  int pageKey = 1;
  final PagingController<int, Datum> _pagingController =
      PagingController(firstPageKey: 1);
  late var provider;
  late var provider2;
  late List<bool> _isFavorited;
  late List<int> _favoriteIds;
  bool adsSlow = false;
  bool catsSlow = false;
  bool prosSlow = false;
  bool internet = true;
  bool isAlwaysShown = true;
  bool dataLoaded = false;
  ProviderHome? _providerHome;
  ModelSetting? modelSettings;

  late List<GlobalKey<State<StatefulWidget>>> tags;

  late ProviderHome newItemDeleted;

  bool isLoading = true;

  late Box<Datum>? boxFavs;
  List<Datum> allItems = [];

  bool? isExistFav;

  void initState(BuildContext context) {
    _isFavorited = [];
    _favoriteIds = [];

    boxFavs = Hive.box(sharedPrefs.mailKey + dataBoxNameFavs);
    _getPriceUnit(context, 'admin.\$');
    // _current = Provider.of<ProviderHome>(context).currentAdIndex;

    // _pagingController.addPageRequestListener((pageKe
    // });

    modelSettings =
        Provider.of<ProviderUser>(context, listen: false).modelSettings;
    modelAds = Provider.of<ProviderHome>(context, listen: false).modelAds;
    modelProducts =
        Provider.of<ProviderHome>(context, listen: false).modelProducts;
    if (modelAds == null ||
        // Provider.of<ProviderHome>(context,listen: false).modelCats == null ||
        modelProducts == null ||
        modelSettings == null) {
      _getPriceUnit(context, 'admin.\$');
      _getAds(context);
      //_getProducts(context, 1);
      _fetchPage(1, context, false);
      //  _getCats(context);
      // _getProducts(context, this.pageKey);
    }
    /*tags =
        List.generate(2, (value) => GlobalKey());*/

    // super.initState();

    initCache();
    //_scrollController.addListener(() {

    // });
  }

  /*@override
  void dispose() {
    super.dispose();
  }*/

  /* @override
  void didChangeDependencies() {
    */ /*modelSettings = Provider.of<ProviderUser>(context,listen: true).modelSettings;
    modelAds = Provider.of<ProviderHome>(context,listen: true).modelAds;
    modelProducts = Provider.of<ProviderHome>(context,listen: true).modelProducts;*/ /*
    if (
    modelAds == null ||
        // Provider.of<ProviderHome>(context,listen: false).modelCats == null ||
        modelProducts == null
        ||modelSettings == null

    ) {
      _getPriceUnit(context, 'admin.\$');
      _getAds(context);
      _getCats(context);
      _getProducts(context, 1);
    }
    newItemDeleted = Provider.of<ProviderHome>(context, listen: false);
    newItemDeleted.addListener(() {
      print('execsetstpro');
      if (newItemDeleted.newItemDeleted && newItemDeleted.proId != -1)
        // setState(() {
        // _isFavorited[_favoriteIds.indexOf(newItemDeleted.proId)] = false;
        //  });
        newItemDeleted.removeListener(() {});
    });

    statusBarHeight = MediaQuery.of(context).padding.top;
    super.didChangeDependencies();
  }
*/
  @override
  Widget build(BuildContext context) {
    print('building.....');

    if (listPadding == null) {
      listPadding = MediaQuery.of(context).size.width / 25;
    }
    if (_providerHome == null) {
      _providerHome = Provider.of<ProviderHome>(context, listen: false);
    }

    if (_providerUser == null) {
      _providerUser = Provider.of<ProviderUser>(context, listen: false);
    }
    if (allItems.isEmpty && signedInOut && sourceRoute == 'l' && this.pageKey == 1) {
      print('building.....    $pageKey');
      _providerHome!.setIsLastPage(false);
     // this.pageKey = 1;
      _fetchPage(1, context, true);
    }
    modelSettings =
        Provider.of<ProviderUser>(context, listen: true).modelSettings;
    modelAds = Provider.of<ProviderHome>(context, listen: true).modelAds;
    modelProducts =
        Provider.of<ProviderHome>(context, listen: true).modelProducts;

    return StatefulWrapper(
      onInit: () => initState(context),
      child: Scaffold(
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
            ),
          ]),
        ),
        body: RawScrollbar(
          thumbColor: colorPrimary,
          isAlwaysShown: isAlwaysShown,
          controller: _scrollController,
          radius: Radius.circular(8.0),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollNotification) {
              //  _pagingController.addPageRequestListener((pageKey) {
              if (scrollNotification is ScrollEndNotification &&
                  scrollNotification.metrics.extentAfter == 0 &&
                  !_providerHome!.isLastPage) {
                // _providerHome!.setPageKey(++_providerHome!.pageKey);
                int key = _providerHome!.pageKey;
                print('pageKeyProvider  $key');

                _fetchPage(++pageKey, context, false);
              }
              // });
              return true;
            },
            child: RefreshIndicator(
              onRefresh: () => Future.sync(() {
                _providerHome!.setIsLastPage(false);
                //  _providerHome!.setPageKey(1);
                this.pageKey = 1;
                //_pagingController.itemList!.clear();

                _fetchPage(1, context, true);
                // _pagingController.refresh();
                //_pagingController.itemList = [];
              }),
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  /*crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,*/
                  children: [
                    Container(
                        // height: statusBarHeight,
                        ),
                    getScreenUi(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _getAds(BuildContext context) async {
    provider = Provider.of<ProviderHome>(context, listen: false);

    //  return;

    if (!await MyApplication.checkConnection()) {
      await Provider.of<ProviderHome>(context, listen: false).getAds();
      // if (this.mounted) {
      // setState(() {
      modelAds = provider.modelAds;
      internet = false;
      // });
      // }
    } else {
      await Provider.of<ProviderHome>(context, listen: false).getAds();
      //if (this.mounted) {
      // setState(() {
      modelAds = provider.modelAds;
      //  });
      //}
    }
  }

  _getCats(BuildContext context) async {
    provider = Provider.of<ProviderHome>(context, listen: false);
    await Provider.of<ProviderHome>(context, listen: false).getCats();
    // if (this.mounted) {
    //  setState(() {
    modelCats = provider.modelCats;
    //  });
    //}
  }

  Future<List<Datum>> _getProducts(BuildContext context, int page) async {
    Api.context = context;
    Api.productPage = page;
    provider = Provider.of<ProviderHome>(context, listen: false);

    await Provider.of<ProviderHome>(context, listen: false)
        .getProducts('', '', '');
    //if (this.mounted) {
    /*setState(() {
      modelProducts = provider.modelProducts;
    });*/
    // }
    return /*modelProducts!.data != null ? */ _providerHome!.modelProducts.data!
        .toList(); /*:[];*/
  }

  Widget getAppWidget(BuildContext context) {
    /*modelSettings =
        Provider.of<ProviderUser>(context, listen: true).modelSettings;
    modelAds = Provider.of<ProviderHome>(context, listen: true).modelAds;
    modelProducts =
        Provider.of<ProviderHome>(context, listen: true).modelProducts;*/
    if (modelAds == null || modelProducts == null || modelSettings == null) {
      isLoading = true;
    } else {
      isLoading = false;
    }
    if (isLoading) {
      //  hideScrollBar();
      return
          //  MyTextWidgetLabel('loading.....', 'l', Colors.black, textLabelSize);

          Container(
        height: MediaQuery.of(context).size.height,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(),
        ]),
      );
    } else {
      List<Datum> products;
      // scrollBarConfig();

      modelProducts!.data != null
          ? products = modelProducts!.data!
          : products = [];

      if (products.length > 0) {
        /*setState(() {
          dataLoaded = true;
        });*/
      }

      tags = List.generate(products.length * 2, (value) => GlobalKey());

      final List<Widget> imgList = [
        FittedBox(
          fit: BoxFit.cover,
          child: Image.asset('images/plcholder.jpeg'),
        )
        // 'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
        // 'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
        // 'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
      ];
      return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CarouselSlider2(
              modelAds: modelAds!,
              context: context,
            ),
            Container(
              //color: colorPrimary,
              height: 30.0,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0, left: 10.0),
              child: KeepAlivePage(
                key: Key('paged'),
                child: PagedGridView<int, Datum>(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    childAspectRatio: 100 / 170,
                    crossAxisSpacing: 0,
                    mainAxisSpacing: 10,
                    crossAxisCount: 2,
                  ),
                  pagingController: _pagingController,
                  shrinkWrap: true,
                  //  physics:AlwaysScrollableScrollPhysics() ,
                  physics: NeverScrollableScrollPhysics(),
                  builderDelegate: PagedChildBuilderDelegate<Datum>(
                    itemBuilder: (context, modelProducts, index) {
                      List<String> itemTags = [];
                      /*itemTags.add(
                            products[index % products.length].slug
                                .toString());
                        itemTags.add(
                            products[index % products.length].name
                                .toString());*/
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
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return Opacity(
                                          opacity: animation.value,
                                          child: ProductDetail(
                                            modelProducts: modelProducts,
                                            tags: itemTags,
                                          ),
                                        );
                                      });
                                },
                                transitionDuration:
                                    Duration(milliseconds: 500)),
                          ),
                          child: _buildItem(
                              modelProducts, products, index, context),
                        ),
                      );
                    },
                    firstPageErrorIndicatorBuilder: (context) {
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
                                          text: S
                                                  .of(context)
                                                  .anUnknownErrorOccuredn +
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
                    },
                  ),
                ),
              ),
            ),
          ]);
    }
  }

  fetchUrls(ModelAds modelAds) {
    List urls = [];
    final List<String> imgList = [
      'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
      'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
      'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
      // 'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
      // 'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
      // 'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
    ];
    for (int i = 0; i < modelAds.data!.length; i++) {
      String url = Api.uri + '/' + modelAds.data![i].image!;
      urls.add(url);
    }
    return urls;
  }

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

  getScreenUi(BuildContext context) {
    if (!internet && (modelAds == null || modelProducts == null) ||
        (modelCats != null &&
                modelCats!.path == 'noint' &&
                (modelAds == null || modelProducts == null)) &&
            !dataLoaded) {
      // hideScrollBar();
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
                    child: Text(S.of(context).noInternet,
                        style: TextStyle(height: 3)))),
          ],
        ),
      );
    } else if ((modelAds != null &&
            modelCats != null &&
            modelProducts != null &&
            modelSettings != null) &&
        (modelAds!.path == 'slint' ||
            modelCats!.path == 'slint' ||
            modelProducts!.path == 'slint' ||
            modelSettings!.path == 'slint') &&
        !dataLoaded) {
      /* Fluttertoast.showToast(
          msg: S.of(context).slowInternet,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/
      //hideScrollBar();
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
  }

  scrollBarConfig() {
    if (isAlwaysShown) {
      Timer.periodic(Duration(milliseconds: 2100), (timer) {
        isAlwaysShown = false;
      });
    }
  }

  hideScrollBar() {
    isAlwaysShown = false;
  }

  initCache() {
    if (!kIsWeb) {
      getApplicationDocumentsDirectory().then((dir) {
        Api.cacheStore =
            DbCacheStore(databasePath: dir.path, logStatements: true);
      });
    } else {
      Api.cacheStore = DbCacheStore(databasePath: 'db', logStatements: true);
    }
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
        // });
      } else {
        print('shared setting price');
        _providerUser!.modelSettings = new ModelSetting();

        List<Datum2> datums = [];
        datums.add(Datum2(value: sharedPrefs.exertedPriceUnitKey));
        _providerUser!.modelSettings!.data = datums;
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
        // });
      }
    }
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  Future<void> _fetchPage(
      int pageKey, BuildContext context, bool refresh) async {
    try {
      print('pagekeyssss  $pageKey');
      print('pagekeyssss this' + this.pageKey.toString());

      final newItems = await _getProducts(context, pageKey);

      /*_pagingController.value = PagingState(
          nextPageKey: pageKey++,
          itemList: newItems );
*/
      if (refresh) {
        _pagingController.value =
            PagingState(nextPageKey: ++pageKey, itemList: newItems);
        allItems.addAll(newItems);
        //_pagingController.itemList = newItems;
      }
      // _isFavorited.addAll(List.filled(newItems.length, false));
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage && !refresh) {
        allItems.addAll(newItems);
        _pagingController.appendLastPage(newItems);
        // _providerHome!.setPageKey(1);
        _providerHome!.setIsLastPage(true);
      } else if (!refresh) {
        //_providerHome!.setPageKey(++_providerHome!.pageKey);
        //_providerHome!.setPageKey(++pageKey);
        allItems.addAll(newItems);
        final nextPageKey = _providerHome!.pageKey;
        print('execmorethan1   $nextPageKey');
        _pagingController.appendPage(newItems, nextPageKey.toInt());
      }
      // _providerHome!.setPageKey(++pageKey);
    } catch (error) {
      _pagingController.error = error;
      Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);
    }
  }

  Widget getDiscountWidget(Datum modelProduct) {
    return (modelProduct != null &&
            modelProduct.discount != 'null' &&
            int.parse(modelProduct.discount.toString()) != 0)
        ? RichText(
            text: TextSpan(
            text: (double.parse(modelProduct.price!) +
                    double.parse(modelProduct.discount!))
                .toString(),
            style: TextStyle(
                fontSize: 14.0,
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.red,
                decorationThickness: 2,
                color: Colors.black45,
                decorationStyle: TextDecorationStyle.solid,
                height: 1.2),
            /* children: [
               */ /* TextSpan(
                    text: ' ' + modelSettings!.data![0].value.toString(),
                    style: TextStyle(
                        fontSize: 14.0,
                        decoration: TextDecoration.none,
                        color: Colors.black45,
                        decorationStyle: TextDecorationStyle.solid,
                        height: 1.2)),*/ /*
              ]*/
          )

            //
            )
        : Text('');
  }

  Future<void> _showSearch(BuildContext context) async {
    FocusScope.of(context).requestFocus(focusNode);
    await showSearch(
      context: context,
      delegate: TheSearch(contextPage: context),
    );
  }

  retryButtonWidget(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: MyButton(
          onClicked: () async {
            if (await MyApplication.checkConnection()) {
              //  setState(() {
              internet = true;
              isLoading = true;
              //  });
              _getAds(context);
              _getCats(context);
              _getProducts(context, pageKey);
              _getPriceUnit(context, 'admin.\$');
            }
          },
          child: Row(
            children: [
              Text(
                'ReTry',
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

  retryButtonListWidget(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: MyButton(
          onClicked: () async {
            // pageKey = 1;
            // _fetchPage(1, context);
            _providerHome!.setPageKey(1);
            _pagingController.refresh();
          },
          child: Row(
            children: [
              Text(
                'ReTry',
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

  _buildItem(Datum modelProducts, List<Datum> products, int index,
      BuildContext context) {
    String name = modelProducts.name!;
    if (name.length > 13) {
      name = name.substring(0, 12) + '...';
    }
    _isFavorited.insert(index, false);
    _favoriteIds.insert(index, modelProducts.id!);
    return Selector<ProviderHome, ModelProducts>(
        selector: (buildContext, countPro) {
      return ModelProducts();
    }, builder: (context, data, child) {
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
                    Padding(
                      padding: EdgeInsetsDirectional.only(
                        start: listPadding!,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      //  mainAxisSize: MainAxisSize.min,
                        children: [
                          // rateWidget(modelProducts),
                          /*Spacer(
                            flex: 1,
                          ),*/
                          Row(children: [
                            Text(
                              modelProducts.price! +
                                  ' ' +
                                  _providerUser!
                                      .modelSettings!.data![0].value!,
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
    });
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
      isExistFav = true;
      return _iconHeart;

      //});
    } else {
      Icon _iconHeart = new Icon(
        CupertinoIcons.heart_fill,
        color: Colors.grey,
      );
      isExistFav = true;
      return _iconHeart;
    }
  }

  onIconHeartClick(Datum modelProducts, int index, BuildContext context) {
    print('fffffffffffdddd' + index.toString());
    Provider.of<ProviderHome>(context, listen: false).getHomeState();
    List<Datum?> datums = boxFavs!.values
        .where((element) => element.id == modelProducts.id)
        .toList();
    if (datums.length == 0) {
      print('ffffffffffffff');
      boxFavs!.add(modelProducts);
      Provider.of<ProviderHome>(context, listen: false).notifyListeners();
      // setState(() {
      _isFavorited[index] = true;
      /*this._iconHeart = new Icon(
          CupertinoIcons.heart_fill,
          color: Colors.red,
        );*/
      //  });
    } else {
      // setState(() {
      /*this._iconHeart = new Icon(
          CupertinoIcons.heart_fill,
          color: Colors.grey,
        );*/
      _isFavorited[index] = false;
      Iterable<dynamic> key = boxFavs!.keys
          .where((element) => boxFavs!.get(element)!.id == modelProducts.id);
      boxFavs!.delete(key.toList()[0]);
      Provider.of<ProviderHome>(context, listen: false).notifyListeners();
      //  });
    }
  }

  getDiscRate(Datum modelProduct) {
    if (modelProduct != null &&
        modelProduct.discount != 'null' &&
        int.parse(modelProduct.discount.toString()) != 0) {
      double disc = (( double.parse(modelProduct.discount!) /(double.parse(modelProduct.price!)+double.parse(modelProduct.discount!))))*100 ;
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
            '$disc2'+'%',
            style: TextStyle(color: Colors.white, fontSize: 12.0),
          ),
        ),
      );
    } else {
      return Text('');
    }
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
    } else {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    BottomNavHost(query, '', -1, false, 'h')));
      });
    }
    return (Container());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
