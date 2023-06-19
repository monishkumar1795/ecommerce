import 'package:flutter/material.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WebProductShimmer extends StatelessWidget {
  final bool isEnabled;
  const WebProductShimmer({Key? key, required this.isEnabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).cardColor,
      ),
      child: Shimmer(
        duration: const Duration(seconds: 2),
        enabled: isEnabled,
        child: Column(children: [
          Expanded(
            child: Container(
              height: 100,
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: ColorResources.getGreyColor(context)),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[300],
              ),
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

        ]),
      ),
    );
  }
}
