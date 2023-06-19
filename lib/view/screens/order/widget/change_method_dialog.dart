import 'package:flutter/material.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:provider/provider.dart';

class ChangeMethodDialog extends StatelessWidget {
  final String orderID;
  final Function callback;
  final bool fromOrder;
  const ChangeMethodDialog({Key? key, required this.orderID, required this.callback, required this.fromOrder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, order, child) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: SizedBox(
              width: 300,
              child: Column(mainAxisSize: MainAxisSize.min, children: [

                Image.asset(Images.wallet, color: Theme.of(context).primaryColor, width: 100, height: 100),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                Text(
                  getTranslated('do_you_want_to_switch', context)!, textAlign: TextAlign.justify,
                  style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),

                !order.isLoading ?  Row(children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(width: 2, color: Theme.of(context).primaryColor)),
                        minimumSize: const Size(1, 50),
                      ),
                      child: Text(getTranslated('no', context)!),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Expanded(child: CustomButton(buttonText: getTranslated('yes', context), onPressed: () async {
                    await order.updatePaymentMethod(orderID, fromOrder, callback);
                    Navigator.pop(Get.context!);
                  })),
                ]) : Center(child: CustomLoader(color: Theme.of(context).primaryColor)),
              ]),
            ),
          ),
        );
      },
    );
  }
}
