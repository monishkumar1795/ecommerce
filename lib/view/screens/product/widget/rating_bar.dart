import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:provider/provider.dart';
class RatingLine extends StatelessWidget {
  const RatingLine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        int fiveStar = 0;
        int fourStar = 0;
        int threeStar = 0;
        int twoStar = 0;
        int oneStar = 0;

        for (var review in productProvider.product!.activeReviews!) {
          if(review.rating! >= 4.5){
            fiveStar++;
          }else if(review.rating! >= 3.5 && review.rating! < 4.5) {
            fourStar++;
          }else if(review.rating! >= 2.5 && review.rating! < 3.5) {
            threeStar++;
          }else if(review.rating! >= 1.5 && review.rating! < 12.5){
            twoStar++;
          }else{
            oneStar++;
          }
        }


        double five = (fiveStar * 100) / 5;
        double four = (fourStar * 100) / 4;
        double three = (threeStar * 100) / 3;
        double two = (twoStar * 100) / 2;
        double one = (oneStar * 100) / 1;

        return Column(children: [
          
          Row(children: [
            Expanded(flex: ResponsiveHelper.isDesktop(context) ? 3 : 4,child: Text(
              'excellent'.tr, style: poppinsRegular.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
            )),

            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.paddingSizeSmall,width: 300,
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.paddingSizeSmall,width: 300 *(five /100),
                  decoration: BoxDecoration(color: Colors.green,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,child: Text(
              'good'.tr, style: poppinsRegular.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
            )),

            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.paddingSizeSmall,width: 300,
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.paddingSizeSmall,width: 300 *(four/100),
                  decoration: BoxDecoration(color: Colors.greenAccent,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,child: Text(
              'average'.tr, style: poppinsRegular.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
            )),
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.paddingSizeSmall,width: 300,
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.paddingSizeSmall,width: 300 *(three /100),
                  decoration: BoxDecoration(color: Colors.orange,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,
                child: Text('below_average'.tr,style: poppinsRegular.copyWith(
              color: Theme.of(context).hintColor,fontSize: Dimensions.fontSizeDefault,
            ))),
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.paddingSizeSmall,width: 300,
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.paddingSizeSmall,width: 300 *(two /100),
                  decoration: BoxDecoration(color: Colors.deepOrange,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 3 : 4,child: Text(
              'poor'.tr,style: poppinsRegular.copyWith(
              color: Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeDefault,
            ),
            )),
            Expanded(flex:ResponsiveHelper.isDesktop(context) ? 8 : 9,child: Stack(
              children: [
                Container(
                  height: Dimensions.paddingSizeSmall,width: 300,
                  decoration: BoxDecoration(color: Theme.of(context).hintColor.withOpacity(0.3),borderRadius: BorderRadius.circular(20)),
                ),
                Container(
                  height: Dimensions.paddingSizeSmall,width: 300 *(one /100),
                  decoration: BoxDecoration(color: Colors.red,borderRadius: BorderRadius.circular(20)),
                ),
              ],
            ),),
          ]),
        ],);
      }
    );
  }
}
