import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';

class CookiesView extends StatelessWidget {
  const CookiesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width  = MediaQuery.of(context).size.width;
    double padding = (width - Dimensions.webScreenWidth) / 2;
    return Consumer<SplashProvider>(
        builder: (context, splashProvide, _) {
          return ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusSizeDefault),
                  topRight: Radius.circular(Dimensions.radiusSizeDefault),
                )),

                padding: EdgeInsets.symmetric(
                  vertical: Dimensions.paddingSizeDefault,
                  horizontal: ResponsiveHelper.isDesktop(context) ? padding : Dimensions.paddingSizeSmall,
                ),

                child: SizedBox(width: Dimensions.webScreenWidth, child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
                      Text(
                        'your_privacy_matters'.tr,
                        style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeDefault,color: Colors.white),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                      Text(splashProvide.configModel!.cookiesManagement!.content ?? "",
                        style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.white70),
                      ),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                    ]),

                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(80,40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: ()=>  splashProvide.cookiesStatusChange(null),
                        child:  Text('no_thanks'.tr, style: poppinsRegular.copyWith(
                            color: Colors.white70, fontSize: Dimensions.fontSizeSmall)),
                      ),
                      SizedBox(width: ResponsiveHelper.isDesktop(context)?Dimensions.paddingSizeExtraLarge:Dimensions.paddingSizeLarge,),


                      TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(80, 40),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: (){
                          splashProvide.cookiesStatusChange(splashProvide.configModel!.cookiesManagement!.content);
                        },
                        child:  Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeDefault,
                              vertical: Dimensions.paddingSizeExtraSmall,
                            ),
                            child: Center(child: Text('yes_accept'.tr, style: poppinsRegular.copyWith(
                              color: Colors.white70,fontSize: Dimensions.fontSizeSmall,
                            )),
                            )),
                      ),

                    ]),


                  ],
                )),
              ),
            ),
          );
        }
    );
  }
}