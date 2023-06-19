import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/body/review_body.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/custom_text_field.dart';
import 'package:flutter_grocery/view/screens/order/widget/delivery_man_widget.dart';
import 'package:provider/provider.dart';

import '../../../../helper/responsive_helper.dart';
import '../../../base/footer_view.dart';

class DeliveryManReviewWidget extends StatefulWidget {
  final DeliveryMan? deliveryMan;
  final String orderID;
  const DeliveryManReviewWidget({Key? key, required this.deliveryMan, required this.orderID}) : super(key: key);

  @override
  State<DeliveryManReviewWidget> createState() => _DeliveryManReviewWidgetState();
}

class _DeliveryManReviewWidgetState extends State<DeliveryManReviewWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height),
                  child: SizedBox(
                    width: 1170,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [

                      widget.deliveryMan != null ? DeliveryManWidget(deliveryMan: widget.deliveryMan) : const SizedBox(),
                      const SizedBox(height: Dimensions.paddingSizeLarge),

                      Container(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(
                            color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 700 : 300]!,
                            blurRadius: 5, spreadRadius: 1,
                          )],
                        ),
                        child: Column(children: [
                          Text(
                            getTranslated('rate_his_service', context)!,
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
                                    orderProvider.deliveryManRating < (i + 1) ? Icons.star_border : Icons.star,
                                    size: 25,
                                    color: orderProvider.deliveryManRating < (i + 1)
                                        ? Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)
                                        : Theme.of(context).primaryColor,
                                  ),
                                  onTap: () {
                                    orderProvider.setDeliveryManRating(i + 1);
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
                            maxLines: 5,
                            capitalization: TextCapitalization.sentences,
                            controller: _controller,
                            hintText: getTranslated('write_your_review_here', context),
                            fillColor: Theme.of(context).cardColor,
                          ),
                          const SizedBox(height: 40),

                          // Submit button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
                            child: Column(
                              children: [
                                !orderProvider.isLoading ? CustomButton(
                                  buttonText: getTranslated('submit', context),
                                  onPressed: () {
                                    if (orderProvider.deliveryManRating == 0) {
                                      showCustomSnackBar(getTranslated('give_a_rating', context)!);
                                    } else if (_controller.text.isEmpty) {
                                      showCustomSnackBar(getTranslated('write_a_review', context)!);
                                    } else {
                                      FocusScopeNode currentFocus = FocusScope.of(context);
                                      if (!currentFocus.hasPrimaryFocus) {
                                        currentFocus.unfocus();
                                      }
                                      ReviewBody reviewBody = ReviewBody(
                                        deliveryManId: widget.deliveryMan!.id.toString(),
                                        rating: orderProvider.deliveryManRating.toString(),
                                        comment: _controller.text,
                                        orderId: widget.orderID,
                                      );
                                      orderProvider.submitDeliveryManReview(reviewBody).then((value) {
                                        if (value.isSuccess) {
                                          showCustomSnackBar(value.message!, isError: false);
                                          _controller.text = '';
                                        } else {
                                          showCustomSnackBar(value.message!);
                                        }
                                      });
                                    }
                                  },
                                ) : Center(child: CustomLoader(color: Theme.of(context).primaryColor)),
                              ],
                            ),
                          ),
                        ]),
                      ),

                    ]),
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
