

import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/email_checker.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/news_letter_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/text_hover.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'custom_snackbar.dart';
class FooterView extends StatelessWidget {
  const FooterView({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    TextEditingController newsLetterController = TextEditingController();
    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    return Container(
      color: ColorResources.getAppBarHeaderColor(context),
      width: double.maxFinite,
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: Dimensions.webScreenWidth,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: Dimensions.paddingSizeLarge ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(Provider.of<SplashProvider>(context).configModel!.ecommerceName ?? AppConstants.appName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontWeight: FontWeight.w800,fontSize: 44,color: Theme.of(context).primaryColor),),
                              ),
                            ],
                          ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Text('news_letter'.tr, style: poppinsBold.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeExtraLarge)),

                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text('subscribe_to_out_new_channel_to_get_latest_updates'.tr, style: poppinsRegular.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeDefault)),

                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          Container(
                            width: 400,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 2,
                                  )
                                ]
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 20),
                                Expanded(child: TextField(
                                  controller: newsLetterController,
                                  style: poppinsRegular.copyWith(color: Colors.black),
                                  decoration: InputDecoration(
                                    hintText: 'your_email_address'.tr,
                                    hintStyle: poppinsRegular.copyWith(color: ColorResources.getGreyColor(context),fontSize: Dimensions.fontSizeLarge),
                                    border: InputBorder.none,
                                  ),
                                  maxLines: 1,

                                )),
                                InkWell(
                                  onTap: (){
                                    String email = newsLetterController.text.trim().toString();
                                    if (email.isEmpty) {
                                      showCustomSnackBar('enter_email_address'.tr);
                                    }else if (EmailChecker.isNotValid(email)) {
                                      showCustomSnackBar('enter_valid_email'.tr);
                                    }else{
                                      Provider.of<NewsLetterProvider>(context, listen: false).addToNewsLetter(email).then((value) {
                                        newsLetterController.clear();
                                      });
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 2,vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 10),
                                    child: Text('subscribe'.tr, style: poppinsRegular.copyWith(color: Colors.white,fontSize: Dimensions.fontSizeDefault)),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeDefault),

                          // const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                          Consumer<SplashProvider>(
                              builder: (context, splashProvider, child) {
                                final isLtr = Provider.of<LocalizationProvider>(context, listen: false).isLtr;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if(splashProvider.configModel!.socialMediaLink!.isNotEmpty)
                                      Text(
                                        'follow_us_on'.tr,
                                        style: poppinsRegular.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeDefault),
                                      ),
                                    SizedBox(
                                      height: 50,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        shrinkWrap: true,
                                        itemCount: splashProvider.configModel!.socialMediaLink!.length,
                                        itemBuilder: (BuildContext context, index){
                                          String? name = splashProvider.configModel!.socialMediaLink![index].name;
                                          late String icon;
                                          if(name == 'facebook'){
                                            icon = Images.facebook;
                                          }else if(name == 'linkedin'){
                                            icon = Images.linkedInIcon;
                                          } else if(name == 'youtube'){
                                            icon = Images.youtube;
                                          }else if(name == 'twitter'){
                                            icon = Images.twitter;
                                          }else if(name == 'instagram'){
                                            icon = Images.inStaGramIcon;
                                          }else if(name == 'pinterest'){
                                            icon = Images.pinterest;
                                          }
                                          return  splashProvider.configModel!.socialMediaLink!.isNotEmpty ?
                                          InkWell(
                                            onTap: (){
                                              _launchURL(splashProvider.configModel!.socialMediaLink![index].link!);
                                            },
                                            child: Padding(
                                              padding: EdgeInsets.only( left: isLtr && index  == 0 ? 0 : 4, right: !isLtr && index == 0 ? 0 : 4),
                                              child: Image.asset(icon,height: Dimensions.paddingSizeExtraLarge,width: Dimensions.paddingSizeExtraLarge,fit: BoxFit.contain),
                                            ),
                                          ):const SizedBox();

                                        },),
                                    ),
                                  ],
                                );
                              }
                          ),

                        ],
                      )),
                  Provider.of<SplashProvider>(context, listen: false).configModel!.playStoreConfig!.status! || Provider.of<SplashProvider>(context, listen: false).configModel!.appStoreConfig!.status!?
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        const SizedBox(height: Dimensions.paddingSizeLarge * 2),
                        Text( Provider.of<SplashProvider>(context, listen: false).configModel!.playStoreConfig!.status! && Provider.of<SplashProvider>(context, listen: false).configModel!.appStoreConfig!.status!
                            ? 'download_our_apps'.tr : 'download_our_app'.tr, style: poppinsBold.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeLarge)),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Provider.of<SplashProvider>(context, listen: false).configModel!.playStoreConfig!.status!?
                            InkWell(onTap:(){
                              _launchURL(Provider.of<SplashProvider>(context, listen: false).configModel!.playStoreConfig!.link!);
                            },child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Image.asset(Images.playStore,height: 50,fit: BoxFit.contain),
                            )):const SizedBox(),
                            Provider.of<SplashProvider>(context, listen: false).configModel!.appStoreConfig!.status!?
                            InkWell(onTap:(){
                              _launchURL(Provider.of<SplashProvider>(context, listen: false).configModel!.appStoreConfig!.link!);
                            },child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Image.asset(Images.appStore,height: 50,fit: BoxFit.contain),
                            )):const SizedBox(),
                          ],)
                      ],
                    ),
                  ) : const SizedBox(),
                  Expanded(flex: 2,child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeLarge * 2),
                      Text('my_account'.tr, style: poppinsBold.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeExtraLarge)),
                      const SizedBox(height: Dimensions.paddingSizeLarge),


                      Consumer<ProfileProvider>(
                        builder: (context, profileProvider, child) {
                          return TextHover(
                              builder: (hovered) {
                                return InkWell(
                                    onTap: (){
                                      isLoggedIn? Navigator.pushNamed(context,
                                        RouteHelper.getProfileEditRoute(profileProvider.userInfoModel),
                                      ) : Navigator.pushNamed(context, RouteHelper.getLoginRoute());
                                      },
                                    child: Text('profile'.tr, style: hovered? poppinsMedium.copyWith(color: Theme.of(context).primaryColor) : poppinsRegular.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeDefault)));
                              }
                          );
                        }
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      TextHover(
                          builder: (hovered) {
                            return InkWell(
                                onTap: (){
                                  Navigator.pushNamed(context, RouteHelper.address);
                                },
                                child: Text('address'.tr, style: hovered? poppinsMedium.copyWith(color: Theme.of(context).primaryColor) : poppinsRegular.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeDefault)));
                          }
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      TextHover(
                          builder: (hovered) {
                            return InkWell(
                                onTap: (){
                                  Navigator.pushNamed(context, RouteHelper.getChatRoute(orderModel: null));
                                },
                                child: Text('live_chat'.tr, style: hovered? poppinsMedium.copyWith(color: Theme.of(context).primaryColor) : poppinsRegular.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeDefault)));
                          }
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      TextHover(
                          builder: (hovered) {
                            return InkWell(
                                onTap: (){
                                  Navigator.pushNamed(context, RouteHelper.myOrder);
                                },
                                child: Text('my_order'.tr, style: hovered? poppinsMedium.copyWith(color: Theme.of(context).primaryColor) : poppinsRegular.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeDefault)));
                          }
                      ),

                    ],)),
                  Expanded(flex: 2,child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeLarge * 2),
                      Text('quick_links'.tr, style: poppinsBold.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeExtraLarge)),
                      const SizedBox(height: Dimensions.paddingSizeLarge),
                      TextHover(
                          builder: (hovered) {
                            return InkWell(
                                onTap: () =>  Navigator.pushNamed(context, RouteHelper.getContactRoute()),
                                child: Text('contact_us'.tr, style: hovered? poppinsMedium.copyWith(color: Theme.of(context).primaryColor) : poppinsRegular.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeDefault)));
                          }
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      TextHover(
                          builder: (hovered) {
                            return InkWell(
                                onTap: () => Navigator.pushNamed(context, RouteHelper.getPolicyRoute()),
                                child: Text('privacy_policy'.tr, style: hovered? poppinsMedium.copyWith(color: Theme.of(context).primaryColor) : poppinsRegular.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeDefault)));
                          }
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      TextHover(
                          builder: (hovered) {
                            return InkWell(
                                onTap: () => Navigator.pushNamed(context, RouteHelper.getTermsRoute()),
                                child: Text('terms_and_condition'.tr, style: hovered? poppinsMedium.copyWith(color: Theme.of(context).primaryColor) : poppinsRegular.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeDefault)));
                          }
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),
                      TextHover(
                          builder: (hovered) {
                            return InkWell(
                                onTap: () => Navigator.pushNamed(context, RouteHelper.getAboutUsRoute()),
                                child: Text('about_us'.tr, style: hovered? poppinsMedium.copyWith(color: Theme.of(context).primaryColor) : poppinsRegular.copyWith(color: ColorResources.getFooterTextColor(context),fontSize: Dimensions.fontSizeDefault)));
                          }
                      ),
                      const SizedBox(height: Dimensions.paddingSizeSmall),

                      TextHover(
                          builder: (hovered) {
                            return InkWell(
                                onTap: () => Navigator.pushNamed(context, RouteHelper.getfaqRoute()),
                                child: Text('faq'.tr, style: hovered? poppinsMedium.copyWith(
                                    color: Theme.of(context).primaryColor) : poppinsRegular.copyWith(
                                  color: ColorResources.getFooterTextColor(context),
                                  fontSize: Dimensions.fontSizeDefault,
                                ),
                                ));
                          }
                      ),

                    ],)),
                ],
              ),
            ),
            const Divider(thickness: .5),
            SizedBox(
              width: 500.0,
              child: Text(Provider.of<SplashProvider>(context,listen: false).configModel!.footerCopyright ??
                  '${'copyright'.tr} ${Provider.of<SplashProvider>(context,listen: false).configModel!.ecommerceName}',
                  overflow: TextOverflow.ellipsis,maxLines: 1,textAlign: TextAlign.center),
            ),

            const SizedBox(height: Dimensions.paddingSizeDefault)
          ],
        ),
      ),
    );
  }
}
_launchURL(String url) async {
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  } else {
    throw 'Could not launch $url';
  }
}