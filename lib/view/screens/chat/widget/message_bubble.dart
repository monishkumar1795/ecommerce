import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/chat_model.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/screens/chat/widget/image_dialog.dart';
import 'package:provider/provider.dart';

class MessageBubble extends StatelessWidget {
  final Messages? messages;
  final bool? isAdmin;
  const MessageBubble({Key? key, this.messages, this.isAdmin}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    return !isAdmin! ? messages!.deliverymanId != null ?
    Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
      ),

      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(messages!.deliverymanId!.name??'',style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: Container(width: 30, height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(width: .5,color: Theme.of(context).hintColor)
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50.0),
                      child: FadeInImage.assetNetwork(
                        placeholder: Images.profilePlaceholder, fit: BoxFit.cover, width: 40, height: 40,
                        image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls!.deliveryManImageUrl}/${messages!.deliverymanId!.image??''}',
                        imageErrorBuilder: (c, o, s) => Image.asset(Images.profilePlaceholder, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                     if(messages!.message != null) Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(messages!.message != null?Dimensions.paddingSizeDefault:0),
                            child: Text(messages!.message??''),
                          ),
                        ),
                      ),
                     if( messages!.attachment !=null) const SizedBox(height: Dimensions.paddingSizeSmall),
                      messages!.attachment !=null? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1,
                            crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                            crossAxisSpacing: 5
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: messages!.attachment!.length,
                        itemBuilder: (BuildContext context, index){
                          return  messages!.attachment!.isNotEmpty?
                          InkWell(
                            onTap: () => showDialog(context: context, builder: (ctx)  =>  ImageDialog(imageUrl: messages!.attachment![index]), ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child:FadeInImage.assetNetwork(
                                placeholder: Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover,
                                image: messages!.attachment![index],
                                imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                              ),
                            ),
                          ):const SizedBox();

                        },):const SizedBox(),
                    ],
                  ),
                ),

              ],
            ),





            const SizedBox(height: Dimensions.paddingSizeSmall),
            const SizedBox(),
            Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(messages!.createdAt!), context), style: poppinsRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.fontSizeSmall),),
          ],
        ),
      ),
    ):
    Padding(
      padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
          //color: Colors.red
        ),

        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${profileProvider.userInfoModel!.fName} ${profileProvider.userInfoModel!.lName}',style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                       if(messages!.message != null) Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorResources.getChatAdminColor(context),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(messages!.message != null ? Dimensions.paddingSizeDefault:0),
                              child: Text(messages!.message??''),
                            ),
                          ),
                        ),
                        messages!.attachment != null ? const SizedBox(height: Dimensions.paddingSizeSmall) : const SizedBox(),
                        messages!.attachment !=null? Directionality(
                          textDirection: TextDirection.rtl,
                          child: GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 1,
                                crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8: 3,
                                crossAxisSpacing: 5
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: messages!.attachment!.length,
                            itemBuilder: (BuildContext context, index){
                              return  (messages!.attachment!.isNotEmpty) ?
                              InkWell(
                                onTap: () => showDialog(context: context, builder: (ctx)  =>  ImageDialog(imageUrl: messages!.attachment![index]), ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover,
                                    image: messages!.attachment![index],
                                    imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                                  ),
                                ),
                              ):const SizedBox();

                            },),
                        ):const SizedBox(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: Dimensions.paddingSizeDefault,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: FadeInImage.assetNetwork(
                          placeholder: Images.placeholder(context), fit: BoxFit.cover, width: 40, height: 40,
                          image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls!.customerImageUrl}/${profileProvider.userInfoModel!.image}',

                          imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), width: 40, height: 40, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ),
                ],
              ),




              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(messages!.createdAt!), context), style: poppinsRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.fontSizeSmall),),

            ],
          ),
        ),
      ),
    )
    //customer to admin
        :Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
      child: (messages!.isReply != null && messages!.isReply!) ?
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),

        ),

        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${Provider.of<SplashProvider>(context,listen: false).configModel!.ecommerceName}',style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: FadeInImage.assetNetwork(
                      placeholder: Images.appLogo, fit: BoxFit.cover, width: 40, height: 40,
                      image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls!.ecommerceImageUrl}/${Provider.of<SplashProvider>(context,listen: false).configModel!.ecommerceLogo}',
                      imageErrorBuilder: (c, o, s) => Image.asset(Images.appLogo, fit: BoxFit.contain, width: 40, height: 40),
                    ),
                  ),


                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      if(messages!.reply != null && messages!.reply!.isNotEmpty)  Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).secondaryHeaderColor,
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(10),
                                topRight: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(messages!.reply != null?Dimensions.paddingSizeDefault:0),
                              child: Text(messages!.reply??''),
                            ),
                          ),
                        ),
                        if(messages!.reply != null && messages!.reply!.isNotEmpty) const SizedBox(height: 8.0),

                        messages!.image != null ? GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              childAspectRatio: 1,
                              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                              crossAxisSpacing: 5
                          ),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: messages!.image!.length,
                          itemBuilder: (BuildContext context, index){
                            return  messages!.image!.isNotEmpty?
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                hoverColor: Colors.transparent,
                                onTap: () => showDialog(context: context, builder: (ctx)  =>  ImageDialog(imageUrl: '${Provider.of<SplashProvider>(context,listen: false).baseUrls!.chatImageUrl}/${messages!.image![index]}'), ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: FadeInImage.assetNetwork(
                                    placeholder: Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover,
                                    image: '${Provider.of<SplashProvider>(context,listen: false).baseUrls!.chatImageUrl}/${messages!.image![index]}',
                                    imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                                  ),
                                ),
                              ),
                            ):const SizedBox();

                          },):const SizedBox(),


                      ],
                    ),
                  ),

                ],
              ),





              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(messages!.createdAt!), context), style: poppinsRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.fontSizeSmall),),
            ],
          ),
        ),
      ):

      Padding(
        padding: const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),

          ),

          child: Consumer<ProfileProvider>(
              builder: (context, profileController,_) {
                return Column(crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${profileController.userInfoModel != null?profileController.userInfoModel!.fName??'':''} ${profileController.userInfoModel != null?profileController.userInfoModel!.lName??'':''}', style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [

                        Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              (messages!.message != null && messages!.message!.isNotEmpty) ? Flexible(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorResources.getChatAdminColor(context),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10),
                                      bottomLeft: Radius.circular(10),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(messages!.message != null?Dimensions.paddingSizeDefault:0),
                                    child: Text(messages!.message??''),
                                  ),
                                ),
                              ) : const SizedBox(),
                              messages!.image != null ? Directionality(
                                textDirection: TextDirection.rtl,
                                child: GridView.builder(
                                  reverse: true,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      childAspectRatio: 1,
                                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 8 : 3,
                                      crossAxisSpacing: 5
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: messages!.image!.length,
                                  itemBuilder: (BuildContext context, index){
                                    return  messages!.image!.isNotEmpty?
                                    InkWell(
                                      onTap: () => showDialog(context: context, builder: (ctx)  =>  ImageDialog(imageUrl: messages!.image![index])),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: Dimensions.paddingSizeSmall ,
                                          right:  0,
                                          top: (messages!.message != null && messages!.message!.isNotEmpty) ? Dimensions.paddingSizeSmall : 0,                                       ),
                                        child:ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: FadeInImage.assetNetwork(
                                            placeholder: Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover,
                                            image: messages!.image![index] ,
                                            imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
                                          ),
                                        ),
                                      ),
                                    ):const SizedBox();

                                  },),
                              ):const SizedBox(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
                          child: Container(width: 40, height: 40,
                            decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(Dimensions.paddingSizeDefault))
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: FadeInImage.assetNetwork(
                                placeholder: Images.placeholder(context), fit: BoxFit.cover, width: 40, height: 40,
                                image: profileController.userInfoModel != null? '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/${profileController.userInfoModel!.image}':'',
                                imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), fit: BoxFit.cover),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),


                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text(DateConverter.localDateToIsoStringAMPM(DateTime.parse(messages!.createdAt!), context), style: poppinsRegular.copyWith(color: Theme.of(context).hintColor,fontSize: Dimensions.fontSizeSmall),),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                  ],
                );
              }
          ),
        ),
      ),
    );
  }
}
