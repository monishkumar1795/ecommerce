
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/rating_bar.dart';
import 'package:flutter_grocery/view/base/wish_button.dart';
import 'package:flutter_grocery/view/screens/product/widget/variation_view.dart';
import 'package:provider/provider.dart';

import 'product_title_view.dart';

class WebProductInformation extends StatelessWidget {
  final Product? product;
  final int? stock;
  final int? cartIndex;
  final  double? priceWithQuantity;
  const WebProductInformation({Key? key, required this.product, required this.stock, required this.cartIndex, required this.priceWithQuantity}) : super(key: key);

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

    if(startingPriceWithCategoryDiscount != null
        && startingPriceWithCategoryDiscount > 0 &&
        startingPriceWithCategoryDiscount < startingPriceWithDiscount!) {
      startingPriceWithDiscount = startingPriceWithCategoryDiscount;
      endingPriceWithDiscount = endingPriceWithCategoryDiscount;
    }




    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(
              child: Text(
                product!.name ?? '',
                style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeMaxLarge, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8)),
                maxLines: 2,
              ),
            ),

            WishButton(product: product),
          ]),
          const SizedBox(height: 5),

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            product!.rating != null ? RatingBar(
              rating: product!.rating!.isNotEmpty ? double.parse(product!.rating![0].average!) : 0.0,
              size: Dimensions.paddingSizeDefault,
            ) : const SizedBox(),

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

          Text(
            '${product!.capacity} ${product!.unit}',
            style: poppinsRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          //Product Price
          Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            CustomDirectionality(child: Text(
              '${PriceConverter.convertPrice(context, startingPriceWithDiscount)}'
                  '${endingPriceWithDiscount!= null ? ' - ${PriceConverter.convertPrice(context, endingPriceWithDiscount)}' : ''}',
              style: poppinsBold.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeOverLarge),
            )),
            const SizedBox(width: Dimensions.paddingSizeSmall),

            if(startingPriceWithDiscount! < startingPrice! )
              CustomDirectionality(
                child: Text('${PriceConverter.convertPrice(context, startingPrice)}'
                    '${endingPrice!= null ? ' - ${PriceConverter.convertPrice(context, endingPrice)}' : ''}',
                  style: poppinsRegular.copyWith(
                    fontSize: Dimensions.fontSizeDefault,
                    color: Theme.of(context).colorScheme.error.withOpacity(0.6),
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
          ],
          ),


          VariationView(product: product),


          const SizedBox(height: Dimensions.paddingSizeDefault),

          const SizedBox(height: Dimensions.paddingSizeExtraLarge ),

          Row(children: [
            QuantityButton(isIncrement: false, quantity: Provider.of<ProductProvider>(context, listen: false).quantity, stock: stock, cartIndex: cartIndex, maxOrderQuantity: product!.maximumOrderQuantity),
            const SizedBox(width: 30),

            Consumer<ProductProvider>(builder: (context, product, child) {
              return Consumer<CartProvider>(builder: (context, cart, child) {
                return Text(cartIndex != null ? cart.cartList[cartIndex!].quantity.toString() : product.quantity.toString(), style: poppinsSemiBold);
              });
            }),
            const SizedBox(width: 30),

            QuantityButton(isIncrement: true, quantity: Provider.of<ProductProvider>(context, listen: false).quantity, stock: stock, cartIndex: cartIndex, maxOrderQuantity: product!.maximumOrderQuantity),
          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Row(children: [
            Text('${getTranslated('total_amount', context)}:', style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(width: Dimensions.paddingSizeExtraSmall),

            CustomDirectionality(
              child: Text(PriceConverter.convertPrice(context, priceWithQuantity), style: poppinsBold.copyWith(
                color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge,
              )),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),


        ]);
  }
}


