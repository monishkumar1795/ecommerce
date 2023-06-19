import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/body/review_body.dart';
import 'package:flutter_grocery/data/model/response/order_details_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/custom_text_field.dart';
import 'package:provider/provider.dart';

import '../../../../helper/responsive_helper.dart';
import '../../../base/footer_view.dart';

class ProductReviewWidget extends StatelessWidget {
  final List<OrderDetailsModel> orderDetailsList;
  const ProductReviewWidget({Key? key, required this.orderDetailsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return Scrollbar(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height),
                  child: SizedBox(
                    width: 1170,
                    child: ListView.builder(
                      itemCount: orderDetailsList.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                          decoration: BoxDecoration(
                            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 2, offset: const Offset(0, 1))],
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(Dimensions.paddingSizeSmall),
                          ),
                          child: Column(
                            children: [

                              // Product details
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: Images.placeholder(context),
                                      image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/${
                                          orderDetailsList[index].productDetails!.image!.isNotEmpty ?
                                          orderDetailsList[index].productDetails!.image![0] : ''
                                      }',
                                      height: 70, width: 85, fit: BoxFit.cover,
                                      imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 70, width: 85, fit: BoxFit.cover),
                                    ),
                                  ),
                                  const SizedBox(width: Dimensions.paddingSizeSmall),
                                  Expanded(child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(orderDetailsList[index].productDetails!.name!, style: poppinsMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 10),

                                      CustomDirectionality(child: Text(PriceConverter.convertPrice(
                                        context, orderDetailsList[index].productDetails!.price,
                                      ), style: poppinsBold)),
                                    ],
                                  )),
                                  Row(children: [
                                    Text(
                                      '${getTranslated('quantity', context)}: ',
                                      style: poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)), overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      orderDetailsList[index].quantity.toString(),
                                      style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ]),
                                ],
                              ),
                              const Divider(height: 20),

                              // Rate
                              Text(
                                getTranslated('rate_the_order', context)!,
                                style: poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)), overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              SizedBox(
                                height: 30,
                                child: ListView.builder(
                                  itemCount: 5,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, i) {
                                    return InkWell(
                                      child: Icon(
                                        orderProvider.ratingList[index] < (i + 1) ? Icons.star_border : Icons.star,
                                        size: 25,
                                        color: orderProvider.ratingList[index] < (i + 1)
                                            ? Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)
                                            : Theme.of(context).primaryColor,
                                      ),
                                      onTap: () {
                                        if(!orderProvider.submitList[index]) {
                                          orderProvider.setRating(index, i + 1);
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              Text(
                                getTranslated('share_your_opinion', context)!,
                                style: poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)), overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: Dimensions.paddingSizeLarge),
                              CustomTextField(
                                maxLines: 3,
                                capitalization: TextCapitalization.sentences,
                                isEnabled: !orderProvider.submitList[index],
                                hintText: getTranslated('write_your_review_here', context),
                                fillColor: Theme.of(context).cardColor,
                                onChanged: (text) {
                                  orderProvider.setReview(index, text);
                                },
                              ),
                              const SizedBox(height: 20),

                              // Submit button
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                                child: Column(
                                  children: [
                                    !orderProvider.loadingList[index] ? CustomButton(
                                      buttonText: getTranslated(orderProvider.submitList[index] ? 'submitted' : 'submit', context),
                                      onPressed: orderProvider.submitList[index] ? null : () {
                                        if(!orderProvider.submitList[index]) {
                                          if (orderProvider.ratingList[index] == 0) {
                                            showCustomSnackBar(getTranslated('give_a_rating', context)!);
                                          } else if (orderProvider.reviewList[index].isEmpty) {
                                            showCustomSnackBar(getTranslated('write_a_review', context)!);
                                          } else {
                                            FocusScopeNode currentFocus = FocusScope.of(context);
                                            if (!currentFocus.hasPrimaryFocus) {
                                              currentFocus.unfocus();
                                            }
                                            ReviewBody reviewBody = ReviewBody(
                                              productId: orderDetailsList[index].productId.toString(),
                                              rating: orderProvider.ratingList[index].toString(),
                                              comment: orderProvider.reviewList[index],
                                              orderId: orderDetailsList[index].orderId.toString(),
                                            );
                                            orderProvider.submitReview(index, reviewBody).then((value) {
                                              if (value.isSuccess) {
                                                showCustomSnackBar(value.message!, isError: false);
                                                orderProvider.setReview(index, '');
                                              } else {
                                                showCustomSnackBar(value.message!);
                                              }
                                            });
                                          }
                                        }
                                      },
                                    ) : Center(child: CustomLoader(color: Theme.of(context).primaryColor)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }
}
