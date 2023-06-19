import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_divider.dart';
import 'package:provider/provider.dart';

class DeliveryFeeDialog extends StatelessWidget {
  final double amount;
  final double distance;
  final bool freeDelivery;
  final Function(double amount)? callBack;
  const DeliveryFeeDialog({Key? key, required this.amount, required this.distance, required this.freeDelivery, this.callBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double deliveryCharge = distance
        * Provider.of<SplashProvider>(context, listen: false).configModel!.deliveryManagement!.shippingPerKm!;
    if(deliveryCharge < Provider.of<SplashProvider>(context, listen: false).configModel!.deliveryManagement!.minShippingCharge!) {
      deliveryCharge = Provider.of<SplashProvider>(context, listen: false).configModel!.deliveryManagement!.minShippingCharge!;
    }
    if(freeDelivery) {
      deliveryCharge = 0;
    }

    callBack!(deliveryCharge);

    return Consumer<OrderProvider>(builder: (context, order, child) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.width*0.4 : MediaQuery.of(context).size.width ,
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Container(
              height: 70, width: 70,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delivery_dining,
                color: Theme.of(context).primaryColor, size: 50,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),

            Column(children: [
              Text(
                '${getTranslated('delivery_fee_from_your_selected_address_to_branch', context)!}:',
                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge), textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              CustomDirectionality(child: Text(
                PriceConverter.convertPrice(context, deliveryCharge),
                style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
              )),

              const SizedBox(height: 20),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(getTranslated('subtotal', context)!, style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                
                CustomDirectionality(child: Text(
                  PriceConverter.convertPrice(context, amount),
                  style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                )),
              ]),
              const SizedBox(height: 10),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  getTranslated('delivery_fee', context)!,
                  style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),

                CustomDirectionality(child: Text(
                  freeDelivery ? getTranslated('free', context)! :
                  '(+) ${PriceConverter.convertPrice(context, deliveryCharge)}',
                  style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                )),
              ]),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                child: CustomDivider(),
              ),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(getTranslated('total_amount', context)!, style: poppinsMedium.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor,
                )),

                CustomDirectionality(child: Text(
                  PriceConverter.convertPrice(context, amount + deliveryCharge),
                  style: poppinsMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: Theme.of(context).primaryColor,
                  ),
                )),
              ]),
            ]),
            const SizedBox(height: 30),

            CustomButton(buttonText: getTranslated('ok', context), onPressed: () {
              Navigator.pop(context);
            }),

          ]),
        ),
      );
    });
  }
}
