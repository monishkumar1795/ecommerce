import 'package:flutter/material.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ProductShimmer extends StatelessWidget {
  final bool isEnabled;
  const ProductShimmer({Key? key, required this.isEnabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: isEnabled,
        child: Row(children: [

          Container(
            height: 85, width: 85,
            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: ColorResources.getGreyColor(context)),
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(height: 15, width: MediaQuery.of(context).size.width, color: Colors.grey[300]),
                const SizedBox(height: 2),
                Container(height: 15, width: MediaQuery.of(context).size.width, color: Colors.grey[300]),
                const SizedBox(height: 10),
                Container(height: 10, width: 50, color: Colors.grey[300]),
              ]),
            ),
          ),

          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(height: 15, width: 50, color: Colors.grey[300]),
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(width: 1, color: Theme.of(context).hintColor.withOpacity(0.6).withOpacity(0.2)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.add, color: Theme.of(context).primaryColor),
            ),
          ]),

        ]),
      ),
    );
  }
}
