import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class CurrencyDialog extends StatelessWidget {
  const CurrencyDialog({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    int? index;
      index = Provider.of<LocalizationProvider>(context, listen: false).languageIndex;

    return Dialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 300,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Text( getTranslated('language', context)!, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
          ),

          SizedBox(height: 150, child: Consumer<SplashProvider>(
            builder: (context, splash, child) {
              List<String?> valueList = [];
              for (var language in AppConstants.languages) {
                valueList.add(language.languageName);
              }

              return CupertinoPicker(
                itemExtent: 40,
                useMagnifier: true,
                magnification: 1.2,
                scrollController: FixedExtentScrollController(initialItem: index = 0),
                onSelectedItemChanged: (int i) {
                  index = i;
                },
                children: valueList.map((value) {
                  return Center(child: Text(value!, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)));
                }).toList(),
              );
            },
          )),

          Divider(
            height: Dimensions.paddingSizeExtraSmall,
            color: Theme.of(context).hintColor.withOpacity(0.6),
          ),

          Row(children: [
            Expanded(child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(getTranslated('cancel', context)!, style: poppinsRegular.copyWith(color: Theme.of(context).hintColor)),
            )),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              child: VerticalDivider(width: Dimensions.paddingSizeExtraSmall, color: Theme.of(context).hintColor),
            ),
            Expanded(child: TextButton(
              onPressed: () {
                  Provider.of<LocalizationProvider>(context, listen: false).setLanguage(Locale(
                    AppConstants.languages[index!].languageCode!,
                    AppConstants.languages[index!].countryCode,
                  ));
                Navigator.pop(context);
              },
              child: Text(getTranslated('ok', context)!, style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor)),
            )),
          ]),

        ]),
      ),
    );
  }
}