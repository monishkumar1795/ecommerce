import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/dimensions.dart';

void showCustomSnackBar(String message, {bool isError = true}) {
  ScaffoldMessenger.of(Get.context!).clearSnackBars();
  final width = MediaQuery.of(Get.context!).size.width;
  ScaffoldMessenger.of(Get.context!)..hideCurrentSnackBar()..showSnackBar(SnackBar(key: UniqueKey(), content: Text(message),
      margin: ResponsiveHelper.isDesktop(Get.context!) ?  EdgeInsets.only(
        right: width * 0.75, bottom: Dimensions.paddingSizeLarge, left: Dimensions.paddingSizeExtraSmall,
      ) : null,
      behavior: ResponsiveHelper.isDesktop(Get.context!) ? SnackBarBehavior.floating : SnackBarBehavior.fixed ,
      dismissDirection: DismissDirection.down,
      backgroundColor: isError ? Colors.red : Colors.green,
      )
  );
}
