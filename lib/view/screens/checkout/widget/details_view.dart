import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_divider.dart';
import 'package:flutter_grocery/view/base/custom_text_field.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/digital_payment_view.dart';
import 'package:provider/provider.dart';

class DetailsView extends StatelessWidget {
  const DetailsView({
    Key? key,
    required List<String> paymentList,
    required double amount,
    required TextEditingController noteController,
    required bool kmWiseCharge,
    required bool selfPickup,
    required double deliveryCharge,
    required bool freeDelivery,
  }) : _amount = amount,  _paymentList = paymentList, _freeDelivery = freeDelivery, _noteController = noteController, _kmWiseCharge = kmWiseCharge, _selfPickup = selfPickup, _deliveryCharge = deliveryCharge, super(key: key);

  final List<String> _paymentList;
  final TextEditingController _noteController;
  final bool _kmWiseCharge;
  final bool _selfPickup;
  final double _deliveryCharge;
  final double _amount;
  final bool _freeDelivery;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        child: Text(getTranslated('payment_method', context)!, style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
      ),
      const SizedBox(height: Dimensions.paddingSizeSmall),

      DigitalPaymentView(paymentList: _paymentList),

      Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: CustomTextField(
          controller: _noteController,
          hintText: getTranslated('additional_note', context),
          maxLines: 5,
          inputType: TextInputType.multiline,
          inputAction: TextInputAction.newline,
          capitalization: TextCapitalization.sentences,
        ),
      ),

      _kmWiseCharge ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        child: Column(children: [
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(getTranslated('subtotal', context)!, style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),

            CustomDirectionality(child: Text(
              PriceConverter.convertPrice(context, _amount),
              style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
            )),
          ]),
          const SizedBox(height: 10),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              getTranslated('delivery_fee', context)!,
              style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
            ),
            Consumer<OrderProvider>(builder: (context, orderProvider, _) {
              return CustomDirectionality(
                child: Text(_freeDelivery ? getTranslated('free', context)! : (_selfPickup ||  orderProvider.distance != -1)
                    ? '(+) ${PriceConverter.convertPrice(context, _selfPickup
                    ? 0 : _deliveryCharge)}'
                    : getTranslated('not_found', context)!,
                  style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
              );
            }),
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
              PriceConverter.convertPrice(context, _amount + (_freeDelivery ? 0:  _deliveryCharge)),
              style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
            )),
          ]),
        ]),
      ) : const SizedBox(),

    ]);
  }
}