import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app8/generated/l10n.dart';
import 'package:flutter_app8/models/ModelProducts.dart';
import 'package:flutter_app8/providers/providerHome.dart';
import 'package:flutter_app8/styles/styles.dart';
import 'package:flutter_app8/values/SharedPreferenceClass.dart';
import 'package:flutter_app8/values/myConstants.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'ProductDetailScreen.dart';

class Favourites extends StatefulWidget {
  @override
  _FavouritesState createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  var listPadding;
  late Box<Datum> dataBox;
 late  ProviderHome newItemDeleted;
  List<Datum> list = [];
  bool isAlwaysShown = true;
  ScrollController _scrollController = new ScrollController();
  Widget? appBarTitle;

  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
  bool _isSearching = false;
  String _searchText = "";
  AppBar? _appBar;
  var statusBarHeight;

  bool searchEmpty = false;

  late List<GlobalKey<State<StatefulWidget>>> tags;

  @override
  void initState() {
    super.initState();
    dataBox = Hive.box( sharedPrefs.mailKey + dataBoxNameFavs);
    list = dataBox.values.toList();
    newItemDeleted = Provider.of<ProviderHome>(context,listen: false);
    _scrollController.addListener(() {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
       // currentFocus.unfocus();
      }
    });
    tags =
        List.generate(2, (value) => GlobalKey());

  }

  @override
  Widget build(BuildContext context) {
    if (statusBarHeight != null) {
      statusBarHeight = MediaQuery.of(context).padding.top;
    }
    if (appBarTitle == null) {
      appBarTitle = Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(
            CupertinoIcons.heart_circle,
            color: Colors.white,
            size: 35,
          ),
          SizedBox(
            width: 8.0,
          ),
          Text(S.of(context).favs),
        ]),
      );
    }
    return Scaffold(
      appBar: AppBar(centerTitle: true, toolbarHeight: toolbarHeight,title: appBarTitle, actions: <Widget>[
        Padding(
          padding: const EdgeInsetsDirectional.only(end: 10.0),
          child: new IconButton(
            icon: actionIcon,
            onPressed: () => onPressed(),
          ),
        )
      ]),
      body: RawScrollbar(
        thumbColor: colorPrimary,
        isAlwaysShown: isAlwaysShown,
        controller: _scrollController,
        radius: Radius.circular(8.0),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: statusBarHeight,
                ),
                ValueListenableBuilder(
                  valueListenable: dataBox.listenable(),
                  builder: (context, Box<Datum> items, _) {
                    List<int> keys = items.keys.cast<int>().toList();
                    return _getProductWidget(keys, context, items);
                  },
                ),
              ]),
        ),
      ),
    );
  }

  Widget _getProductWidget(
      List<int> keys, BuildContext context, Box<Datum> items) {
    //loading = provider.loadedCats;
    // List<Datum> list = modelProducts.data;
    /*  setState(() {
      provider = Provider.of<ProviderHome>(context,listen: false);
    });*/

    if (listPadding == null) {
      listPadding = MediaQuery.of(context).size.width / 25;
    }

    /*return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Align(
              alignment: Alignment.bottomCenter,
              child: CircularProgressIndicator(

              )),
        ),
      );*/
    if(_isSearching && searchEmpty && items.length != 0)
    {
      return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                    fit: BoxFit.contain, child: Text(S.of(context).noResults))),
          ],
        ),
      );
    }
    if (items.length == 0) {
      return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                width: MediaQuery.of(context).size.width / 1.5,
                child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(S.of(context).noProInWishList))),
          ],
        ),
      );
    }
    scrollBarConfig();
    final List<String> imgList = [
      'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
      'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
      'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
    ];

    // scrollBarConfig();
    int count;

    if (_isSearching && _searchQuery.text.isNotEmpty) {
      count = list.length;
    } else {
      count = keys.length;
    }
    tags =
        List.generate(count*2, (value) => GlobalKey());
    print('counttttt'+ count.toString());
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: GridView.count(
        crossAxisCount: 2,
          childAspectRatio: 100 / 170,
          crossAxisSpacing: 0,
          mainAxisSpacing: 10,

        scrollDirection: Axis.vertical,
        //controller: _scrollController,

        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
children: List.generate(list.length, (index) {
    return _buildItem(list[index]);
    })));

        /*itemBuilder: (BuildContext context, Datum modelProducts,int index) {
          List<String> itemTags = [];

          Datum? modelProducts;
          if (_isSearching && _searchQuery.text.isNotEmpty) {
            modelProducts = list[index];
            itemTags.add(modelProducts.slug.toString());
            itemTags.add(modelProducts.name.toString());
          } else {
            final int key = keys[index];
            modelProducts = items.get(key);
            if (modelProducts != null) {
              itemTags.add(modelProducts.slug.toString());
              itemTags.add(modelProducts.name.toString());
            }
          }
          String name = modelProducts!.name!;
          if (name.length > 22) {
            name = name.substring(0, 22) + '...';
          }

          return Dismissible(
              onDismissed: (_) {
                dataBox.deleteAt(index);
                newItemDeleted.getHomeState(true, dataBox.getAt(index)!.id!);
              },
              key: Key(
                  modelProducts.slug.toString() + modelProducts.id.toString()),
              child: Material(
                  color: Colors.transparent,
                  child: _buildItem(modelProducts,  index), *//*InkWell(
                splashColor: colorPrimary,
                onTap: () => Navigator.push(
                  context,
                  PageRouteBuilder<Null>(
                      pageBuilder: (BuildContext context, Animation<double> animation,
                          Animation<double> secondaryAnimation) {
                        return AnimatedBuilder(
                            animation: animation,
                            builder: (BuildContext context, Widget? child) {
                              return Opacity(
                                opacity: animation.value,
                                child:ProductDetail(
                                  modelProducts: modelProducts,tags: itemTags,) ,
                              );
                            });
                      },
                      transitionDuration: Duration(milliseconds: 500)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 4.5,
                    child: Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        children: [
                          AspectRatio(
                            aspectRatio: 4.5/6,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Hero(
                                  tag: modelProducts.name.toString()+modelProducts.slug.toString(),
                                  child: CachedNetworkImage(
                                       placeholder:(context,s)=> Icon(Icons.camera),imageUrl: modelProducts.images != null ? 'https://flk.sa/'+ modelProducts.images![0] : 'jj' ,
                                    fit: BoxFit.cover,
                                   // width: MediaQuery.of(context).size.width / 3.7,
                                    height: MediaQuery.of(context).size.height / 4.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              *//* *//*mainAxisAlignment: MainAxisAlignment.start,
                                                                crossAxisAlignment: CrossAxisAlignment.start,*//* *//*
                              children: [
                                SizedBox(
                                  width: MediaQuery.of(context).size.width -
                                      MediaQuery.of(context).size.width / 2.8,
                                  child: Padding(
                                    padding: EdgeInsetsDirectional.only(
                                        end: listPadding, top: listPadding * 1.2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width /
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
                                            color: colorPrimary,
                                            size: 14.0),

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
                                        end: listPadding,
                                        bottom: listPadding * 1.2),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        rateWidget(modelProducts),
                                        Spacer(
                                          flex: 1,
                                        ),
                                        Text(

                                          modelProducts.price! + ' '+sharedPrefs.exertedPriceUnitKey,
                                          style: TextStyle(

                                              fontSize: 14.0),

                                        ),

                                        //  rateWidget(modelProducts, index),
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
              ),*//*
                 ),
              );
        }*/


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

  rateWidget(Datum modelProducts) {
    if (modelProducts.rate != null) {
      return Row(
        children: [
          FittedBox(
            fit: BoxFit.contain,
            child: Icon(
              Icons.star_rate_rounded,
              color: colorPrimary,
              size: 14.0,
            ),
          ),
          FittedBox(
              fit: BoxFit.contain,
              child: Text(
                modelProducts.rate!,
                style: TextStyle(
                    fontSize:
                        14.0),
              )),
        ],
      );
    } else {
      return Text('');
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

  onPressed() {
    setState(() {
      if (this.actionIcon.icon == Icons.search) {
        this.actionIcon = new Icon(
          Icons.close,
          color: Colors.white,
        );
        this.appBarTitle = Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: Theme(
            data: Theme.of(context).copyWith(
              inputDecorationTheme: InputDecorationTheme(border: InputBorder.none),
            ),
            child: new TextField(
              controller: _searchQuery,

              style: new TextStyle(
                color: Colors.black,
              ),
              onChanged: (String query) => onChanged(query),
              decoration: new InputDecoration(
                prefixIcon: new Icon(Icons.search, color: colorPrimary),
                hintText: S.of(context).search,
                hintStyle: new TextStyle(color: Colors.black54),
              ),
            ),
          ),
        );
        //  this._appBar = Styles.getAppBarStyleSearch(context, S.of(context).favs, Icons.refresh,actionIcon,()=>print(''));
        _handleSearchStart();
      } else {
        // this._appBar = Styles.getAppBarStyleSearch(context, S.of(context).favs, Icons.refresh,Icon(Icons.close),()=>print(''));

        _handleSearchEnd();
      }
    });
  }

  void _handleSearchStart() {
    setState(() {
      _isSearching = true;
      // actionIcon = new Icon(Icons.search,color: Colors.white,);
    });
  }

  void _handleSearchEnd() {

    setState(() {
      list = dataBox.values.toList();
      actionIcon = new Icon(
        Icons.search,
        color: Colors.white,
      );
    searchEmpty = false;
      this.appBarTitle =
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
            CupertinoIcons.heart_circle,
            color: Colors.white,
            size: 35,
        ),
        SizedBox(
            width: 8.0,
        ),
        Text(S.of(context).favs),
      ]),
          );
      _isSearching = false;
     // list.clear();
      _searchQuery.clear();
    });
  }

  onChanged(String query) {
    searchEmpty = false;
    print('database hive' + '');
    setState(() {
      list = dataBox.values.where((element) => element.name!.contains(_searchQuery.text)).toList();
      if(list.isEmpty)
      {
        searchEmpty = true;
      }
    });
  }
 Widget _buildItem(Datum modelProducts) {
    String name = modelProducts.name!;
    if (name.length > 13) {
      name = name.substring(0, 12) + '...';
    }

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
                      placeholder:(con,str)=> Image.asset('images/plcholder.jpeg'),
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
                    onIconHeartClick(modelProducts);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border()),
                    child: onIconHeartStart(modelProducts),
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
              padding: EdgeInsetsDirectional.only(top: 12.0,bottom: 18.0),
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
                                  ' '  + ' '+sharedPrefs.exertedPriceUnitKey,
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
                 /* Padding(
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
  getDiscRate(Datum modelProduct){
    return (modelProduct != null &&
        modelProduct.discount != 'null' &&
        int.parse(modelProduct.discount.toString()) != 0)
        ? Positioned(
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
    ):Text('');
  }

  Icon onIconHeartStart(Datum modelProduct) {

    print('fffffffffffdddd');
    List<Datum?> datums = dataBox.values
        .where((element) => element.id == modelProduct.id)
        .toList();




      Icon _iconHeart = new Icon(
        CupertinoIcons.heart_fill,
        color: Colors.red,
      );

      return _iconHeart;

      //});

  }

  onIconHeartClick(Datum modelProducts) {
   // print('fffffffffffdddd' + index.toString());
    List<Datum?> datums = dataBox.values
        .where((element) => element.id == modelProducts.id)
        .toList();
    if (datums.length == 0 ) {
      print('ffffffffffffff');
      dataBox.add(modelProducts);
      setState(() {

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

        Iterable<dynamic> key = dataBox.keys
            .where((element) => dataBox.get(element)!.id == modelProducts.id);
        dataBox.delete(key.toList()[0]);
        list = dataBox.values.toList();
      });
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
            /*children: [
              TextSpan(
                  text: ' ' + sharedPrefs.exertedPriceUnitKey,
                  style: TextStyle(
                      fontSize: 14.0,
                      decoration: TextDecoration.none,
                      color: Colors.black45,
                      decorationStyle: TextDecorationStyle.solid,
                      height: 1.2)),
            ]*/)

      //
    )
        : Text('');
  }
}
