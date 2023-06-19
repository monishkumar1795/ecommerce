import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/category_model.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/text_hover.dart';

class CategoryHoverWidget extends StatelessWidget {
  final List<CategoryModel>? categoryList;
  const CategoryHoverWidget({Key? key, required this.categoryList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
      child: Column(
          children: categoryList!.map((category) => InkWell(
            onTap: () async {
              Future.delayed(const Duration(milliseconds: 100)).then((value) async{

                await Navigator.of(context).pushNamed(
                  RouteHelper.getCategoryProductsRouteNew(categoryModel:  category),
                );
                Navigator.of(Get.context!).pop();

                Navigator.of(Get.context!).pushNamed(
                  RouteHelper.getCategoryProductsRouteNew(categoryModel: category),
                );
              });
            },
            child: TextHover(
                builder: (isHover) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeDefault),
                    decoration: BoxDecoration(color: isHover ? ColorResources.getGreyColor(context) : Theme.of(context).cardColor, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(width: 200,child: Text(category.name!, overflow: TextOverflow.ellipsis,maxLines: 1,)),
                        const Icon(Icons.chevron_right, size: Dimensions.paddingSizeDefault),
                      ],
                    ),
                  );
                }
            ),
          )).toList()
      ),
    );
  }
}
