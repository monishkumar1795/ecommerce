import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/html_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/app_bar_base.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatelessWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({Key? key, required this.htmlType}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
    String data = 'no_data_found';
    String appBarText = '';

    switch (htmlType) {
      case HtmlType.termsAndCondition :
        data = configModel!.termsAndConditions ?? '';
        appBarText = 'terms_and_condition';
        break;
      case HtmlType.aboutUs :
        data = configModel!.aboutUs ?? '';
        appBarText = 'about_us';
        break;
      case HtmlType.privacyPolicy :
        data = configModel!.privacyPolicy ?? '';
        appBarText = 'privacy_policy';
        break;
      case HtmlType.faq:
        data = configModel!.faq ?? '';
        appBarText = 'faq';
        break;
      case HtmlType.cancellationPolicy:
        data = configModel!.cancellationPolicy ?? '';
        appBarText = 'cancellation_policy';
        break;
      case HtmlType.refundPolicy:
        data = configModel!.refundPolicy ?? '';
        appBarText = 'refund_policy';
        break;
      case HtmlType.returnPolicy:
        data = configModel!.returnPolicy ?? '';
        appBarText = 'return_policy';
        break;
    }


    if(data.isNotEmpty) {
      data = data.replaceAll('href=', 'target="_blank" href=');
    }

    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar())
          : ResponsiveHelper.isMobilePhone() ? null : AppBarBase(
        title: appBarText.tr,
      )) as PreferredSizeWidget?,
      body: SingleChildScrollView(child: Column(children: [
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context)
              ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height),
          child: Container(
            width: 1170,
            color: Theme.of(context).canvasColor,
            child:  SingleChildScrollView(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              physics: const BouncingScrollPhysics(),
              child: Column(children: [
                ResponsiveHelper.isDesktop(context)
                    ? Text(appBarText.tr, style: poppinsBold.copyWith(fontSize: 28,color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)))
                    : const SizedBox.shrink(),

                Padding(
                  padding: ResponsiveHelper.isDesktop(context)
                      ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeSmall)
                      : const EdgeInsets.all(0.0),
                  child: HtmlWidget(
                    data,
                    key: Key(htmlType.toString()),
                    textStyle: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                    onTapUrl: (String url){
                      return launchUrlString(url);
                    },
                  ),
                ),
              ]),
            ),
          ),
        ),

        ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),

        ]),
      ),
    );
  }
}
