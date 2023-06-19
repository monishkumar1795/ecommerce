import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';

import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';
import 'package:url_launcher/url_launcher.dart';

class ThirdPartyChatWidget extends StatefulWidget {
  final ConfigModel configModel;
  const ThirdPartyChatWidget({
    Key? key,
    required this.configModel,
  }) : super(key: key);

  @override
  State<ThirdPartyChatWidget> createState() => _ThirdPartyChatWidgetState();
}

class _ThirdPartyChatWidgetState extends State<ThirdPartyChatWidget> {
  List<SpeedDialChild> dialList = [];


  @override
  void initState() {

    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      if((widget.configModel.whatsapp != null
          && widget.configModel.whatsapp!.status!
          && widget.configModel.whatsapp!.number != null)){

        dialList.add(SpeedDialChild(
          backgroundColor: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeExtraSmall,
              horizontal: Dimensions.paddingSizeSmall,
            ),
            height: 35, width: 55,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Theme.of(context).primaryColor),
            child: Image.asset(Images.whatsapp),
          ),
          onPressed: () async {
            final String? whatsapp = widget.configModel.whatsapp!.number;
            final Uri whatsappMobile = Uri.parse("whatsapp://send?phone=$whatsapp");
            if (await canLaunchUrl(whatsappMobile)) {
              await launchUrl(whatsappMobile, mode: LaunchMode.externalApplication);
            } else {
              await launchUrl( Uri.parse("https://web.whatsapp.com/send?phone=$whatsapp"), mode: LaunchMode.externalApplication);
            }
          },
        ));
      }


      if((widget.configModel.telegram != null
          && widget.configModel.telegram!.status!
          && widget.configModel.telegram!.userName != null)){


        dialList.add(SpeedDialChild(backgroundColor: Colors.transparent,child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: Dimensions.paddingSizeExtraSmall,
            horizontal: Dimensions.paddingSizeSmall,
          ),
          height: 35, width: 55,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
          child: Image.asset(Images.telegram),
        ),
          onPressed: () async {
            final String? userName = widget.configModel.telegram!.userName;
            final Uri whatsappMobile = Uri.parse("https://t.me/$userName");
            if (await canLaunchUrl(whatsappMobile)) {
              await launchUrl(whatsappMobile, mode: LaunchMode.externalApplication);
            }
          },)
        );

      }

      if((widget.configModel.messenger != null
          && widget.configModel.messenger!.status!
          && widget.configModel.messenger!.userName != null)){

        dialList.add(SpeedDialChild(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: Dimensions.paddingSizeExtraSmall,
              horizontal: Dimensions.paddingSizeSmall,
            ),
            height: 35, width: 55,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white),
            child: Image.asset(Images.messenger),
          ),
          onPressed: () async {
            final String? userId = widget.configModel.messenger!.userName;
            final Uri messengerUrl = Uri.parse("https://m.me/$userId");
            if (await canLaunchUrl(messengerUrl)) {
              await launchUrl(messengerUrl, mode: LaunchMode.externalApplication);
            }
          },
        ));

      }

    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return dialList.isEmpty ? const SizedBox() : dialList.length > 1 ?  SpeedDial(
      closedForegroundColor: Colors.white,
      openForegroundColor: Colors.white,
      closedBackgroundColor: Theme.of(context).primaryColor,
      openBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
      labelsBackgroundColor: Colors.white,
      speedDialChildren: dialList,
      child: const Icon(Icons.message),
    ) : InkWell(onTap:()=> dialList.first.onPressed(), child: dialList.first.child);

  }
}
