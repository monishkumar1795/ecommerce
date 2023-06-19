import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/on_hover.dart';
import 'package:flutter_grocery/view/screens/product/product_details_screen.dart';
import 'package:provider/provider.dart';
class WebDailyItemView extends StatelessWidget {
  final ProductProvider productProvider;
  final int index;
   WebDailyItemView({Key? key,required this.productProvider,required this.index}) : super(key: key);

  final oneSideShadow = Padding(
    padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
    child: Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return OnHover(
      isItem: true,
      child: InkWell(
        onTap: (){
          Navigator.of(context).pushNamed(RouteHelper.getProductDetailsRoute(product: productProvider.dailyItemList![index]),
              arguments: ProductDetailsScreen(product: productProvider.dailyItemList![index]));
        },
        borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
        child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, 4),
                    blurRadius: 7,
                    spreadRadius: 0.1
                )
              ]
          ),
          child: Column(
            children: [
              Expanded(
                  flex: 6,
                  child: Stack(
                    children: [
                      oneSideShadow,
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(top: 5,left: 5,right: 5),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusSizeTen),topRight: Radius.circular(Dimensions.radiusSizeTen)),
                            // boxShadow: [
                            //   BoxShadow(
                            //       color: Colors.black.withOpacity(0.1),
                            //       offset: const Offset(0, 0),
                            //       blurRadius: 10,
                            //       spreadRadius: 0,
                            //       blurStyle: BlurStyle.outer
                            //   ),
                            // ]
                        ),
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(Dimensions.radiusSizeTen),topRight: Radius.circular(Dimensions.radiusSizeTen)),
                          child: FadeInImage.assetNetwork(
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                            placeholder: Images.placeholder(context),
                            image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}'
                                '/${productProvider.dailyItemList![index].image![0]}',
                            imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), width: 100, height: 150, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ],
                  )
              ),
              Expanded(flex: 4,child: Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    Text(
                      productProvider.dailyItemList![index].name!,
                      style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                      maxLines: 1, overflow: TextOverflow.ellipsis,textAlign: TextAlign.center,
                    ),
                    Text(
                      '${productProvider.dailyItemList![index].capacity} ${productProvider.dailyItemList![index].unit}',
                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),



                    CustomDirectionality(child: Text(
                      PriceConverter.convertPrice(
                        context, productProvider.dailyItemList![index].price,
                        discount: productProvider.dailyItemList![index].discount,
                        discountType: productProvider.dailyItemList![index].discountType,
                      ),
                      style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                    )),

                    productProvider.dailyItemList![index].discount! > 0
                        ? CustomDirectionality(child: Text(
                        PriceConverter.convertPrice(
                          context, productProvider.dailyItemList![index].price,
                        ),
                        style: poppinsRegular.copyWith(
                          fontSize: Dimensions.fontSizeExtraSmall,
                          color: Theme.of(context).colorScheme.error,
                          decoration: TextDecoration.lineThrough,
                        ))) : const SizedBox(),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );

  }
}
