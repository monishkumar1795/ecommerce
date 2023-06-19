
import 'package:flutter/material.dart';
import 'package:flutter_grocery/provider/flash_deal_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MegaDealShimmer extends StatelessWidget {
  final bool isHomeScreen;
  const MegaDealShimmer({Key? key, required this.isHomeScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: isHomeScreen ? Axis.horizontal : Axis.vertical,
      itemCount: 2,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(20),
          width: 200,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 1, blurRadius: 5)]),
          child: Shimmer(
            color:  Colors.grey[300]!,
            enabled: Provider.of<FlashDealProvider>(context).flashDealList == null,
            child: Column(children: [
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2, color: Colors.grey.withOpacity(0.3)),
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
      },
    );
  }
}