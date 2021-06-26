import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app8/generated/l10n.dart';
import 'package:flutter_app8/icons/my_flutter_app_icons.dart';
import 'package:flutter_app8/models/ModelOrders.dart';
import 'package:flutter_app8/models/ModelSetting.dart';
import 'package:flutter_app8/providers/providerHome.dart';
import 'package:flutter_app8/providers/providerUser.dart';
import 'package:flutter_app8/screens/customwidgets/stateFulWrapper.dart';
import 'package:flutter_app8/styles/buttonStyle.dart';
import 'package:flutter_app8/styles/styles.dart';
import 'package:flutter_app8/values/SharedPreferenceClass.dart';
import 'package:flutter_app8/values/api.dart';
import 'package:flutter_app8/values/myApplication.dart';
import 'package:flutter_app8/values/myConstants.dart';
import 'package:fluttericon/brandico_icons.dart';
import 'package:fluttericon/entypo_icons.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:fluttericon/iconic_icons.dart';
import 'package:fluttericon/mfg_labs_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttericon/typicons_icons.dart';
import 'package:fluttericon/zocial_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:intl/intl.dart' hide TextDirection;
import 'package:provider/provider.dart';
import 'package:steps_indicator/steps_indicator.dart';

import 'CustomerOrdersDetailScreen.dart';

class Orders extends StatelessWidget {

  double? statusBarHeight;

  bool internet = true;
  ModelOrders? modelOrders;
  late ProviderHome provider;
  double? listPadding;

  bool isAlwaysShown = true;

  ModelSetting? modelSettings;
  ProviderUser? _providerUser;
  ProviderHome? _providerHome;

  int _pageSize = 6;
  final PagingController<int, Datum> _pagingController =
  PagingController(firstPageKey: 1);
  int pageKey = 1;

  
   initState(BuildContext context) {
     modelSettings =
         Provider.of<ProviderUser>(context, listen: false).modelSettings;
     modelOrders = Provider.of<ProviderHome>(context, listen: false).modelOrders;
     if(modelOrders == null || modelSettings == null) {
       _getPriceUnit(context, 'admin.\$');

     }

     _fetchPage(pageKey,context,false);
  


   
    MyApplication.initCache();
  }

  @override
  Widget build(BuildContext context) {
    if (_providerHome == null) {
      _providerHome = Provider.of<ProviderHome>(context, listen: false);
    }
    if (_providerUser == null) {
      _providerUser = Provider.of<ProviderUser>(context, listen: false);
    }
    modelSettings =
        Provider.of<ProviderUser>(context, listen: true).modelSettings;
    modelOrders =
        Provider.of<ProviderHome>(context, listen: true).modelOrders;
    if (listPadding == null) {
      listPadding = MediaQuery
          .of(context)
          .size
          .width / 25;
    }
    if (statusBarHeight == null) {
      statusBarHeight = MediaQuery
          .of(context)
          .padding
          .top;
    }
    scrollBarConfig();
    return StatefulWrapper(
      onInit:  initState(context),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: Styles.getAppBarStyleOrders(
            context, S
            .of(context)
            .orders, Octicons.list_ordered),
        body: Container(
          color: Colors.grey[300],
          // height: MediaQuery.of(context).size.height,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                color: Colors.white,
                height: 0,
              ),
              getScreenUi(context),
            ],
          ),
        ),
      ),
    );
  }

  getScreenUi(BuildContext context) {
    if (!internet && modelOrders == null) {
      return Container(
        height: MediaQuery
            .of(context)
            .size
            .height / 1.5,
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width / 2,
              height: MediaQuery
                  .of(context)
                  .size
                  .height / 4,
              color: Colors.grey[300],
              child: FittedBox(
                  fit: BoxFit.contain,
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: colorPrimary,
                  )),
            ),
            retryButtonWidget(context),
            Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width / 2,
                child: FittedBox(
                    fit: BoxFit.contain,
                    child: Text(
                      S
                          .of(context)
                          .noInternet,
                      style: TextStyle(
                          color: Theme
                              .of(context)
                              .textTheme
                              .headline1!
                              .color,
                          height: 3),
                    ))),
          ],
        ),
      );
    }
    /*else
      if (modelOrders != null && modelOrders!.path == 'slint') {
      */ /* Fluttertoast.showToast(
          msg: S.of(context).slowInternet,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/ /*
      return Container(
        height: MediaQuery.of(context).size.height / 1.5,
        color: Colors.grey[300],
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
                      style: TextStyle(
                          color: Theme.of(context).textTheme.headline1!.color,
                          height: 3)),
                )),
          ],
        ),
      );
    }*/

    return getAppWidget(context);
  }

  Widget getAppWidget(BuildContext context) {
    if (_providerUser!.modelSettings == null /*|| _providerHome!.modelOrders == null*/) {
      return
        //  MyTextWidgetLabel('loading.....', 'l', Colors.black, textLabelSize);
        Theme(
          data: Theme.of(context).copyWith(accentColor: Colors.black),
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height / 1.5,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(),
            ]),
          ),
        );
    } else {
      //   List orders = modelOrders!.data!;
      final List<String> imgList = [
        'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
        'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
        'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
        // 'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
        // 'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
        // 'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
      ];
      /*if (modelOrders!.data != null && modelOrders!.data!.length == 0) {
        //hideScrollBar();
        return
          Container(
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
                      FontAwesome.dropbox,
                      color: colorPrimary,
                    )),
              ),
              Container(
                  width: MediaQuery.of(context).size.width / 2,
                  child: FittedBox(
                      fit: BoxFit.contain, child: Text(S.of(context).youHaveNoOrdersYet))),
            ],
          ),
        );
      }*/
      return Padding(
          padding:
          EdgeInsets.only(top: 0.0, bottom: 0.0, right: 0.0, left: 0.0),
          child: Container(
            height: MediaQuery
                .of(context)
                .size
                .height / 1.3,
            child: RawScrollbar(
              radius: Radius.circular(scrollBarRadius),
              thumbColor: colorPrimary,
              isAlwaysShown: isAlwaysShown,
              child: NotificationListener<ScrollNotification>(
                  onNotification:   (ScrollNotification scrollNotification) {
                  //  _pagingController.addPageRequestListener((pageKey) {
                  if (scrollNotification is ScrollEndNotification &&
                      scrollNotification.metrics.extentAfter == 0 &&
                      !_providerHome!.isLastPageCats) {
                    // _providerHome!.setPageKey(++_providerHome!.pageKey);
                //    int key = ++pageKey;
                    print('pageKeyProvider  $key');

                    _fetchPage(++pageKey, context, false);
                  }
                  // });
                  return true;
                },
                child: RefreshIndicator(
                  onRefresh: () =>
                      Future.sync(() {
                        pageKey = 1;
                        _fetchPage(pageKey, context, true);
                      }),
                  child: PagedListView<int, Datum>(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<Datum>(
                        itemBuilder: (context, modelOrders, index) {
                          if (modelOrders.items!.length == 0) {
                            return Text('');
                          }
                          // print('length :'+ orders.length.toString());
                          String name = modelOrders.items![0].productId!.name!;
                          if (name.length > 22) {
                            name = name.substring(0, 22) + '...';
                          }
                          return InkWell(
                            onTap: () =>
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CustomerOrdersDetail(modelOrders)),
                                ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 12.0, bottom: 12.0, right: 8.0, left: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.0),
                                child: Container(
                                  color: Colors.white,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      splashColor: colorPrimary,
                                      /*onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProductDetail(
                                          modelProducts: modelProducts.data[index],
                                        )
                                    ),
                                  ),*/
                                      child: Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Container(
                                          width:
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .width /
                                              1.2,
                                          height:
                                          MediaQuery
                                              .of(context)
                                              .size
                                              .height /
                                              4.5,
                                          child: Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: Row(
                                              children: [
                                                AspectRatio(
                                                  aspectRatio: 4.5 / 6,
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(
                                                        12.0),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                      child: CachedNetworkImage(
                                                        placeholder: (con, str) =>
                                                            Image.asset(
                                                                'images/plcholder.jpeg'),
                                                        imageUrl: (modelOrders
                                                            .items !=
                                                            null &&
                                                            modelOrders.items![
                                                            0] !=
                                                                null &&
                                                            modelOrders
                                                                .items![0]
                                                                .productId !=
                                                                null &&
                                                            modelOrders
                                                                .items![0]
                                                                .productId!
                                                                .images!
                                                                .isNotEmpty)
                                                            ? 'https://flk.sa/' +
                                                            modelOrders
                                                                .items![0]
                                                                .productId!
                                                                .images![0]
                                                            : 'jj',
                                                        fit: BoxFit.cover,
                                                        width:
                                                        MediaQuery
                                                            .of(context)
                                                            .size
                                                            .width /
                                                            3.7,
                                                        height:
                                                        MediaQuery
                                                            .of(context)
                                                            .size
                                                            .height /
                                                            4.5,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    /*mainAxisAlignment: MainAxisAlignment.start,*/
                                                    //   crossAxisAlignment: CrossAxisAlignment.stretch,
                                                    children: [
                                                      SizedBox(
                                                        width: MediaQuery
                                                            .of(
                                                            context)
                                                            .size
                                                            .width -
                                                            MediaQuery
                                                                .of(context)
                                                                .size
                                                                .width /
                                                                2.9,
                                                        child: Padding(
                                                          padding: EdgeInsetsDirectional
                                                              .only(
                                                              end:
                                                              listPadding!,
                                                              top:
                                                              listPadding! *
                                                                  1.2),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Column(
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                                  crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                                  children: [
                                                                    Container(
                                                                      width: MediaQuery
                                                                          .of(
                                                                          context)
                                                                          .size
                                                                          .width /
                                                                          1.8,
                                                                      child: Text(
                                                                        name,
                                                                        style: TextStyle(
                                                                            fontSize: Theme
                                                                                .of(
                                                                                context)
                                                                                .textTheme
                                                                                .headline3!
                                                                                .fontSize),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                    Text(
                                                                      modelOrders
                                                                          .total
                                                                          .toString() +
                                                                          ' ' +
                                                                          modelSettings!
                                                                              .data![0]
                                                                              .value!,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                          14.0),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 10,
                                                                    ),
                                                                    optionsWidget(
                                                                        modelOrders,
                                                                        context),
                                                                  ]),
                                                              Spacer(
                                                                flex: 1,
                                                              ),
                                                              /*Icon(Icons.add_circle_outline,
                                                              color: colorPrimary,
                                                              size: MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                                  18),*/
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Spacer(
                                                        flex: 1,
                                                      ),
                                                      SizedBox(
                                                        width: MediaQuery
                                                            .of(
                                                            context)
                                                            .size
                                                            .width -
                                                            MediaQuery
                                                                .of(context)
                                                                .size
                                                                .width /
                                                                2.5,
                                                        child: Padding(
                                                          padding: EdgeInsetsDirectional
                                                              .only(
                                                              end:
                                                              listPadding!,
                                                              bottom:
                                                              listPadding! *
                                                                  1.2),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            mainAxisSize:
                                                            MainAxisSize.min,
                                                            children: [
                                                              getOrderStateStepper(
                                                                  modelOrders
                                                                      .status!,
                                                                  context),

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
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        noItemsFoundIndicatorBuilder: (context) =>
                            Container(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 1.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width / 2,
                                    height:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height / 3,
                                    child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Icon(
                                          FontAwesome.dropbox,
                                          color: colorPrimary,
                                        )),
                                  ),
                                  Container(
                                      width:
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .width / 2,
                                      child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Text(
                                              S
                                                  .of(context)
                                                  .youHaveNoOrdersYet))),
                                ],
                              ),
                            ),
                        firstPageErrorIndicatorBuilder: (context) {
                          if (modelOrders != null &&
                              modelOrders!.path == 'slint') {
                            /* Fluttertoast.showToast(
          msg: S.of(context).slowInternet,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/
                            return Container(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 1.5,
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width / 2,
                                    height:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height / 4,
                                    child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Icon(
                                          MyFlutterApp.slow_internet,
                                          color: colorPrimary,
                                        )),
                                  ),
                                  retryButtonWidget(context),
                                  Container(
                                      width:
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .width / 2,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(S
                                            .of(context)
                                            .slowInternet,
                                            style: TextStyle(
                                                color: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .headline1!
                                                    .color,
                                                height: 3)),
                                      )),
                                ],
                              ),
                            );
                          } else {
                            return Container(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height / 1.5,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width / 2,
                                    height:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .height / 4,
                                    child: FittedBox(
                                        fit: BoxFit.contain,
                                        child: Icon(
                                          Icons.error_outline_outlined,
                                          color: Colors.red,
                                        )),
                                  ),
                                  Container(
                                      width:
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .width / 1.4,
                                      child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: RichText(
                                            textAlign: TextAlign.center,
                                            text: TextSpan(
                                                text: S
                                                    .of(context)
                                                    .anUnknownErrorOccuredn +
                                                    '\n',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .headline6!
                                                    .copyWith(
                                                    height: 1,
                                                    fontWeight:
                                                    FontWeight.bold),
                                                children: [
                                                  TextSpan(
                                                      text: S
                                                          .of(context)
                                                          .plzChknternetConnection +
                                                          '\n' +
                                                          S
                                                              .of(context)
                                                              .tryAgain,
                                                      style: Theme
                                                          .of(context)
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
                          }
                        }

                      // separatorBuilder: (context, index) => new Divider(),
                    ),
                  ),
                ),
              ),
            ),
          ));
    }
  }

  getOrderStateStepper(String status, BuildContext context) {
    int selectedStep = 1;
    if (status.toLowerCase() == 'done') {
      selectedStep = 2;
    } else if (status.toLowerCase() == 'pending') {
      selectedStep = 0;
    }

    return
      Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 190.0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Spacer(flex: 1,),
                Text(
                  S
                      .of(context)
                      .pending,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10.0,
                    fontWeight: FontWeight.w500,
                    height: 2,),
                ),
                Spacer(flex: 4,),
                Text(
                  S
                      .of(context)
                      .charged,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w500,
                      height: 2),
                ),
                Spacer(flex: 4,),
                Text(
                  S
                      .of(context)
                      .done,
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 10.0,
                      fontWeight: FontWeight.w500,
                      height: 2),
                ),
                Spacer(flex: 2,),
                // SizedBox(width: 10.0,),
              ],),
          ),
          StepsIndicator(
            selectedStep: selectedStep,
            nbSteps: 3,
            doneLineThickness: 3.0,
            undoneLineThickness: 3.0,
            selectedStepColorOut: Colors.green,
            selectedStepColorIn: Colors.white,
            unselectedStepColorOut: Colors.black,
            unselectedStepColorIn: Colors.black,
            doneStepColor: Colors.blue,
            doneLineColor: Colors.green,
            undoneLineColor: Colors.grey,
            isHorizontal: true,
            lineLength: 50,
            doneStepSize: 33,
            unselectedStepSize: 25,
            selectedStepSize: 30,
            selectedStepBorderSize: 1,
            doneStepWidget: getStepIndicatorWidget(
                Colors.white, Colors.green, status, 10.0, 20.0),
            // Custom Widget
            unselectedStepWidget: getStepIndicatorWidget(
                Colors.white, Colors.grey, status, 10.0, 20.0),
            // Custom Widget
            selectedStepWidget: getStepIndicatorWidget(
                Colors.white, Colors.green, status, 10.0, 20.0),
            // Custom Widget
            lineLengthCustomStep: [
              StepsIndicatorCustomLine(nbStep: 0, length: 50.0,)
            ],
            enableLineAnimation: false,
            enableStepAnimation: false,
          ),

        ],);
  }

  getStepIndicatorWidget(Color? colorIn, Color? colorOut, String title,
      double sizeIn, double sizeOut) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [

        Container(
          height: sizeOut,
          width: sizeOut,
          decoration: BoxDecoration(color: colorOut, shape: BoxShape.circle),
          padding: EdgeInsets.all(5.0),
          child: Container(
            height: sizeIn,
            width: sizeIn,
            decoration: BoxDecoration(color: colorIn, shape: BoxShape.circle),
          ),
        ),

      ],
    );
  }

  getOptions(Datum modelOrders) {
    String optionsData = "";
    // Log.e("vars_length",String.valueOf(datumCustomerOrders.getItems().get(0).productId.getVars().size()));
    for (int i = 0; i < modelOrders.items![0].productId!.vars!.length; i++) {
      if (i == modelOrders.items![0].productId!.vars!.length - 1) {
        optionsData = optionsData +
            modelOrders.items![0].productId!.vars![i].name! +
            " : " +
            modelOrders.items![0].options![i];
      } else {
        optionsData = optionsData +
            modelOrders.items![0].productId!.vars![i].name! +
            " : " +
            modelOrders.items![0].options![i] +
            " | ";
      }
    }

    return optionsData;
  }

  Widget optionsWidget(Datum modelOrders, BuildContext context) {
    return modelOrders.items!.length == 0
        ? Text('')
        : Text(
      getOptions(modelOrders),
      textDirection: TextDirection.rtl,
      style: Styles.getTextGreyStyle(context),
    );
  }

  _getOrdersData(BuildContext context, int page) async {
    Api.context = context;
    print('fetch dataaaaaaaaaaaa');
    Api.orderPage = page;
    provider = Provider.of<ProviderHome>(context, listen: false);

    //  return;

    if (!await MyApplication.checkConnection()) {
      Api.context = context;
      print('iduser' + sharedPrefs.getCurrentUserId);
      await Provider.of<ProviderHome>(context, listen: false)
          .getOrders(sharedPrefs.getCurrentUserId);

      // setState(() {
      modelOrders = _providerHome!.modelOrders;

      internet = false;
      _providerHome!.notifyListeners();
      // });
    } else {
      print('iduser' + sharedPrefs.getCurrentUserId);
      await Provider.of<ProviderHome>(context, listen: false)
          .getOrders(sharedPrefs.getCurrentUserId);
      // setState(() {
      modelOrders = _providerHome!.modelOrders;
      _providerHome!.notifyListeners();
      // });
    }
    return modelOrders!.data!.toList();
  }

  scrollBarConfig() {
    if (isAlwaysShown) {
      Timer.periodic(Duration(milliseconds: 2100), (timer) {
        isAlwaysShown = false;
      });
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
          print('priceunitttt' + modelSettings!.data![0].value.toString());
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

  Future<void> _fetchPage(int pageKey, BuildContext context,bool refresh) async {
    try {
      print('dataaaaaaaaaaaa   $pageKey');
      final newItems = await _getOrdersData(context, pageKey);
      if (refresh) {
        _pagingController.value =
            PagingState(nextPageKey: ++pageKey, itemList: newItems);
        //_pagingController.itemList = newItems;
      }
      print('dataaaaaaaaaaaa');
      final isLastPage = newItems.length < _pageSize;

      if (isLastPage && !refresh ) {
        _pagingController.appendLastPage(newItems);
      } else if(!refresh) {
        final nextPageKey = this.pageKey++;

        _pagingController.appendPage(newItems, nextPageKey.toInt());
      }
    } catch (error) {
      _pagingController.error = error;
      /*Fluttertoast.showToast(
          msg: error.toString(),
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: colorPrimary,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM);*/
    }
  }

  retryButtonWidget(BuildContext context) {
    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width / 2,
      child: MyButton(
          onClicked: () async {
            if (await MyApplication.checkConnection()) {
              _getPriceUnit(context, 'admin.\$');
              pageKey = 1;
              _pagingController.refresh();
            }
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

  retryButtonListWidget(BuildContext context) {
    return SizedBox(
      width: MediaQuery
          .of(context)
          .size
          .width / 2,
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
}
