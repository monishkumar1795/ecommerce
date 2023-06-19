import 'package:flutter/material.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:provider/provider.dart';

class OrderCancelDialog extends StatelessWidget {
  final String orderID;
  final Function callback;
  final bool fromOrder;
  const OrderCancelDialog({Key? key, required this.orderID, required this.callback, required this.fromOrder}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, order, child) =>  Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child:  SizedBox(
          width: 300,
          child: Column(mainAxisSize: MainAxisSize.min, children: [

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: 50),
              child: Text(getTranslated('are_you_sure_to_cancel', context)!, style: poppinsRegular, textAlign: TextAlign.center),
            ),

            Divider(height: 0, color: Theme.of(context).hintColor.withOpacity(0.6)),
            !order.isLoading ? Row(children: [
              Expanded(child: InkWell(
                onTap: () {
                  Provider.of<OrderProvider>(context, listen: false).cancelOrder(orderID, fromOrder, (String message, bool isSuccess, String orderID) {
                    Navigator.pop(context);
                    callback(message, isSuccess, orderID);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10))),
                  child: Text(getTranslated('yes', context)!, style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor)),
                ),
              )),

              Expanded(child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: const BorderRadius.only(bottomRight: Radius.circular(10))),
                  child: Text(getTranslated('no', context)!, style: poppinsRegular.copyWith(color: Colors.white)),
                ),
              )),

            ]) : SizedBox( height: 50,child: Center(child: CustomLoader(color: Theme.of(context).primaryColor))),

          ]),
        )   )
    );
  }
}
