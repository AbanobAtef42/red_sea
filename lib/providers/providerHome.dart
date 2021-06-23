import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app8/models/ModelAds.dart';
import 'package:flutter_app8/models/ModelCats.dart';
import 'package:flutter_app8/models/ModelOrders.dart';
import 'package:flutter_app8/models/ModelProducts.dart';
import 'package:flutter_app8/values/api.dart';

class ProviderHome with ChangeNotifier {
  bool isLastPage = false;
  bool isLastPageCats = false;
  ModelAds? modelAds = new ModelAds();
  ModelCats? modelCats;
  ModelCats? modelCats2;
  ModelProducts modelProducts = new ModelProducts();
  ModelProducts? modelProductsCats;
  ModelOrders? modelOrders;
  int index1 = 0;
   int proId = -1;
String? sentOrder;
  bool loaded = false;
  bool newItemDeleted = false;
  static bool slowInternetAds = false;
  static bool slowInternetCats = false;
  static bool slowInternetPros = false;
  bool? loadingCats;

  String? state;

  int pageKey = 2;
  int pageKeyCats = 2;

  getAds() async {
    final Api api = Api();
    slowInternetAds = false;
    modelAds = await api.adsApi("ads");

    notifyListeners();
  }

  getCats() async {
    final Api api = Api();
    slowInternetCats = false;
    modelCats = await api.catsApi("category");

    notifyListeners();
  }
  getCats2() async {
    final Api api = Api();
    slowInternetCats = false;
    modelCats2 = await api.catsApi("category");

    notifyListeners();
  }

  getProducts(String catQuery, String searchQuery, String trendQuery) async {
    final Api api = Api();
    loaded = false;
    slowInternetPros = false;
    modelProducts =
        await api.productsApi("products", catQuery, trendQuery, searchQuery);
    if (modelProducts == null) modelProducts = new ModelProducts();
    loaded = true;
    notifyListeners();
  }

  getProductsCats(
      String catQuery, String searchQuery, String trendQuery) async {

    final Api api = Api();
    loadingCats = true;
    // modelProductsCats = null;
    modelProductsCats = await api.productsApi("products", catQuery, trendQuery,
        searchQuery); //) as Future<ModelProducts>;

    loadingCats = false;
    notifyListeners();
  }

  getOrders(String id) async {
    final Api api = Api();

    modelOrders =
        await api.getOrdersApi('orders?customer_id='+id); //) as Future<ModelProducts>;

    notifyListeners();
  }
  sendOrder(Map<String,Object?> data) async {
    final Api api = Api();


   sentOrder = await api.orderRequestApi('orders', data) ;//) as Future<ModelProducts>;

    notifyListeners();
  }
  checkInventoryForOrder(Map<String,Object?> data) async {
    final Api api = Api();


    state = await api.inventoryCheckApi('inventory/check', data) ;//) as Future<ModelProducts>;

    notifyListeners();
  }

  getCatIndex(int index) {
    index = this.index1;
    notifyListeners();
  }
  getHomeState(){

    notifyListeners();
  }
  setIsLastPage(bool isLast){
    this.isLastPage = isLast;
    notifyListeners();
  }
  setIsLastPageCats(bool isLast){
    this.isLastPage = isLast;
    notifyListeners();
  }
  setPageKey(int pageKey){
    this.pageKey = pageKey;
    notifyListeners();
  }
  setPageKeyCats(int pageKey){
    this.pageKeyCats = pageKey;
    notifyListeners();
  }
}
