import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';

class TitleWidget extends StatelessWidget {
  final String? title;
  final Function? onTap;
  const TitleWidget({Key? key, required this.title, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ResponsiveHelper.isDesktop(context) ? ColorResources.getAppBarHeaderColor(context) : Theme.of(context).canvasColor,
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 12),
      margin: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: 5) : EdgeInsets.zero,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title!, style: ResponsiveHelper.isDesktop(context) ?  poppinsSemiBold.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)) : poppinsMedium),
        onTap != null ? InkWell(
          onTap: onTap as void Function()?,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 5, 0, 5),
            child: Text(
              'view_all'.tr,
              style: ResponsiveHelper.isDesktop(context) ?  poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor) : poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor.withOpacity(0.8)),
            ),
          ),
        ) : const SizedBox(),
      ]),
    );
  }
}
