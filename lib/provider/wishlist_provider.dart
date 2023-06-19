import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/data/model/response/wishlist_model.dart';
import 'package:flutter_grocery/data/repository/wishlist_repo.dart';
import 'package:flutter_grocery/helper/api_checker.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';


class WishListProvider extends ChangeNotifier {
  final WishListRepo? wishListRepo;

  WishListProvider({required this.wishListRepo});

  List<Product>? _wishList;
  List<Product>? get wishList => _wishList;
  Product? _product;
  Product? get product => _product;
  List<int?> _wishIdList = [];
  List<int?> get wishIdList => _wishIdList;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void addToWishList(Product product, BuildContext context) async {
    _wishList!.add(product);
    _wishIdList.add(product.id);
    notifyListeners();
    ApiResponse apiResponse = await wishListRepo!.addWishList([product.id]);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      showCustomSnackBar('item_added_to'.tr, isError: false);
    } else {
      _wishList!.remove(product);
      _wishIdList.remove(product.id);
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void removeFromWishList(Product product, BuildContext context) async {
    _wishList!.remove(product);
    _wishIdList.remove(product.id);
    notifyListeners();
    ApiResponse apiResponse = await wishListRepo!.removeWishList([product.id]);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      showCustomSnackBar('item_removed_from'.tr, isError: false);
    } else {
      _wishList!.add(product);
      _wishIdList.add(product.id);
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> getWishList() async {
    _isLoading = true;
    _wishList = [];
    _wishIdList = [];
    ApiResponse apiResponse = await wishListRepo!.getWishList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _wishList = [];
      _wishList!.addAll(WishListModel.fromJson(apiResponse.response!.data).products!);
      for(int i = 0; i< _wishList!.length; i++){
        _wishIdList.add(_wishList![i].id);
      }


    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }
}
