import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/body/place_order_body.dart';
import 'package:flutter_grocery/data/model/response/cart_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_dialog.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/screens/checkout/order_successful_screen.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/offline_payment_dialog.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:convert'as convert;



class PlaceOrderButtonView extends StatefulWidget {
  final double? amount;
  final TextEditingController? noteController;
  final bool? kmWiseCharge;
  final String? orderType;
  final double? deliveryCharge;
  final bool? selfPickUp;
  final String? couponCode;

  const PlaceOrderButtonView({Key? key, 
    this.amount,
    this.noteController,
    this.kmWiseCharge,
    this.orderType,
    this.deliveryCharge,
    this.selfPickUp,
    this.couponCode,
}) : super(key: key);

  @override
  State<PlaceOrderButtonView> createState() => _PlaceOrderButtonViewState();
}

class _PlaceOrderButtonViewState extends State<PlaceOrderButtonView> {

  TextEditingController paymentByController = TextEditingController();
  TextEditingController transactionIdController = TextEditingController();
  TextEditingController paymentNoteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final configModel = Provider.of<SplashProvider>(context, listen: false).configModel;
    final directPaymentList = [
      'cash_on_delivery',
      'offline_payment',
      'wallet_payment',
    ];

    return SizedBox(
      width: 1170,
      child: Consumer<OrderProvider>(
          builder: (context, orderProvider, _) {
            if(orderProvider.isLoading) {
              return Center(child: CustomLoader(color: Theme.of(context).primaryColor));
            }
            return CustomButton(
              margin: Dimensions.paddingSizeSmall,
              buttonText: getTranslated('place_order', context),
              onPressed: () {
                if (!widget.selfPickUp! && orderProvider.addressIndex == -1) {
                  showCustomSnackBar(getTranslated('select_delivery_address', context)!,isError: true);
                }else if (orderProvider.timeSlots == null || orderProvider.timeSlots!.isEmpty) {
                  showCustomSnackBar(getTranslated('select_a_time', context)!,isError: true);
                }else if (orderProvider.paymentMethod == '') {
                  showCustomSnackBar(getTranslated('select_payment_method', context)!,isError: true);
                } else if (!widget.selfPickUp! && widget.kmWiseCharge! && orderProvider.distance == -1) {
                  showCustomSnackBar(getTranslated('delivery_fee_not_set_yet', context)!,isError: true);
                }
                else {
                  List<CartModel> cartList = Provider.of<CartProvider>(context, listen: false).cartList;
                  List<Cart> carts = [];
                  for (int index = 0; index < cartList.length; index++) {
                    Cart cart = Cart(
                      productId: cartList[index].id, price: cartList[index].price,
                      discountAmount: cartList[index].discountedPrice,
                      quantity: cartList[index].quantity, taxAmount: cartList[index].tax,
                      variant: '', variation: [Variation(type: cartList[index].variation != null ? cartList[index].variation!.type : null)],
                    );
                    carts.add(cart);
                  }

                  PlaceOrderBody placeOrderBody = PlaceOrderBody(
                    cart: carts, orderType: widget.orderType,
                    couponCode: widget.couponCode, orderNote: widget.noteController!.text,
                    branchId: configModel!.branches![orderProvider.branchIndex].id,
                    deliveryAddressId: !widget.selfPickUp!
                        ? Provider.of<LocationProvider>(context, listen: false).addressList![orderProvider.addressIndex].id
                        : 0, distance: widget.selfPickUp! ? 0 : orderProvider.distance,
                    couponDiscountAmount: Provider.of<CouponProvider>(context, listen: false).discount,
                    timeSlotId: orderProvider.timeSlots![orderProvider.selectTimeSlot].id,
                    paymentMethod: orderProvider.paymentMethod,
                    deliveryDate: orderProvider.getDates(context)[orderProvider.selectDateSlot],
                    couponDiscountTitle: '',
                    orderAmount: widget.amount! + widget.deliveryCharge!,
                  );


                  if(directPaymentList.contains(orderProvider.paymentMethod)) {

                    if(orderProvider.paymentMethod != 'offline_payment') {
                      if(placeOrderBody.paymentMethod == 'cash_on_delivery'
                          && configModel.maxAmountCodStatus! &&
                          placeOrderBody.orderAmount! >
                              configModel.maxOrderForCODAmount!) {
                        showCustomSnackBar('${getTranslated('for_cod_order_must_be', context)} ${configModel.maxOrderForCODAmount}');
                      }else if(orderProvider.paymentMethod == 'wallet_payment' &&
                          Provider.of<ProfileProvider>(context, listen: false).userInfoModel!.walletBalance!
                              < placeOrderBody.orderAmount!) {
                        showCustomSnackBar(getTranslated('wallet_balance_is_insufficient', context)!);

                      } else{
                        orderProvider.placeOrder( placeOrderBody, _callback);
                      }
                    }else{
                      showAnimatedDialog(context, OfflinePaymentDialog(
                        placeOrderBody: placeOrderBody,
                        callBack: (placeOrder) => orderProvider.placeOrder( placeOrder, _callback),
                      ), dismissible: false, isFlip: true);
                    }


                  }else{
                    String? hostname = html.window.location.hostname;
                    String protocol = html.window.location.protocol;
                    String port = html.window.location.port;
                    final String placeOrder =  convert.base64Url.encode(convert.utf8.encode(convert.jsonEncode(placeOrderBody.toJson())));

                    String url = "customer_id=${Provider.of<ProfileProvider>(context, listen: false).userInfoModel!.id}"
                        "&&callback=${AppConstants.baseUrl}${RouteHelper.orderSuccessful}&&order_amount=${(widget.amount! + widget.deliveryCharge!).toStringAsFixed(2)}";

                    String webUrl = "customer_id=${Provider.of<ProfileProvider>(context, listen: false).userInfoModel!.id}"
                        "&&callback=$protocol//$hostname${RouteHelper.orderWebPayment}&&order_amount=${(widget.amount! + widget.deliveryCharge!).toStringAsFixed(2)}&&status=";

                    String webUrlDebug = "customer_id=${Provider.of<ProfileProvider>(context, listen: false).userInfoModel!.id}"
                        "&&callback=$protocol//$hostname:$port${RouteHelper.orderWebPayment}&&order_amount=${(widget.amount! + widget.deliveryCharge!).toStringAsFixed(2)}&&status=";

                    String tokenUrl = convert.base64Encode(convert.utf8.encode(ResponsiveHelper.isWeb() ? (kDebugMode ? webUrlDebug : webUrl) : url));
                    String selectedUrl = '${AppConstants.baseUrl}/payment-mobile?token=$tokenUrl&&payment_method=${orderProvider.paymentMethod}';

                    orderProvider.clearPlaceOrder().then((_) => orderProvider.setPlaceOrder(placeOrder).then((value) {
                      if(ResponsiveHelper.isWeb()){
                        html.window.open(selectedUrl,"_self");
                      }else{
                        Navigator.pushReplacementNamed(context, RouteHelper.getPaymentRoute(
                          page: 'checkout',  selectAddress: tokenUrl, placeOrderBody: placeOrderBody,
                        ));
                      }

                    }));
                  }
                }
              },
            );
          }
      ),
    );
  }

  void _callback(bool isSuccess, String message, String orderID) async {
    if (isSuccess) {
      Provider.of<CartProvider>(Get.context!, listen: false).clearCartList();
      Provider.of<OrderProvider>(Get.context!, listen: false).stopLoader();
      if ( Provider.of<OrderProvider>(Get.context!, listen: false).paymentMethod != 'cash_on_delivery') {
        Navigator.pushReplacementNamed(Get.context!,
          '${'${RouteHelper.orderSuccessful}/'}$orderID/success',
          arguments: OrderSuccessfulScreen(
            orderID: orderID, status: 0,
          ),
        );
      } else {
        Navigator.pushReplacementNamed(Get.context!, '${RouteHelper.orderSuccessful}/$orderID/success');
      }
    } else {
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 600), backgroundColor: Colors.red),);
    }
  }
}
