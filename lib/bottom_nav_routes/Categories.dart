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
import 'package:flutter_app8/screens/ProductDetailScreen.dart';
import 'package:flutter_app8/styles/buttonStyle.dart';
import 'package:flutter_app8/styles/styles.dart';
import 'package:flutter_app8/styles/textWidgetStyle.dart';
import 'package:flutter_app8/values/SharedPreferenceClass.dart';
import 'package:flutter_app8/values/api.dart';
import 'package:flutter_app8/values/myApplication.dart';
import 'package:flutter_app8/values/myConstants.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class Categories extends StatefulWidget {
  final String catQuery;
  final String searchQuery;
  final int catIndex;
  final Key rebuild;

  static String name = 'category';
  const Categories(this.catQuery, this.searchQuery, this.catIndex, this.rebuild)
      : super(key: rebuild);

  //static bool listen = true;

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState
    extends State<Categories> /*with  AutomaticKeepAliveClientMixin*/ {
  ModelCats? modelCats;
  ModelProducts? modelProducts;
  ModelProducts? modelProducts2;
  double? listPadding;
  String catQuery = '';
  String trendQuery = '';
  String searchQuery = '';
  double? statusBarHeight;
  bool dataLoaded = false;
  bool listen = true;
  int index1 = 0;
  Icon _searchIcon = new Icon(Icons.search);
  FocusNode? focusNode;
  // IconButton _searchIconButton = new IconButton();
  final TextEditingController textEditingController =
      new TextEditingController();
  ProviderHome? provider;

  bool loading = false;
  bool adsSlow = false;
  bool catsSlow = false;
  bool prosSlow = false;
  bool internet = true;

  var x = 0;

  var _appBarTitle;
  ScrollController _scrollController = ScrollController();
  int pageKey = 1;
  static const int _pageSize = 10;
  final PagingController<int, Datum> _pagingController =
      PagingController(firstPageKey: 1);
  final PagingController<int, Datum> _pagingControllerCats =
      PagingController(firstPageKey: 0);
  final PagingController<int, Datum> _pagingControllerSearch =
      PagingController(firstPageKey: 0);
  PagingController<int, Datum> _pagingControllerMain =
      PagingController(firstPageKey: 0);

  bool? isAlwaysShown;

  bool internetp = true;

  ModelSetting? modelSettings;

  late List<GlobalKey<State<StatefulWidget>>> tags;

  bool isReadOnly = false;

  bool showCursor = true;

  @override
  void initState() {
    provider = Provider.of<ProviderHome>(context, listen: false);
    focusNode = new FocusNode();
    isAlwaysShown = true;
    catQuery = widget.catQuery;
    print('catQueryhomecats' + ' ' + catQuery);
    searchQuery = widget.searchQuery;
    if (searchQuery != '') {
      textEditingController.text = searchQuery.toString();
    }
    if (widget.catIndex != -1) {
      index1 = widget.catIndex;
    }
    _getCats(context);
    _getPriceUnit(context, 'admin.\$');
    _getProducts(context, -1, pageKey);
    _pagingControllerCats.addPageRequestListener((pageKey) {
      print('execpagingcats' + pageKey.toString());
      _fetchPageCats(this.pageKey);
    });
    _pagingController.addPageRequestListener((pageKey) {
      print('execpaging' + pageKey.toString());
      _fetchPage(pageKey);
    });

    _pagingControllerSearch.addPageRequestListener((pageKey) {
      _fetchPageSearch(pageKey);
    });
    super.initState();
    _scrollController.addListener(() {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    });

    MyApplication.initCache();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    /*Fluttertoast.showToast(
        msg: 'build : build ',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: colorPrimary,
        textColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        fontSize: textLabelSize);*/
    //  print('init stateeeeee');
    print('init stateeeeee');
    return Scaffold(
      /*appBar: AppBar(
                title: Text(cats,
              ),*/
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
      ), //_buildBar(context) as PreferredSizeWidget?,
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
            getScreenUi(),
          ],
        ),
      ),
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
    if (modelCats == null || modelProducts == null || modelSettings == null) {
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
    List cats = modelCats!.data == null ? [] : modelCats!.data!;

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
                itemCount: cats.length+1,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  if (index == index1 ) {
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
                                            index ==0 ? 'All' :
                                        cats[index-1].name,
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
                                    child: Text( index == 0 ? 'All' :
                                  cats[index-1].name,
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
        _getProductWidget(modelProducts),
      ],
    );
  }

  rateWidget(Datum modelProducts) {
    if (modelProducts.rate != null) {
      return Row(
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: Icon(
              Icons.star_rate_rounded,
              color: colorPrimary,
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

  _getCats(BuildContext context) async {
    // final provider = Provider.of<ProviderHome>(context, listen: false);
    if (!await MyApplication.checkConnection()) {
      await Provider.of<ProviderHome>(context, listen: false).getCats2();
      setState(() {
        modelCats = provider!.modelCats2;
        internet = false;
      });
    } else {
      await Provider.of<ProviderHome>(context, listen: false).getCats2();
      if (this.mounted) {
        setState(() {
          modelCats = provider!.modelCats2;
        });
      }
    }
  }

  _getProducts(BuildContext context, int index, int page) async {
    Api.context = context;
    Api.productPage = page;
    if (searchQuery != '') {
      this._pagingControllerMain = _pagingControllerSearch;
    } else if (catQuery != '') {
      _pagingControllerMain = _pagingControllerCats;
      _pagingControllerMain.refresh();
    }
    //this._pagingControllerMain = _pagingControllerCats;

    else {
      _pagingControllerMain = _pagingController;
    }
    // Directory path = await getApplicationDocumentsDirectory();
    //Api.cacheStore =  DbCacheStore(databasePath: path.path, logStatements: true);
    /*getApplicationDocumentsDirectory().then((dir) {
      CacheStore cacheStore = DbCacheStore(databasePath: dir.path, logStatements: true);
      Api.dio = Dio(Api.options);
      Api.dio.interceptors.add(DioCacheInterceptor(options: CacheOptions(store: cacheStore)));

   setState(() {

   });


      // Api().path = dir.path;
    });*/

    //  provider = Provider.of<ProviderHome>(context, listen: false);
    //  WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    // loading = true;
    /*if(modelProducts != null) {
      if (Provider
          .of<ProviderHome>(context, listen: false)
          .modelProductsCats
          .data != null) {
        Provider
            .of<ProviderHome>(context, listen: false)
            .modelProductsCats
            .data
            .clear();
      }
    }*/

    await Provider.of<ProviderHome>(context, listen: false)
        .getProductsCats(catQuery, searchQuery, trendQuery);
    /*if(this.mounted && index == -1){
       modelProducts = new ModelProducts();
     }*/
    print('catttttt' + catQuery);
    if ((this.mounted && index == -1) ||
        (this.mounted &&
            modelCats != null &&
            catQuery == modelCats!.data![index].slug)) {
      if (!await MyApplication.checkConnection()) {
        setState(() {
          modelProducts = provider!.modelProductsCats;
          internetp = false;
          loading = false;
        });
        return modelProducts!.data;
      } else {
        setState(() {
          internetp = true;
          Timer.periodic(Duration(milliseconds: 0), (timer) {
            loading = false;
          });

          modelProducts = provider!.modelProductsCats;
          /*if(modelProducts == null)
          {
            modelProducts = new ModelProducts();
          }*/
        });
        return modelProducts!.data;
      }
    }
    return modelProducts!.data;
    //  modelProducts2 = modelProducts;
    /* setState(() {
         provider = Provider.of<ProviderHome>(context,listen: false);
       });*/
  }

  _getProductsBuild(BuildContext context) async {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      // provider = Provider.of<ProviderHome>(context, listen: false);

      Provider.of<ProviderHome>(context, listen: false)
          .getProducts('', searchQuery, '');
    });
    modelProducts = provider!.modelProducts;
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

  _getProductsByCat(BuildContext context, String catQuery) async {
    // modelProducts2 = null;
    final provider = Provider.of<ProviderHome>(context);
    await Provider.of<ProviderHome>(context).getProducts('', '', catQuery);
    modelProducts2 = provider.modelProducts;
    // _getProductWidget();
  }

  onListItemTap(ModelCats? modelCats, int index, BuildContext context,
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
    setState(() {
      index1 = index;
      searchQuery = '';
      catQuery = index == 0 ? '' : modelCats!.data![index-1].slug!;
      trendQuery = '';
      // _pagingControllerMain = _pagingControllerCats;

      loading = true;
      pageKey = 1;
      // this.modelCats = provider.modelCats;
      //modelProducts = new ModelProducts();

     // print('catQuery2' + modelCats!.data![index].slug!);
    });
    _pagingController.refresh();
    //_getProducts(context, index1, pageKey);
  }

  Widget _getProductWidget(ModelProducts? modelProducts) {
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
    } else if (modelProducts!.path == 'slint') {
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
            retryButtonWidget(),
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

    if (modelProducts.data != null &&
        modelProducts.data!.length == 0 &&
        false) {
      hideScrollBar();


    }



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
      child: RefreshIndicator(
        onRefresh: () => Future.sync(
          () {
            pageKey = 1;
            _pagingController.refresh();
          },
        ),
        child: PagedListView<int, Datum>(
          pagingController: _pagingController,
          shrinkWrap: true,
          builderDelegate: PagedChildBuilderDelegate<Datum>(
            itemBuilder: (context, modelProducts, index) {
              dataLoaded = true;

              List<String> itemTags = [];
              /*itemTags.add(products[index].slug.toString());
                itemTags.add(products[index].name.toString());*/
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
                              /*mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,*/
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

  Widget _buildBar(BuildContext context) {
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
            onChanged: (str) => onChanged(str),
            onFieldSubmitted: (str) => onSubmitted(str),
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
  }

  void onChanged(String newVal) {
    if (newVal != '') {
      setState(() {
        this._searchIcon = new Icon(Icons.close);
      });
    } else {
      setState(() {
        this._searchIcon = new Icon(Icons.search);
      });
    }
  }

  _searchPressed(
      TextEditingController textEditingController, FocusNode focusNode) {
    // setState(() {
    if (this._searchIcon.icon == Icons.search) {
      /*setState(() {
       // this._searchIcon = new Icon(Icons.close);
      });*/
      print('searchhhhhhhhhhhh');
      focusNode.requestFocus();
      //  this._searchIconButton = new IconButton(icon: _searchIcon, onPressed: onPressed);
      /* this._appBarTitle =
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
            );*/
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
  }

  onPressed() {}
  onSubmitted(String query) async {
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
      searchQuery = query;
      print('query' + query);
      //   x = 0;
      this._searchIcon = new Icon(Icons.close);
      // modelProducts = null;
      //
      // provider = Provider.of<ProviderHome>(context, listen: false);

      modelProducts = provider!.modelProductsCats;
      setState(() {
        textEditingController.text = searchQuery.toString();
        searchQuery = query;
        loading = true;
        pageKey = 1;
        catQuery = '';

        //

        // });
      });
      _pagingController.refresh();
      // _getProducts(context, -1,pageKey);
    }
  }

  getScreenUi() {
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
            retryButtonWidget(),
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
    if (isAlwaysShown!) {
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
            if (modelSettings != null) {
              SharedPrefs().priceUnit(modelSettings!.data![0].value.toString());
              SharedPrefs()
                  .exertedPriceUnit(modelSettings!.data![0].value.toString());
            }
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

  Future<void> _fetchPage(int pageKey) async {
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
  }

  Future<void> _fetchPageCats(int pageKey) async {
    try {
      final newItems = await _getProducts(context, index1, pageKey);

      print('wwwwwwwwwww' + index1.toString());
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingControllerCats.appendLastPage(newItems);
      } else {
        final nextPageKey = ++this.pageKey;

        _pagingControllerCats.appendPage(newItems, nextPageKey.toInt());
      }
    } catch (error) {
      _pagingControllerCats.error = error;
    }
  }

  Future<void> _fetchPageSearch(int pageKey) async {
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
  }

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

  retryButtonWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: MyButton(
          onClicked: () async {
            if (await MyApplication.checkConnection()) {
              setState(() {
                internet = true;
                catQuery = '';
                searchQuery = '';
                trendQuery = '';
              });
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

  Future<void> _showSearch() async {
    FocusScope.of(context).requestFocus(focusNode);
    await showSearch(
      context: context,
      delegate:
          TheSearch(contextPage: context, controller: textEditingController),
      query: textEditingController.text.toString(),
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
      //  controller!.text = query.toString();
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
