import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ReviewWidget extends StatelessWidget {
  final ActiveReview reviewModel;
  const ReviewWidget({Key? key, required this.reviewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? customerName = getTranslated('user_not_available', context);

    if(reviewModel.customer != null) {
      customerName = '${reviewModel.customer!.fName ?? ''} ${reviewModel.customer!.lName ?? ''}';
    }




    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipOval(

            child: FadeInImage.assetNetwork(
              image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/${
                  reviewModel.customer != null ? reviewModel.customer!.image ?? '' : ''}',
              placeholder: Images.placeholder(context),
              width: 30, height: 30, fit: BoxFit.cover,
              imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 30, width: 30, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 5),

          Expanded(child: Text(
            customerName!,
            style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
            maxLines: 1, overflow: TextOverflow.ellipsis,
          )),
          const SizedBox(width: 5),
          RatingBar(rating: double.parse('${reviewModel.rating}'), size: Dimensions.paddingSizeDefault),

        ]),
        const SizedBox(height: 5),
        Text(reviewModel.comment!, style: poppinsRegular),
      ]),
    );
  }
}

class ReviewShimmer extends StatelessWidget {
  const ReviewShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(height: 30, width: 30, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Container(height: 15, width: 100, color: Colors.white),
            const Expanded(child: SizedBox()),
            Icon(Icons.star, color: Theme.of(context).primaryColor, size: 18),
            const SizedBox(width: 5),
            Container(height: 15, width: 20, color: Colors.white),
          ]),
          const SizedBox(height: 5),
          Container(height: 15, width: MediaQuery.of(context).size.width, color: Colors.white),
          const SizedBox(height: 3),
          Container(height: 15, width: MediaQuery.of(context).size.width, color: Colors.white),
        ]),
      ),
    );
  }
}

