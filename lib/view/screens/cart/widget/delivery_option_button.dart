import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:provider/provider.dart';

class DeliveryOptionButton extends StatelessWidget {
  final String value;
  final String? title;
  final bool kmWiseFee;
  final bool freeDelivery;
  const DeliveryOptionButton({Key? key, required this.value, required this.title, required this.kmWiseFee, this.freeDelivery = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, order, child) {
        return InkWell(
          onTap: () => order.setOrderType(value),
          child: Row(
            children: [
              Radio(
                value: value,
                groupValue: order.orderType,
                activeColor: Theme.of(context).primaryColor,
                onChanged: (String? value) => order.setOrderType(value),
              ),
              const SizedBox(width: Dimensions.paddingSizeSmall),

              Text(title!, style: poppinsRegular),
              const SizedBox(width: 5),

              freeDelivery ? CustomDirectionality(child: Text('(${getTranslated('free', context)})', style: poppinsMedium))
                  :  kmWiseFee  ? const SizedBox() : Text('(${value == 'delivery' && !freeDelivery
                  ? PriceConverter.convertPrice(context, Provider.of<SplashProvider>(context, listen: false).configModel!.deliveryCharge)
                  : getTranslated('free', context)})', style: poppinsMedium,
              ),

            ],
          ),
        );
      },
    );
  }
}
