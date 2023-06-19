import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/rating_bar.dart';
import 'package:flutter_grocery/view/base/wish_button.dart';
import 'package:provider/provider.dart';

class ProductTitleView extends StatelessWidget {
  final Product? product;
  final int? stock;
  final int? cartIndex;
  const ProductTitleView({Key? key, required this.product, required this.stock,required this.cartIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? startingPrice;
    double? startingPriceWithDiscount;
    double? startingPriceWithCategoryDiscount;
    double? endingPrice;
    double? endingPriceWithDiscount;
    double? endingPriceWithCategoryDiscount;
    if(product!.variations!.isNotEmpty) {
      List<double?> priceList = [];
      for (var variation in product!.variations!) {
        priceList.add(variation.price);
      }
      priceList.sort((a, b) => a!.compareTo(b!));
      startingPrice = priceList[0];
      if(priceList[0]! < priceList[priceList.length-1]!) {
        endingPrice = priceList[priceList.length-1];
      }
    }else {
      startingPrice = product!.price;
    }


    if(product!.categoryDiscount != null) {
      startingPriceWithCategoryDiscount = PriceConverter.convertWithDiscount(
        startingPrice, product!.categoryDiscount!.discountAmount, product!.categoryDiscount!.discountType,
        maxDiscount: product!.categoryDiscount!.maximumAmount,
      );

      if(endingPrice != null){
        endingPriceWithCategoryDiscount = PriceConverter.convertWithDiscount(
          endingPrice, product!.categoryDiscount!.discountAmount, product!.categoryDiscount!.discountType,
          maxDiscount: product!.categoryDiscount!.maximumAmount,
        );
      }
    }
    startingPriceWithDiscount = PriceConverter.convertWithDiscount(startingPrice, product!.discount, product!.discountType);

    if(endingPrice != null) {
      endingPriceWithDiscount = PriceConverter.convertWithDiscount(endingPrice, product!.discount, product!.discountType);
    }

    if(startingPriceWithCategoryDiscount != null &&
        startingPriceWithCategoryDiscount > 0 &&
        startingPriceWithCategoryDiscount < startingPriceWithDiscount!) {
      startingPriceWithDiscount = startingPriceWithCategoryDiscount;
      endingPriceWithDiscount = endingPriceWithCategoryDiscount;
    }




    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(Dimensions.paddingSizeDefault),
          topRight: Radius.circular(Dimensions.paddingSizeDefault),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 3,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(
                  product!.name ?? '',
                    style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                ),

                WishButton(product: product),

              ],
            ),

            product!.rating != null ? Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
              child: RatingBar(
                rating: product!.rating!.isNotEmpty ? double.parse(product!.rating![0].average!) : 0.0, size: Dimensions.paddingSizeDefault,
              ),
            ) : const SizedBox(),

            //Product Price
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              CustomDirectionality(child: Text(
                '${PriceConverter.convertPrice(context, startingPriceWithDiscount, )}'
                    '${endingPriceWithDiscount!= null ? ' - ${PriceConverter.convertPrice(context, endingPriceWithDiscount)}' : ''}',
                style: poppinsBold.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6), fontSize: Dimensions.fontSizeLarge),
              )),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
                  color: product!.totalStock! > 0
                      ?  Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.3),
                ),
                child: Text(
                  '${ getTranslated(product!.totalStock! > 0
                      ? 'in_stock' : 'stock_out', context)}',
                  style: poppinsMedium.copyWith(color: Colors.white),
                ),
              ),
            ]),
            const SizedBox(height: Dimensions.paddingSizeSmall),



            startingPriceWithDiscount! < startingPrice!  ? CustomDirectionality(
              child: Text(
                '${PriceConverter.convertPrice(context, startingPrice)}'
                    '${endingPrice != null ? ' - ${PriceConverter.convertPrice(context, endingPrice)}' : ''}',
                style: poppinsBold.copyWith(
                  color: Theme.of(context).hintColor.withOpacity(0.6),
                  fontSize: Dimensions.fontSizeSmall, decoration: TextDecoration.lineThrough,
                ),
              ),
            ): const SizedBox(),

            Row(children: [

              Text(
                '${product!.capacity} ${product!.unit}',
                style: poppinsRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall),
              ),

              const Expanded(child: SizedBox.shrink()),

              Builder(
                builder: (context) {
                  return Row(children: [
                    QuantityButton(
                      isIncrement: false, quantity: productProvider.quantity,
                      stock: stock,cartIndex: cartIndex,
                      maxOrderQuantity: product!.maximumOrderQuantity,
                    ),
                    const SizedBox(width: 15),

                    Consumer<CartProvider>(builder: (context, cart, child) {
                      return Text(cartIndex != null ? cart.cartList[cartIndex!].quantity.toString()
                          : productProvider.quantity.toString(), style: poppinsSemiBold,
                      );
                    }),
                    const SizedBox(width: 15),

                    QuantityButton(
                      isIncrement: true, quantity: productProvider.quantity,
                      stock: stock, cartIndex: cartIndex,
                      maxOrderQuantity: product!.maximumOrderQuantity,
                    ),
                  ]);
                }
              ),
            ]),
          ]);
        },
      ),
    );
  }
}

class QuantityButton extends StatelessWidget {
  final bool isIncrement;
  final int quantity;
  final bool isCartWidget;
  final int? stock;
  final int? maxOrderQuantity;
  final int? cartIndex;

  const QuantityButton({Key? key, 
    required this.isIncrement,
    required this.quantity,
    required this.stock,
    required this.maxOrderQuantity,
    this.isCartWidget = false,
    required this.cartIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    return InkWell(
      onTap: () {
        if(cartIndex != null) {
          if(isIncrement) {
            if(maxOrderQuantity == null || cartProvider.cartList[cartIndex!].quantity! < maxOrderQuantity!){
              if (cartProvider.cartList[cartIndex!].quantity! < cartProvider.cartList[cartIndex!].stock!) {
                cartProvider.setQuantity(true, cartIndex, showMessage: true, context: context);
              } else {
                showCustomSnackBar(getTranslated('out_of_stock', context)!);
              }
            }else{
              showCustomSnackBar('${getTranslated('you_can_add_max', context)} $maxOrderQuantity ${
                  getTranslated(maxOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
            }

          }else {
            if (Provider.of<CartProvider>(context, listen: false).cartList[cartIndex!].quantity! > 1) {
              Provider.of<CartProvider>(context, listen: false).setQuantity(false, cartIndex, showMessage: true, context: context);
            } else {
              Provider.of<ProductProvider>(context, listen: false).setExistData(null);
              cartProvider.removeFromCart(cartIndex!, context);
            }
          }
        }else {
          if (!isIncrement && quantity > 1) {
            Provider.of<ProductProvider>(context, listen: false).setQuantity(false);
          } else if (isIncrement) {
            if(maxOrderQuantity == null || quantity < maxOrderQuantity!) {
              if(quantity < stock!) {
                Provider.of<ProductProvider>(context, listen: false).setQuantity(true);
              }else {
                showCustomSnackBar(getTranslated('out_of_stock', context)!);
              }
            }else{
              showCustomSnackBar('${getTranslated('you_can_add_max', context)} $maxOrderQuantity ${
                  getTranslated(maxOrderQuantity! > 1 ? 'items' : 'item', context)} ${getTranslated('only', context)}');
            }
          }
        }
      },
      child: ResponsiveHelper.isDesktop(context)  ? Container(
        // padding: EdgeInsets.all(3),
        height: 50,width: 50,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5),color: Theme.of(context).primaryColor),
        child: Center(
          child: Icon(
            isIncrement ? Icons.add : Icons.remove,
            color: isIncrement
                ? Theme.of(context).textTheme.bodyLarge?.color
                : quantity > 1
                ? Theme.of(context).textTheme.bodyLarge?.color
                : Theme.of(context).textTheme.bodyLarge?.color,
            size: isCartWidget ? 26 : 20,
          ),
        ),
      ) : Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color:  ColorResources.getGreyColor(context))),
        child: Icon(
          isIncrement ? Icons.add : Icons.remove,
          color: isIncrement
              ?  Theme.of(context).primaryColor
              : quantity > 1
                  ?  Theme.of(context).primaryColor
                  :  Theme.of(context).primaryColor,
          size: isCartWidget ? 26 : 20,
        ),
      ),
    );
  }
}
