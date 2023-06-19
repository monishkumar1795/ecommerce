import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/main_app_bar.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';


class DescriptionScreen extends StatelessWidget {
  final String description;
  const DescriptionScreen({Key? key, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context) ? const MainAppBar() : CustomAppBar(title: getTranslated('description', context), isBackButtonExist: true)) as PreferredSizeWidget?,
     body: Center(
       child: Container(
         width: 1170,
         height: MediaQuery.of(context).size.height,
         padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
         child:SingleChildScrollView(
           child: Center(
             child: SizedBox(width: 1170, child: HtmlWidget(
               description,
               onTapUrl: (String url) {
                return launchUrl(Uri.parse(url));
               },
             ),
             ),
           ),
         ),
       ),
     ),

      //HtmlWidget(description),
     // body: Html(data: description),
    );
  }
}

