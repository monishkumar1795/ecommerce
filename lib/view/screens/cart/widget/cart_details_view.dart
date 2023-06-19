import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_divider.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/screens/cart/widget/delivery_option_button.dart';
import 'package:provider/provider.dart';

class CartDetailsView extends StatelessWidget {
  const CartDetailsView({
    Key? key,
    required TextEditingController couponController,
    required double total,
    required bool isSelfPickupActive,
    required bool kmWiseCharge,
    required bool isFreeDelivery,
    required double itemPrice,
    required double tax,
    required double discount,
    required this.deliveryCharge,
  }) : _couponController = couponController, _total = total, _isSelfPickupActive = isSelfPickupActive, _kmWiseCharge = kmWiseCharge, _isFreeDelivery = isFreeDelivery, _itemPrice = itemPrice, _tax = tax, _discount = discount, super(key: key);

  final TextEditingController _couponController;
  final double _total;
  final bool _isSelfPickupActive;
  final bool _kmWiseCharge;
  final bool _isFreeDelivery;
  final double _itemPrice;
  final double _tax;
  final double _discount;
  final double deliveryCharge;

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    return Column(children: [
      Consumer<CouponProvider>(
        builder: (context, couponProvider, child) {
          return Row(children: [
            Expanded(child: TextField(
              controller: _couponController,
              style: poppinsMedium,
              decoration: InputDecoration(
                hintText: getTranslated('enter_promo_code', context),
                hintStyle: poppinsRegular.copyWith(color: Theme.of(context).hintColor),
                isDense: true,
                filled: true,
                enabled: couponProvider.discount == 0,
                fillColor: Theme.of(context).cardColor,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                  borderSide: BorderSide.none,
                ),
              ),
            )),

            InkWell(
              onTap: () {
                if (_couponController.text.isNotEmpty && !couponProvider.isLoading) {
                  if (couponProvider.discount! < 1) {
                    couponProvider.applyCoupon(_couponController.text, (_total - deliveryCharge) );
                  } else {
                    couponProvider.removeCouponData(true);
                  }
                }else {
                  showCustomSnackBar(getTranslated('invalid_code_or_failed', context)!,isError: true);
                }
              },
              child: Container(
                height: 50,
                width: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(Provider.of<LocalizationProvider>(context, listen: false).isLtr ? 10 : 0),
                    left: Radius.circular(Provider.of<LocalizationProvider>(context, listen: false).isLtr ? 0 : 10),
                  ),
                ),
                child: couponProvider.discount! <= 0
                    ? !couponProvider.isLoading
                    ? Text(
                  getTranslated('apply', context)!,
                  style: poppinsMedium.copyWith(color: Colors.white),
                )
                    : const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : const Icon(Icons.clear, color: Colors.white),
              ),
            ),
          ]);
        },
      ),
      const SizedBox(height: Dimensions.paddingSizeLarge),

      _isSelfPickupActive ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(getTranslated('delivery_option', context)!, style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
        DeliveryOptionButton(value: 'delivery', title: getTranslated('delivery', context), kmWiseFee: _kmWiseCharge, freeDelivery: _isFreeDelivery),

        // DeliveryOptionButton(value: 'self_pickup', title: getTranslated('self_pickup', context), kmWiseFee: _kmWiseCharge),
        const SizedBox(height: Dimensions.paddingSizeLarge),

      ]) : const SizedBox(),

      // Total
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(getTranslated('items_price', context)!, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

        CustomDirectionality(child: Text(
          PriceConverter.convertPrice(context, _itemPrice),
          style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
        )),
      ]),
      const SizedBox(height: 10),


       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [

         CustomDirectionality(child: Text(
           '${getTranslated('tax', context)} ${configModel.isVatTexInclude!
               ? '(${getTranslated('include', context)})' : ''}',
           style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
         )),

        CustomDirectionality(child: Text(
          '${ configModel.isVatTexInclude! ?  '' : '(+)'} ${PriceConverter.convertPrice(context, _tax)}',
          style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
        )),
      ]),
      const SizedBox(height: 10),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(getTranslated('discount', context)!, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

        CustomDirectionality(child: Text(
          '(-) ${PriceConverter.convertPrice(context, _discount)}',
          style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
        )),
      ]),
      const SizedBox(height: 10),

      Consumer<CouponProvider>(builder: (context, couponProvider, _) {
        return couponProvider.couponType != 'free_delivery' && couponProvider.discount! > 0 ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(getTranslated('coupon_discount', context)!, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

          CustomDirectionality(child: Text(
            '(-) ${PriceConverter.convertPrice(context, couponProvider.discount)}',
            style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
          )),
        ],) : const SizedBox();
      }),
      const SizedBox(height: 10),

      if (_kmWiseCharge || _isFreeDelivery) const SizedBox() else Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(
          getTranslated('delivery_fee', context)!,
          style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
        ),

        CustomDirectionality(child: Text(
          '(+) ${PriceConverter.convertPrice(context, deliveryCharge)}',
          style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
        )),

      ]),

      const Padding(
        padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
        child: CustomDivider(),
      ),

      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(getTranslated(_kmWiseCharge ? 'subtotal' : 'total_amount', context)!, style: poppinsMedium.copyWith(
          fontSize: Dimensions.fontSizeExtraLarge,
          color: Theme.of(context).primaryColor,
        )),

        CustomDirectionality(child: Text(
          PriceConverter.convertPrice(context, _total ),
          style: poppinsMedium.copyWith(
            fontSize: Dimensions.fontSizeExtraLarge,
            color: Theme.of(context).primaryColor,
          ),
        )),
      ]),

    ]);
  }
}