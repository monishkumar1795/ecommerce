import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/coupon_model.dart';
import 'package:flutter_grocery/data/repository/coupon_repo.dart';
import 'package:flutter_grocery/helper/api_checker.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';

class CouponProvider extends ChangeNotifier {
  final CouponRepo? couponRepo;

  CouponProvider({required this.couponRepo});

  List<CouponModel>? _couponList;
  CouponModel? _coupon;
  double? _discount = 0.0;
  String? _code = '';
  String? _couponType = '';
  bool _isLoading = false;

  CouponModel? get coupon => _coupon;

  double? get discount => _discount;
  String? get code => _code;
  String? get couponType => _couponType;

  bool get isLoading => _isLoading;

  List<CouponModel>? get couponList => _couponList;

  Future<void> getCouponList(BuildContext context) async {
    ApiResponse apiResponse = await couponRepo!.getCouponList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _couponList = [];
      apiResponse.response!.data.forEach((category) => _couponList!.add(CouponModel.fromJson(category)));
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> applyCoupon(String coupon, double order) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await couponRepo!.applyCoupon(coupon);

    if (apiResponse.response != null && apiResponse.response!.data != null) {
      _coupon = CouponModel.fromJson(apiResponse.response!.data);
      _code = _coupon!.code;
      if (_coupon!.minPurchase != null && _coupon!.minPurchase! <= order) {
        if (_coupon!.discountType == 'percent' && _coupon!.couponType != 'free_delivery') {
          if (_coupon!.maxDiscount != null && _coupon!.maxDiscount != 0) {
            _discount = (_coupon!.discount! * order / 100) < _coupon!.maxDiscount! ? (_coupon!.discount! * order / 100) : _coupon!.maxDiscount;
          } else {
            _discount = _coupon!.discount! * order / 100;
          }
          showCustomSnackBar('${'you_got_discount'.tr} ${'${_coupon!.discount}%'}', isError: false);

        }else if(_coupon!.discountType == 'amount' && order < _coupon!.discount! ) {
          showCustomSnackBar('${'you_need_order_more_than'.tr} '
              '${PriceConverter.convertPrice(Get.context!, _coupon!.discount)}');
        }
        else if(_coupon!.couponType == 'free_delivery'){
          _couponType = _coupon!.couponType;
          showCustomSnackBar('you_got_free_delivery_offer'.tr, isError: false);
        }else {
          _discount = _coupon!.discount;
          showCustomSnackBar('${'you_got_discount'.tr} ${PriceConverter.convertPrice(Get.context!, _coupon!.discount)}', isError: false);
        }
      } else {
        showCustomSnackBar('${'you_need_order_more_than'.tr} '
            '${PriceConverter.convertPrice(Get.context!, _coupon!.discount)}');
        _discount = 0.0;
      }
    } else {
      _discount = 0.0;
      _coupon = null;
      _couponType = '';
      showCustomSnackBar('invalid_code_or_failed'.tr, isError: true);

    }

    _isLoading = false;
    notifyListeners();
  }

  void removeCouponData(bool notify) {
    _coupon = null;
    _isLoading = false;
    _discount = 0.0;
    _code = '';
    if(notify) {
      notifyListeners();
    }
  }
}
