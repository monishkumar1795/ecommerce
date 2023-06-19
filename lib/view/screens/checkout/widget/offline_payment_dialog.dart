import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/body/place_order_body.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/custom_text_field.dart';
import 'package:provider/provider.dart';

class OfflinePaymentDialog extends StatefulWidget {
  final PlaceOrderBody placeOrderBody;
  final Function(PlaceOrderBody)? callBack;
  const OfflinePaymentDialog({Key? key, required this.placeOrderBody, this.callBack}) : super(key: key);

  @override
  State<OfflinePaymentDialog> createState() => _OfflinePaymentDialogState();
}

class _OfflinePaymentDialogState extends State<OfflinePaymentDialog> {
  TextEditingController paymentByController = TextEditingController();
  TextEditingController transactionIdController = TextEditingController();
  TextEditingController paymentNoteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 700,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(getTranslated('offline_payment', context)!, style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeLarge),),

                  InkWell(
                    onTap: ()=> Navigator.of(context).pop(),
                    child: const SizedBox(child: Icon(Icons.clear)),
                  ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge,),

              Text(getTranslated('payment_by', context)!, style: poppinsRegular,),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextField(
                isShowBorder: true,
                hintText: 'jhon doe',
                controller: paymentByController,
                inputAction: TextInputAction.next,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Text(getTranslated('transaction_id', context)!, style: poppinsRegular,),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextField(
                hintText: 'TRX-XXXX',
                isShowBorder: true,
                controller: transactionIdController,
                inputAction: TextInputAction.next,
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),

              Text(getTranslated('payment_note', context)!, style: poppinsRegular,),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              CustomTextField(
                isShowBorder: true,
                controller: paymentNoteController,
                maxLines: 3,
                inputAction: TextInputAction.done,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),

              Row(children: [
                Expanded(child: CustomButton(buttonText: getTranslated('cancel', context),
                    backgroundColor: Theme.of(context).hintColor,
                    onPressed: ()=> Navigator.of(context).pop())),
                const SizedBox(width: Dimensions.paddingSizeDefault),

                Expanded(child: Consumer<OrderProvider>(
                  builder: (context, orderProvider, _) {
                    return orderProvider.isLoading ? Center(child: CustomLoader(color: Theme.of(context).primaryColor)) : CustomButton(
                      buttonText: getTranslated('submit', context),
                      onPressed: (){
                        if(paymentByController.text.isEmpty){
                          showCustomSnackBar(getTranslated('please_insert_user_name', context)!);
                        }else if(transactionIdController.text.isEmpty){
                          showCustomSnackBar(getTranslated('please_input_transaction_id', context)!);
                        }else{
                          widget.callBack!(widget.placeOrderBody.setOfflinePayment(
                            paymentBy: paymentByController.text,
                            transactionReference: transactionIdController.text,
                            paymentNote: paymentNoteController.text,
                          ));
                        }
                      },
                    );
                  }
                )),
              ])

            ]
        ),
      ),
    );
  }
}