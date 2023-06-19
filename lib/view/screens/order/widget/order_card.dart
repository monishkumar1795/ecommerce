import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/cart_model.dart';
import 'package:flutter_grocery/data/model/response/order_details_model.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';

import '../order_details_screen.dart';
class OrderCard extends StatelessWidget {
  const OrderCard({Key? key, required this.orderList, required this.index}) : super(key: key);

  final List<OrderModel>? orderList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(
          color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 300]!,
          spreadRadius: 1, blurRadius: 5,
        )],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //date and money
        Row(children: [
          Text(
            DateConverter.isoDayWithDateString(orderList![index].updatedAt!),
            style: poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
          ),
          const Expanded(child: SizedBox.shrink()),

          CustomDirectionality(child: Text(
            PriceConverter.convertPrice(context, orderList![index].orderAmount),
            style: poppinsBold.copyWith(color: Theme.of(context).primaryColor),
          )),
        ]),
        const SizedBox(height: 8),
        //Order list
        Text('${getTranslated('order_id', context)} #${orderList![index].id.toString()}', style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
        //item position
        Row(children: [
          Icon(Icons.circle, color: Theme.of(context).primaryColor, size: 16),
          const SizedBox(width: Dimensions.paddingSizeExtraSmall),
          Text(
            '${getTranslated('order_is', context)} ${getTranslated(orderList![index].orderStatus, context)}',
            style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor),
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        SizedBox(
          height: 50,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            // View Details Button
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(
                  RouteHelper.getOrderDetailsRoute(orderList![index].id),
                  arguments: OrderDetailsScreen(orderId: orderList![index].id, orderModel: orderList![index]),
                );
              },
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: ColorResources.getGreyColor(context),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 100]!,
                          spreadRadius: 1,
                          blurRadius: 5)
                    ],
                    borderRadius: BorderRadius.circular(10)),
                child: Text(getTranslated('view_details', context)!,
                    style: poppinsRegular.copyWith(
                      color: Colors.black,
                      fontSize: Dimensions.fontSizeDefault,
                    )),
              ),
            ),

            orderList![index].orderType != 'pos' ? Consumer<OrderProvider>(
                builder: (context, orderProvider, _) {
                  return Consumer<ProductProvider>(
                      builder: (context, productProvider, child) {
                      return TextButton(
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(width: 2, color: Theme.of(context).primaryColor))),
                        onPressed: () async {
                          if(orderProvider.isActiveOrder) {
                            Navigator.of(context).pushNamed(RouteHelper.getOrderTrackingRoute(orderList![index].id));
                          }else {
                            List<OrderDetailsModel> orderDetails = (await orderProvider.getOrderDetails(orderList![index].id.toString()))!;
                            List<CartModel> cartList = [];
                            String? errorMessage;
                            Variations? variation;
                            String? error;

                             await Future.forEach(orderDetails, (dynamic orderDetail) async {
                               Product? product;
                               try{
                                 product = await productProvider.getProductDetails(
                                   context, '${orderDetail.productId}',
                                   Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
                                 );
                               }catch(e){
                                 error = getTranslated('one_or_more_items_not_available', context);

                               }

                              if(product != null) {
                                double? price = product.price;
                                int? stock = product.totalStock;

                                List<String> variationList = [];
                                for (int index = 0; index < productProvider.product!.choiceOptions!.length; index++) {
                                  variationList.add(productProvider.product!.choiceOptions![index].options![productProvider.variationIndex![index]].replaceAll(' ', ''));
                                }
                                String variationType = '';
                                bool isFirst = true;
                                for (var variation in variationList) {
                                  if (isFirst) {
                                    variationType = '$variationType$variation';
                                    isFirst = false;
                                  } else {
                                    variationType = '$variationType-$variation';
                                  }
                                }

                                for (Variations variation in productProvider.product!.variations!) {
                                  if (variation.type == variationType) {
                                    price = variation.price;
                                    variation = variation;
                                    stock = variation.stock;
                                    break;
                                  }
                                }

                                CartModel cartModel = CartModel(
                                    productProvider.product!.id, productProvider.product!.image!.isNotEmpty
                                    ? productProvider.product!.image![0] : '', productProvider.product!.name, price,
                                    PriceConverter.convertWithDiscount(price, productProvider.product!.discount, productProvider.product!.discountType),
                                    productProvider.quantity, variation,
                                    (price!-PriceConverter.convertWithDiscount(price, productProvider.product!.discount, productProvider.product!.discountType)!),
                                    (price-PriceConverter.convertWithDiscount(price, productProvider.product!.tax, productProvider.product!.taxType)!),
                                    productProvider.product!.capacity, productProvider.product!.unit, stock,productProvider.product
                                );

                                if(Provider.of<CartProvider>(Get.context!, listen: false).isExistInCart(cartModel) != null) {
                                  errorMessage = '${cartModel.product!.name} ${'is_already_in_cart'.tr}';

                                }else if(cartModel.stock! < 1) {
                                  errorMessage = '${cartModel.product!.name} ${'is_out_of_stock'.tr}';
                                }else{
                                  cartList.add(cartModel);
                                }

                              }



                            }).then((value) {
                              if(error != null) {
                                showCustomSnackBar(error!);
                              }else if (errorMessage != null) {
                                 showCustomSnackBar(errorMessage!);
                               }else {
                                 if(cartList.isNotEmpty){
                                   for (var cartModel in cartList) {
                                     Provider.of<CartProvider>(context, listen: false).addToCart(cartModel);
                                   }

                                   ResponsiveHelper.isMobilePhone()
                                       ? Provider.of<SplashProvider>(context, listen: false).setPageIndex(2)
                                       : Navigator.pushNamed(context, RouteHelper.cart);
                                 }
    }
                             });
                          }
                        },
                        child: Text(orderProvider.isActiveOrder
                            ?  getTranslated('track_your_order', context)! : 'Re-Order',
                          style: poppinsRegular.copyWith(
                            color: Theme.of(context).primaryColor,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                        ),
                      );
                    }
                  );
                }
            ) : const SizedBox.shrink(),


            //Track your Order Button
          ]),
        ),
      ]),
    );
  }
}
