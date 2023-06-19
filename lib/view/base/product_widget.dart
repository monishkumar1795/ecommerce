
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/cart_model.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/on_hover.dart';
import 'package:flutter_grocery/view/base/rating_bar.dart';
import 'package:provider/provider.dart';

import 'wish_button.dart';

class ProductWidget extends StatelessWidget {
  final Product product;
  final String productType;
  final bool isGrid;
  ProductWidget({Key? key, required this.product, this.productType = ProductType.dailyItem, this.isGrid = false}) : super(key: key);


  final oneSideShadow = Padding(
    padding: const EdgeInsets.only(left: 5, right: 5, top: 5),
    child: Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {

    double? priceWithDiscount = 0;
    double? categoryDiscountAmount;
    if(product.categoryDiscount != null) {
      categoryDiscountAmount = PriceConverter.convertWithDiscount(
        product.price, product.categoryDiscount!.discountAmount, product.categoryDiscount!.discountType,
        maxDiscount: product.categoryDiscount!.maximumAmount,
      );
    }

    priceWithDiscount = PriceConverter.convertWithDiscount(product.price, product.discount, product.discountType);


    if(categoryDiscountAmount != null && categoryDiscountAmount > 0
        && categoryDiscountAmount  < priceWithDiscount!) {
      priceWithDiscount = categoryDiscountAmount;

    }

    return Consumer<CartProvider>(
      builder: (context, cartProvider, child) {
        double? price = 0;
        int? stock = 0;
        bool isExistInCart = false;
        int? cardIndex;
        CartModel? cartModel;
        if(product.variations!.isNotEmpty) {
          for(int index=0; index<product.variations!.length; index++) {
            price = product.variations!.isNotEmpty ? product.variations![index].price : product.price;
            stock = product.variations!.isNotEmpty ? product.variations![index].stock : product.totalStock;
            cartModel = CartModel(product.id, product.image!.isNotEmpty ? product.image![0] : '', product.name, price,
                PriceConverter.convertWithDiscount(price, product.discount, product.discountType),
                1,
                product.variations!.isNotEmpty ? product.variations![index] : null,
                (price! - PriceConverter.convertWithDiscount(price, product.discount, product.discountType)!),
                (price - PriceConverter.convertWithDiscount(price, product.tax, product.taxType)!),
                product.capacity,
                product.unit,
                stock,product
            );
            isExistInCart = Provider.of<CartProvider>(context, listen: false).isExistInCart(cartModel) != null;
            cardIndex = Provider.of<CartProvider>(context, listen: false).isExistInCart(cartModel);
            if(isExistInCart) {
              break;
            }
          }
        }else {
          price = product.variations!.isNotEmpty ? product.variations![0].price! : product.price!;
          stock = product.variations!.isNotEmpty ? product.variations![0].stock! : product.totalStock!;
          cartModel = CartModel(product.id, product.image!.isNotEmpty ?  product.image![0] : '', product.name, price,
              PriceConverter.convertWithDiscount(price, product.discount, product.discountType),
              1,
              product.variations!.isNotEmpty ? product.variations![0] : null,
              (price - PriceConverter.convertWithDiscount(price, product.discount, product.discountType)!),
              (price - PriceConverter.convertWithDiscount(price, product.tax, product.taxType)!),
              product.capacity,
              product.unit,
              stock,product
          );
          isExistInCart = Provider.of<CartProvider>(context, listen: false).isExistInCart(cartModel) != null;
          cardIndex = Provider.of<CartProvider>(context, listen: false).isExistInCart(cartModel);
        }

        return ResponsiveHelper.isDesktop(context) ? OnHover(
          isItem: true,
          child: _productGridView(context, isExistInCart, stock, cartModel, cardIndex, priceWithDiscount!),
        ) : isGrid ? _productGridView(context, isExistInCart, stock, cartModel, cardIndex, priceWithDiscount!) :
        Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
          child: InkWell(
            onTap: () => Navigator.of(context).pushNamed(RouteHelper.getProductDetailsRoute(
              product: product, formSearch: productType == ProductType.searchItem,
            )),

            child: Container(
              height: 85,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).cardColor,
              ),
              child: Row(children: [
                Container(
                  height: 85,
                  width: 85,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2,
                        color: ColorResources.getGreyColor(context)),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${
                          product.image!.isNotEmpty ? product.image![0] : ''}',
                      placeholder: (context, url) => Image.asset(Images.placeholder(context)),
                      errorWidget: (context, url, error) => Image.asset(Images.placeholder(context)),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: Text(product.name!,
                              style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),


                          product.rating != null ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: RatingBar(rating: product.rating!.isNotEmpty ? double.parse(product.rating![0].average!) : 0.0, size: 10),
                          ) : const SizedBox(),

                          Text('${product.capacity} ${product.unit}',
                              style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))),

                          Flexible(
                            child: Row(children: [
                              product.price! > priceWithDiscount! ? CustomDirectionality(child: Text(
                                PriceConverter.convertPrice(context, product.price),
                                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall, decoration: TextDecoration.lineThrough),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )) : const SizedBox(),

                              product.price! > priceWithDiscount ? const SizedBox(width: Dimensions.paddingSizeExtraSmall) : const SizedBox(),

                              CustomDirectionality(child: Text(
                                PriceConverter.convertPrice(context, priceWithDiscount),
                                style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeSmall),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              )),

                            ],),
                          ),
                        ]),
                  ),
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: WishButton(product: product, edgeInset: const EdgeInsets.all(5)),
                      ),
                      const Expanded(child: SizedBox()),
                      !isExistInCart
                          ? InkWell(
                          onTap: () {
                            if(product.variations == null || product.variations!.isEmpty) {
                              if (isExistInCart) {
                                showCustomSnackBar('already_added'.tr);
                              } else if (stock! < 1) {
                                showCustomSnackBar('out_of_stock'.tr);
                              } else {
                                Provider.of<CartProvider>(context, listen: false).addToCart(cartModel!);
                                showCustomSnackBar('added_to_cart'.tr, isError: false);
                              }
                            }else {
                              Navigator.of(context).pushNamed(
                                RouteHelper.getProductDetailsRoute(
                                  product: product, formSearch:productType == ProductType.searchItem,
                                ),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            margin: const EdgeInsets.all(2),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Theme.of(context).hintColor.withOpacity(0.6).withOpacity(0.2)),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.add,
                                color: Theme.of(context).primaryColor),
                          ))
                          : Consumer<CartProvider>(builder: (context, cart, child) =>
                          Row(children: [
                            InkWell(
                              onTap: () {
                                if (cart.cartList[cardIndex!].quantity! > 1) {
                                  Provider.of<CartProvider>(context, listen: false).setQuantity(false, cardIndex, context: context, showMessage: true);
                                } else {
                                  Provider.of<CartProvider>(context, listen: false).removeFromCart(cardIndex, context);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeExtraSmall),
                                child: Icon(Icons.remove, size: 20, color: Theme.of(context).primaryColor),
                              ),
                            ),
                            Text(
                                cart.cartList[cardIndex!].quantity.toString(),
                                style: poppinsSemiBold.copyWith(
                                    fontSize: Dimensions.fontSizeExtraLarge,
                                    color: Theme.of(context).primaryColor)),
                            InkWell(
                              onTap: () {
                                if (cart.cartList[cardIndex!].quantity! <
                                    cart.cartList[cardIndex].stock!) {
                                  Provider.of<CartProvider>(context, listen: false).setQuantity(true, cardIndex, context: context, showMessage: true);
                                } else {
                                  showCustomSnackBar('out_of_stock'.tr);
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: Dimensions.paddingSizeSmall,
                                    vertical: Dimensions.paddingSizeExtraSmall),
                                child: Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ]),
                      ),
                    ]),
              ]),
            ),
          ),
        );
      },
    );
  }

  InkWell _productGridView(BuildContext context, bool isExistInCart, int? stock, CartModel? cartModel, int? cardIndex, double priceWithDiscount) {

    return InkWell(
          borderRadius:  BorderRadius.circular(Dimensions.radiusSizeTen),
          onTap: () {
            Navigator.of(context).pushNamed(RouteHelper.getProductDetailsRoute(
              product: product, formSearch:productType == ProductType.searchItem,
            ));
          },
          child: Container(
            decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
            boxShadow: [BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 4),
              blurRadius: 7,
              spreadRadius: 0.1,
            ),]), 
            child: Stack(children: [
              Column(children: [
                Expanded(
                  flex: 6,
                  child: Stack(children: [
                    oneSideShadow,

                    Container(
                      padding: const EdgeInsets.all(5),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radiusSizeTen),
                          topRight: Radius.circular(Dimensions.radiusSizeTen),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(Dimensions.radiusSizeTen),
                          topRight: Radius.circular(Dimensions.radiusSizeTen),
                        ),
                        child: FadeInImage.assetNetwork(
                          placeholder: Images.placeholder(context),
                          height: 155,
                          fit: BoxFit.cover,
                          image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${
                              product.image!.isNotEmpty ? product.image![0] : ''}',
                          imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), width: 80, height: 155, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                  ],
                ),),
                
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          product.name!,
                          style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      product.rating != null ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: RatingBar(rating: product.rating!.isNotEmpty ? double.parse(product.rating![0].average!) : 0.0, size: 10),
                      ) : const SizedBox(),

                      Text(
                        '${product.capacity} ${product.unit}',
                        style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      CustomDirectionality(child: Text(
                        PriceConverter.convertPrice(context, priceWithDiscount),
                        style: poppinsBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge),
                      )),

                      product.price! > priceWithDiscount  ?
                      CustomDirectionality(
                        child: Text(
                            PriceConverter.convertPrice(context, product.price),
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeExtraSmall,
                              color: Theme.of(context).colorScheme.error,
                              decoration: TextDecoration.lineThrough,
                            )),
                      ) : const SizedBox(),

                      if(productType == ProductType.latestProduct) Column(children: [
                        !isExistInCart ? InkWell(
                          onTap: () {
                            if(product.variations == null || product.variations!.isEmpty) {
                              if (isExistInCart) {
                                showCustomSnackBar('already_added'.tr);
                              } else if (stock! < 1) {
                                showCustomSnackBar('out_of_stock'.tr);
                              } else {
                                Provider.of<CartProvider>(context, listen: false).addToCart(cartModel!);
                                showCustomSnackBar('added_to_cart'.tr, isError: false);
                              }
                            }else {
                              Navigator.of(context).pushNamed(
                                RouteHelper.getProductDetailsRoute(
                                  product: product, formSearch:productType == ProductType.searchItem,
                                ),
                              );
                            }
                          },
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Text(
                                'add_to_cart'.tr,
                                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                              SizedBox(
                                height: 16,
                                width: 16,
                                child: Image.asset(Images.shoppingCartBold),
                              ),
                            ],
                          ),
                        ) :
                        Consumer<CartProvider>(builder: (context, cart, child) =>
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (cart.cartList[cardIndex!].quantity! > 1) {
                                      Provider.of<CartProvider>(context, listen: false).setQuantity(false, cardIndex);
                                    } else {
                                      Provider.of<CartProvider>(context, listen: false).removeFromCart(cardIndex, context);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                      vertical: Dimensions.paddingSizeExtraSmall,
                                    ),
                                    child: Icon(Icons.remove, size: 20, color: Theme.of(context).primaryColor,),
                                  ),
                                ),

                                Text(
                                  cart.cartList[cardIndex!].quantity.toString(), style: poppinsSemiBold.copyWith(
                                  fontSize: Dimensions.fontSizeExtraLarge,
                                  color: Theme.of(context).primaryColor,
                                ),),

                                InkWell(
                                  onTap: () {
                                    if (cart.cartList[cardIndex].quantity! < cart.cartList[cardIndex].stock!) {
                                      Provider.of<CartProvider>(context, listen: false).setQuantity(true, cardIndex);
                                    } else {
                                      showCustomSnackBar('out_of_stock'.tr);
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: Dimensions.paddingSizeSmall,
                                      vertical: Dimensions.paddingSizeExtraSmall,),
                                    child: Icon(Icons.add, size: 20, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ],
                            ),
                        ),

                      ],),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),


                    ],
                  ),
                ),
              ],),

              Positioned.fill(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: WishButton(product: product, edgeInset: const EdgeInsets.all(8.0),),
                  )
              ),
            ],),
          ),
        );
  }
}


