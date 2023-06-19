import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/base/error_response.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/view/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

class ApiChecker {
  static void checkApi(ApiResponse apiResponse) {
    ErrorResponse error = getError(apiResponse);

    if((error.errors![0].code == '401' || error.errors![0].code == 'auth-001' ||  ModalRoute.of(Get.context!)!.settings.name != RouteHelper.getLoginRoute())) {
      Provider.of<SplashProvider>(Get.context!, listen: false).removeSharedData();
      Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        content: Text(error.errors![0].message ?? getTranslated('not_found', Get.context!)!
            , style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ));
    }
  }

  static ErrorResponse getError(ApiResponse apiResponse){
    ErrorResponse error;

    try{
      error = ErrorResponse.fromJson(apiResponse);
    }catch(e){
      if(apiResponse.error != null){
        error = ErrorResponse.fromJson(apiResponse.error);
      }else{
        error = ErrorResponse(errors: [Errors(code: '', message: apiResponse.error.toString())]);
      }
    }
    return error;
  }
}