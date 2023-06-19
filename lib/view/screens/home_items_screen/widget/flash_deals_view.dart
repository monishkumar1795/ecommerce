import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/provider/flash_deal_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/product_widget.dart';
import 'package:flutter_grocery/view/base/rating_bar.dart';
import 'package:flutter_grocery/view/base/web_product_shimmer.dart';
import 'package:flutter_grocery/view/screens/home_items_screen/widget/flash_deal_shimmer.dart';
import 'package:flutter_grocery/view/screens/product/category_product_screen_new.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class FlashDealsView extends StatelessWidget {
  final bool isHomeScreen;
  const FlashDealsView({Key? key, this.isHomeScreen = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return isHomeScreen ?
    Consumer<FlashDealProvider>(
      builder: (context, flashDealProvider, child) {
        double width = MediaQuery.of(context).size.width;
        return flashDealProvider.flashDealList != null && flashDealProvider.flashDealList!.isNotEmpty ?
        ListView.builder(
          padding: const EdgeInsets.all(0),
          scrollDirection: isHomeScreen ? Axis.horizontal : Axis.vertical,
          itemCount: flashDealProvider.flashDealList!.isEmpty ? 2 : flashDealProvider.flashDealList!.length,
          itemBuilder: (context, index) {

            return SizedBox(
              width: width,
              child: flashDealProvider.flashDealList != null ? flashDealProvider.flashDealList!.isNotEmpty ?
              Stack(
                fit: StackFit.expand,
                children: [
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      viewportFraction: .55,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      disableCenter: true,
                      onPageChanged: (index, reason) {
                        Provider.of<FlashDealProvider>(context, listen: false).setCurrentIndex(index);
                      },
                    ),
                    itemCount: flashDealProvider.flashDealList!.isEmpty ?
                    1 : flashDealProvider.flashDealList!.length,
                    itemBuilder: (context, index, _) {

                      return InkWell(
                        onTap: () => Navigator.of(context).pushNamed(RouteHelper.getProductDetailsRoute(product: flashDealProvider.flashDealList![index])),
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Theme.of(context).cardColor,
                              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5)]),
                          child: Stack(children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: MediaQuery.of(context).size.width/2.2,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).primaryColor.withOpacity(.2),width: .1),
                                    borderRadius: const BorderRadius.all( Radius.circular(10)),
                                  ),

                                  // product.image!.isNotEmpty ? product.image![0] : ''}',
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all( Radius.circular(10)),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: Images.placeholderLight, fit: BoxFit.cover,
                                      image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}'
                                          '/${ flashDealProvider.flashDealList![index].image!.isNotEmpty ? flashDealProvider.flashDealList![index].image?.first : ''}',
                                      imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholderLight,
                                        fit: BoxFit.cover,height: width*.50,),
                                    ),
                                  ),
                                ),
                              ),


                              Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                child: Column(mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(flashDealProvider.flashDealList![index].name!,
                                      style: poppinsRegular, maxLines: 2,
                                      overflow: TextOverflow.ellipsis, textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                                    Row(children: [
                                      flashDealProvider.flashDealList![index].rating != null ? Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: RatingBar(
                                          rating: flashDealProvider.flashDealList![index].rating!.isNotEmpty
                                              ? double.parse(flashDealProvider.flashDealList![index].rating![0].average!)
                                              : 0.0, size: 10,
                                        ),
                                      ) : const SizedBox(),

                                      const Spacer(),


                                      CustomDirectionality(
                                        child: Text(flashDealProvider.flashDealList![index].discount! > 0 ?
                                        PriceConverter.convertPrice(context, flashDealProvider.flashDealList![index].price) : '',
                                          style: poppinsBold.copyWith(
                                            color: Theme.of(context).hintColor,
                                            decoration: TextDecoration.lineThrough,
                                            fontSize: Dimensions.fontSizeExtraSmall,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),

                                      CustomDirectionality(
                                        child: Text(PriceConverter.convertPrice(context, flashDealProvider.flashDealList![index].price,
                                            discountType: flashDealProvider.flashDealList![index].discountType,
                                            discount: flashDealProvider.flashDealList![index].discount),
                                          style: poppinsBold.copyWith(color: Theme.of(context).primaryColor),
                                        ),
                                      ),
                                    ]),


                                  ],
                                ),
                              ),
                            ]),


                            flashDealProvider.flashDealList![index].discount! >= 1 ?
                            Positioned(top: 0, left: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                height: 25,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(10),
                                      bottomRight: Radius.circular(10)),
                                ),
                                child: Text(PriceConverter.percentageCalculation(
                                  context,
                                  '${flashDealProvider.flashDealList![index].price}',
                                  flashDealProvider.flashDealList![index].discount,
                                  flashDealProvider.flashDealList![index].discountType,),
                                  style: poppinsRegular.copyWith(
                                    color: Colors.white,
                                    fontSize: Dimensions.fontSizeSmall,
                                  ),
                                ),
                              ),
                            ) : const SizedBox.shrink(),


                          ]),
                        ),
                      );
                    },
                  ),

                ],
              ) : const SizedBox() : Shimmer(
                color: Colors.grey[300]!,
                // highlightColor: Colors.grey[100],
                enabled: flashDealProvider.flashDealList == null,
                child: Container(margin: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                )),
              ),
            );

          },
        ) : MegaDealShimmer(isHomeScreen: isHomeScreen);
      },
    ):
    Consumer<FlashDealProvider>(
      builder: (context, flashDealProvider, child) {
        return flashDealProvider.flashDealList!.isNotEmpty ?
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
              mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
              childAspectRatio:ResponsiveHelper.isDesktop(context) ? (1 / 1.1) : 3.0,
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 1),
          itemCount: flashDealProvider.flashDealList!.length,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: Dimensions.paddingSizeLarge),
          // padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return ProductWidget(product: flashDealProvider.flashDealList![index],);
          },
        ) : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
              mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
              childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1 / 1.1) : 4,
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 1),
          itemCount: 10,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return ResponsiveHelper.isDesktop(context)
                ?  WebProductShimmer(isEnabled: flashDealProvider.flashDealList == null)
                : ProductShimmer(isEnabled: flashDealProvider.flashDealList == null);
          },
        );
      },
    );
  }
}



