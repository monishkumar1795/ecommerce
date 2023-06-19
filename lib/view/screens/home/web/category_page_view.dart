import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/on_hover.dart';
import 'package:flutter_grocery/view/base/text_hover.dart';
import 'package:provider/provider.dart';

import '../../../../../provider/splash_provider.dart';
import '../../../../../utill/color_resources.dart';
import '../../../../../utill/dimensions.dart';
import '../../../../../utill/images.dart';

class CategoryPageView extends StatelessWidget {
  final CategoryProvider categoryProvider;
  final PageController pageController;
  const CategoryPageView({Key? key, required this.categoryProvider, required this.pageController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalPage = (categoryProvider.categoryList!.length / 7).ceil();

    return PageView.builder(
      controller: pageController,
      itemCount: totalPage,
      onPageChanged: (index) {
        categoryProvider.updateProductCurrentIndex(index, totalPage);
      },
      itemBuilder: (context, index) {
        int initialLength = 7;
        int currentIndex = 7 * index;

        if(index + 1 == totalPage){
          initialLength = categoryProvider.categoryList!.length - (index * 7);
        }else{
          initialLength = 7;
        }

        return Align(
          alignment: initialLength < 7 ? Provider.of<LocalizationProvider>(context).isLtr ? Alignment.centerLeft : Alignment.centerRight  : Alignment.center,
          child: ListView.builder(
              itemCount: initialLength, scrollDirection: Axis.horizontal, physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
              itemBuilder: (context, item) {
                int currentIndex0 = item  + currentIndex;
                String? name = '';
                categoryProvider.categoryList![currentIndex0].name!.length > 20 ? name = '${categoryProvider.categoryList![currentIndex0].name!.substring(0, 20)} ...' : name = categoryProvider.categoryList![currentIndex0].name;
                return Container(
                          margin: const EdgeInsets.only(top: 20,left: 20,right: 15),
                          child: InkWell(
                            hoverColor: Colors.transparent,
                            onTap: (){
                              Navigator.of(context).pushNamed(
                                RouteHelper.getCategoryProductsRouteNew(categoryModel: categoryProvider.categoryList![currentIndex0]),
                                // arguments: CategoryProductScreenNew(categoryModel: categoryProvider.categoryList[_currentIndex]),
                              );
                              },
                            child: TextHover(
                              builder: (hovered) {
                                return Column(children: [
                                  OnHover(

                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(Provider.of<ThemeProvider>(context).darkTheme ? 0.05 : 1),
                                          borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
                                          boxShadow:Provider.of<ThemeProvider>(context).darkTheme
                                              ? null
                                              : [
                                            BoxShadow(
                                              color:ColorResources.cartShadowColor.withOpacity(0.3),
                                              blurRadius: 20,
                                            )
                                          ]
                                      ),
                                      padding: const EdgeInsets.all(3),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(Dimensions.radiusSizeLarge),
                                        child: FadeInImage.assetNetwork(
                                          placeholder: Images.placeholder(context), width: 125, height: 125, fit: BoxFit.cover,
                                          image: Provider.of<SplashProvider>(context, listen: false).baseUrls != null
                                              ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.categoryImageUrl}/${categoryProvider.categoryList![currentIndex0].image}':'',
                                          imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), width: 125, height: 125, fit: BoxFit.cover),

                                        ),
                                      ),
                                    ),
                                  ),

                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: Dimensions.paddingSizeDefault),
                                      child:  SizedBox(
                                        width: 120,
                                        child: Text(
                                          name!,
                                          style: poppinsMedium.copyWith(color: hovered ? Theme.of(context).primaryColor : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),

                                ]);
                              }
                            ),
                          ),
                        );
              }
          ),
        );
      },
    );
  }
}
