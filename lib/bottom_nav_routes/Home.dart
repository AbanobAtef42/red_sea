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
import 'package:flutter_app8/bottom_nav_routes/Categories.dart';
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
import 'package:flutter_app8/styles/buttonStyle.dart';
import 'package:flutter_app8/styles/styles.dart';
import 'package:flutter_app8/styles/textWidgetStyle.dart';
import 'package:flutter_app8/values/SharedPreferenceClass.dart';
import 'package:flutter_app8/values/api.dart';
import 'package:flutter_app8/values/myApplication.dart';
import 'package:flutter_app8/values/myConstants.dart';
import 'package:flutter_app8/providers/providerUser.dart';
import 'package:flutter_app8/values/myApplication.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:fluttericon/linecons_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  static var name = 'home';

  /*static ModelAds modelAds;
  static double statusBarHeight;
  static ModelCats modelCats;

  static ModelProducts modelProducts;*/
  final Function goToCats;
  Home(this.goToCats);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _current = 0;
  ModelAds? modelAds;
  double? statusBarHeight;
  ModelCats? modelCats;
  double? listPadding;
  ModelProducts? modelProducts;
  Icon _iconHeart = Icon(
    CupertinoIcons.heart_fill,
    color: Colors.grey,
    size: 25,
  );
  FocusNode focusNode = FocusNode();
  ScrollController _scrollController = new ScrollController();
  static const int _pageSize = 10;
  final PagingController<int, Datum> _pagingController =
      PagingController(firstPageKey: 0);
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

  ModelSetting? modelSettings;

  late List<GlobalKey<State<StatefulWidget>>> tags;

  int pageKey = 1;

  late ProviderHome newItemDeleted;

  bool isLoading = true;

  late Box<Datum>? boxFavs;

  bool? isExistFav;

  @override
  void initState() {
    _isFavorited = [];
    _favoriteIds = [];

    boxFavs = Hive.box(sharedPrefs.mailKey + dataBoxNameFavs);
    _getPriceUnit(context, 'admin.\$');
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    /*tags =
        List.generate(2, (value) => GlobalKey());*/

    super.initState();

    initCache();
    //_scrollController.addListener(() {

    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _getAds(context);
    _getCats(context);
    _getProducts(context, pageKey);

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

  @override
  Widget build(BuildContext context) {
    if (listPadding == null) {
      listPadding = MediaQuery.of(context).size.width / 25;
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: toolbarHeight,
        actions: [
          IconButton(icon:Icon( Icons.search,color: Colors.black,), onPressed: _showSearch),
          IconButton(icon:Icon( CupertinoIcons.heart_fill,color: Colors.black,), onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Favourites() ),
          ),),

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
        title: Icon(RpgAwesome.food_chain),
      ),
      body: RawScrollbar(
        thumbColor: colorPrimary,
        isAlwaysShown: isAlwaysShown,
        controller: _scrollController,
        radius: Radius.circular(8.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            /*crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,*/
            children: [
              Container(
                  // height: statusBarHeight,
                  ),
              getScreenUi(),
            ],
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
      if (this.mounted) {
        setState(() {
          modelAds = provider.modelAds;
          internet = false;
        });
      }
    } else {
      await Provider.of<ProviderHome>(context, listen: false).getAds();
      if (this.mounted) {
        setState(() {
          modelAds = provider.modelAds;
        });
      }
    }
  }

  _getCats(BuildContext context) async {
    provider = Provider.of<ProviderHome>(context, listen: false);
    await Provider.of<ProviderHome>(context, listen: false).getCats();
    if (this.mounted) {
      setState(() {
        modelCats = provider.modelCats;
      });
    }
  }

  Future<List<Datum>> _getProducts(BuildContext context, int page) async {
    Api.productPage = page;
    provider = Provider.of<ProviderHome>(context, listen: false);

    await Provider.of<ProviderHome>(context, listen: false)
        .getProducts('', '', '');
    if (this.mounted) {
      setState(() {
        modelProducts = provider.modelProducts;
      });
    }
    return modelProducts!.data!.toList();
  }

  Widget getAppWidget(BuildContext context) {
    if (modelAds == null ||
        modelCats == null ||
        modelProducts == null ||
        modelSettings == null) {
      isLoading = true;
    } else {
      isLoading = false;
    }
    if (isLoading) {
      hideScrollBar();
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
      scrollBarConfig();
      List urls = fetchUrls(modelAds!);
      List cats = modelCats!.data!;
      modelProducts!.data != null
          ? products = modelProducts!.data!
          : products = [];

      if (products.length > 0) {
        setState(() {
          dataLoaded = true;
        });
      }

      tags = List.generate(products.length * 2, (value) => GlobalKey());

      final List<Widget> imgList = [
        FittedBox(
            fit: BoxFit.cover,
            child: Icon(
              Icons.check_box_outline_blank_sharp,
              color: colorPrimary,
            ))
        // 'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
        // 'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
        // 'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
      ];
      return SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                      autoPlay:
                          modelAds!.data!.isEmpty || modelAds!.data!.length == 1
                              ? false
                              : true,
                      scrollPhysics:
                          modelAds!.data!.isEmpty || modelAds!.data!.length == 1
                              ? NeverScrollableScrollPhysics()
                              : BouncingScrollPhysics(),
                      height: MediaQuery.of(context).size.height / 3.7,
                      autoPlayInterval: Duration(seconds: 2),
                      onPageChanged: (index, reason) {
                        if (this.mounted) {
                          setState(() {
                            _current = index;
                          });
                        }
                      },
                      viewportFraction: modelAds!.data!.isNotEmpty ? 0.8 : 1.0),
                  items: /*modelAds!.data!.isNotEmpty  ?*/ modelAds!
                          .data!.isNotEmpty
                      ? modelAds!.data!
                          .map((item) => Stack(
                                children: [
                                  new Align(
                                    alignment: Alignment.topCenter,
                                    child: CachedNetworkImage(
                                      imageUrl: modelAds!.data!.isNotEmpty &&
                                              modelAds!.data![_current].image !=
                                                  null
                                          ? 'https://flk.sa/' + item.image!
                                          : 'jj',
                                      fit: BoxFit.fill,
                                      width:
                                          MediaQuery.of(context).size.width / 1,
                                      height:
                                          MediaQuery.of(context).size.height /
                                              3.8,
                                    ),
                                  ),
                                  new Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Container(
                                              color: colorSemiWhite2,
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                modelAds!
                                                    .data![
                                                        _current /*imgList.indexOf(item)*/
                                                        ]
                                                    .title!,
                                                style: Styles.getTextAdsStyle(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ), //urls.indexOf(item)
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Container(
                                              color: colorSemiWhite2,
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                modelAds!
                                                    .data![
                                                        _current /*imgList.indexOf(item)*/
                                                        ]
                                                    .description!,
                                                style: Styles.getTextAdsStyle(),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          MyButton(
                                            onClicked: () {
                                              _launchURL(
                                                  'https://foryou.flk.sa/store/' +
                                                      modelAds!.data![_current]
                                                          .title!);
                                            },
                                            child: Text(
                                              modelAds!
                                                  .data![
                                                      _current /*imgList.indexOf(item)*/
                                                      ]
                                                  .button!,
                                              style:
                                                  Styles.getTextDialogueStyle(),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ))
                          .toList()
                      : imgList.map((e) => e).toList(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: modelAds!.data!.map((item) {
                int index = modelAds!.data!.indexOf(item);
                return Container(
                  width: _current == index ? 16.0 : 8.0,
                  height: _current == index ? 16.0 : 8.0,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? colorPrimary
                        : Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                );
              }).toList(),
            ),
            /*Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                height: MediaQuery.of(context).size.height / 6,
                width: MediaQuery.of(context).size.width,
                child: Scrollbar(
                  child: ListView.builder(
                      itemCount: cats.length,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        print(cats[index].slug + 'catQueryhomecats2');
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BottomNavHost('',
                                        cats[index].slug.toString(), index + 1),
                                  ));
                              */ /*BottomNavHost.searchQueryFun = '';
                              BottomNavHost.catQueryFun = cats[index].slug.toString();
                              BottomNavHost.catsIndex = index;
                                widget.goToCats();*/ /*
                            },
                            */ /*Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Categories(cats[index].slug, '')))*/ /*
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          placeholder: (context, s) =>
                                              Icon(Icons.camera),
                                          imageUrl: modelCats!
                                                      .data!.isNotEmpty &&
                                                  modelCats!
                                                          .data![index].image !=
                                                      null
                                              ? 'https://flk.sa/' +
                                                  modelCats!.data![index].image!
                                              : 'jj',
                                          fit: BoxFit.cover,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4,
                                        ),
                                      ),
                                      radius: 30,
                                    ),
                                    // SizedBox(height: 10,),
                                    Text(cats[index].name),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            ),*/
            /*AspectRatio(
              aspectRatio: 16 / 9,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    child: CachedNetworkImage(
                      placeholder: (context, s) => Icon(Icons.camera),
                      imageUrl: modelAds!.data!.isNotEmpty &&
                              modelAds!.data![0].image!.isNotEmpty
                          ? 'https://flk.sa/' + modelAds!.data![0].image!
                          : 'jj',
                      fit: BoxFit.fill,
                      // width: MediaQuery.of(context).size.width / 1.05,
                      height: MediaQuery.of(context).size.height / 3,
                    ),
                  ),
                ),
              ),
            ),*/
            SizedBox(
              height: 30.0,
            ),
            RefreshIndicator(
              onRefresh: () => Future.sync(() {
                pageKey = 1;
                _pagingController.refresh();
              }),
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0, left: 10.0),
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
                      itemTags.add(
                          products[index % products.length].slug.toString());
                      itemTags.add(
                          products[index % products.length].name.toString());
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
                          child: _buildItem(modelProducts, products, index),
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
                            retryButtonListWidget(),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ]));
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

  rateWidget(Datum modelProducts) {
    if (modelProducts.rate != null) {
      return Row(
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: Icon(
              Icons.star_rate_rounded,
              color: Colors.yellow[700],
              size: MediaQuery.of(context).size.width / RateTextDividerBy,
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

  getScreenUi() {
    if (!internet &&
            (modelAds == null || modelCats == null || modelProducts == null) ||
        (modelCats != null &&
                modelCats!.path == 'noint' &&
                (modelAds == null || modelProducts == null)) &&
            !dataLoaded) {
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
                    Icons.wifi_off_rounded,
                    color: colorPrimary,
                  )),
            ),
            retryButtonWidget(),
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
            retryButtonWidget(),
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
        if (this.mounted) {
          setState(() {
            isAlwaysShown = false;
          });
        }
      });
    }
  }

  hideScrollBar() {
    setState(() {
      isAlwaysShown = false;
    });
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
      setState(() {
        if (sharedPrefs.exertedPriceUnitKey.isEmpty) {
          modelSettings = null;
          internet = false;
        } else {
          print('shared setting price');
          modelSettings = new ModelSetting();
          List<Datum2> datums = [];
          datums.add(Datum2(value: sharedPrefs.exertedPriceUnitKey));
          modelSettings!.data = datums;
        }
        //   modelSettings = Provider.of<ProviderUser>(context, listen: false).modelSettings;
      });
    } else {
      print('exeinternetprice');
      if (sharedPrefs.priceUnitKey == '') {
        await Provider.of<ProviderUser>(context, listen: false)
            .getSettingsData();

        if (this.mounted) {
          setState(() {
            modelSettings =
                Provider.of<ProviderUser>(context, listen: false).modelSettings;
            SharedPrefs().priceUnit(modelSettings!.data![0].value.toString());
            SharedPrefs()
                .exertedPriceUnit(modelSettings!.data![0].value.toString());
            // print(modelSettings!.data.toString()+'--------');
          });
        }
      } else {
        setState(() {
          print('shared setting price');
          modelSettings = new ModelSetting();
          List<Datum2> datums = [];
          datums.add(Datum2(value: sharedPrefs.priceUnitKey));
          modelSettings!.data = datums;
        });
      }
    }
  }

  void _launchURL(String url) async =>
      await canLaunch(url) ? await launch(url) : throw 'Could not launch $url';

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await _getProducts(context, pageKey);

      // _isFavorited.addAll(List.filled(newItems.length, false));
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
                children: [
                TextSpan(
                    text: ' ' + modelSettings!.data![0].value.toString(),
                    style: TextStyle(
                        fontSize: 14.0,
                        decoration: TextDecoration.none,
                        color: Colors.black45,
                        decorationStyle: TextDecorationStyle.solid,
                        height: 1.2)),
              ])

            //
            )
        : Text('');
  }

  Future<void> _showSearch() async {
    FocusScope.of(context).requestFocus(focusNode);
    await showSearch(
      context: context,
      delegate: TheSearch(contextPage: context),
    );
  }

  retryButtonWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: MyButton(
          onClicked: () async {
            if (await MyApplication.checkConnection()) {
              setState(() {
                internet = true;
                isLoading = true;
              });
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

  retryButtonListWidget() {
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

  _buildItem(Datum modelProducts, List<Datum> products, int index) {
    String name = modelProducts.name!;
    if (name.length > 13) {
      name = name.substring(0, 12) + '...';
    }
    _isFavorited.insert(index, false);
    _favoriteIds.insert(index, modelProducts.id!);
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
                      placeholder: (context, s) => Icon(Icons.camera),
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
              Positioned(
                right: 0,
                top: 40,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius:
                          BorderRadius.only(topLeft: Radius.circular(15.0))),
                  child: Text(
                    '20%',
                    style: TextStyle(color: Colors.white, fontSize: 12.0),
                  ),
                ),
              ),
              Positioned(
                left: 15,
                top: 15,
                child: GestureDetector(
                  onTap: () {
                    onIconHeartClick(modelProducts, index);
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
              padding: EdgeInsetsDirectional.only(top: 8.0),
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
                        rateWidget(modelProducts),
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
                        end: listPadding!,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // rateWidget(modelProducts),
                          Spacer(
                            flex: 1,
                          ),
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
                  Padding(
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
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Icon onIconHeartStart(Datum modelProduct, int index) {
    bool isFavourite = _isFavorited[index];
    print('fffffffffffdddd');
    List<Datum?> datums = boxFavs!.values
        .where((element) => element.id == modelProduct.id)
        .toList();
    if (datums.length > 0) {
      _isFavorited[index] = true;
    }

    if (_isFavorited[index]) {
      print('ffffffffffffff');

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

  onIconHeartClick(Datum modelProducts, int index) {
    print('fffffffffffdddd' + index.toString());
    List<Datum?> datums = boxFavs!.values
        .where((element) => element.id == modelProducts.id)
        .toList();
    if (datums.length == 0) {
      print('ffffffffffffff');
      boxFavs!.add(modelProducts);
      setState(() {
        _isFavorited[index] = true;
        /*this._iconHeart = new Icon(
          CupertinoIcons.heart_fill,
          color: Colors.red,
        );*/
      });
    } else {
      setState(() {
        /*this._iconHeart = new Icon(
          CupertinoIcons.heart_fill,
          color: Colors.grey,
        );*/
        _isFavorited[index] = false;
        Iterable<dynamic> key = boxFavs!.keys
            .where((element) => boxFavs!.get(element)!.id == modelProducts.id);
        boxFavs!.delete(key.toList()[0]);
      });
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
                builder: (context) => BottomNavHost(query, '', -1)));
      });
    }
    return (Container());
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
