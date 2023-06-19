import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/category_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/main_app_bar.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

// ignore: must_be_immutable
class Allcategoriescreen extends StatefulWidget {
  const Allcategoriescreen({Key? key}) : super(key: key);

  @override
  State<Allcategoriescreen> createState() => _AllcategoriescreenState();
}

class _AllcategoriescreenState extends State<Allcategoriescreen> {

  @override
  void initState() {
    super.initState();
    if(Provider.of<CategoryProvider>(context, listen: false).categoryList != null
        && Provider.of<CategoryProvider>(context, listen: false).categoryList!.isNotEmpty
    ) {
      _load();
    }else{
      Provider.of<CategoryProvider>(context, listen: false).getCategoryList(
        context, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,true,
      ).then((apiResponse) {
        if(apiResponse.response!.statusCode == 200 && apiResponse.response!.data != null){
          _load();
        }

      });
    }

  }
  _load() async {
    final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    categoryProvider.changeIndex(0, notify: false);
    if(categoryProvider.categoryList!.isNotEmpty) {
      categoryProvider.getSubCategoryList(context, categoryProvider.categoryList![0].id.toString(),
        Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context) ?  const MainAppBar(): null,
      body: Center(
        child: SizedBox(
          width: 1170,
          child: Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              return categoryProvider.categoryList != null && categoryProvider.categoryList!.isNotEmpty
                  ? Row(children: [

                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(top: 3),
                        height: double.infinity,
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 900 : 200]!, spreadRadius: 3, blurRadius: 10)],
                        ),
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: categoryProvider.categoryList!.length,
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            CategoryModel category = categoryProvider.categoryList![index];
                            return InkWell(
                              onTap: () {
                                categoryProvider.changeIndex(index);
                                categoryProvider.getSubCategoryList(context, category.id.toString(),
                                  Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode);
                              },
                              child: CategoryItem(
                                title: category.name,
                                icon: category.image,
                                isSelected: categoryProvider.categoryIndex == index,
                              ),
                            );
                          },
                        ),
                      ),

                      categoryProvider.subCategoryList != null
                          ? Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                itemCount: categoryProvider.subCategoryList!.length + 1,
                                itemBuilder: (context, index) {

                                  if(index == 0) {
                                    return ListTile(
                                      onTap: () {
                                        categoryProvider.changeSelectedIndex(-1);
                                        Provider.of<ProductProvider>(context, listen: false).initCategoryProductList(
                                          categoryProvider.categoryList![categoryProvider.categoryIndex].id.toString(), context, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
                                        );
                                        Navigator.of(context).pushNamed(
                                          RouteHelper.getCategoryProductsRouteNew(
                                           categoryModel:  categoryProvider.categoryList![categoryProvider.categoryIndex],
                                          ),
                                        );
                                      },
                                      title: Text(getTranslated('all', context)!),
                                      trailing: const Icon(Icons.keyboard_arrow_right),
                                    );
                                  }
                                  return ListTile(
                                    onTap: () {
                                      categoryProvider.changeSelectedIndex(index-1);
                                      if(ResponsiveHelper.isMobilePhone()) {

                                      }
                                      Provider.of<ProductProvider>(context, listen: false).initCategoryProductList(
                                        categoryProvider.subCategoryList![index-1].id.toString(), context,
                                        Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
                                      );

                                      Navigator.of(context).pushNamed(
                                        RouteHelper.getCategoryProductsRouteNew(
                                          categoryModel: categoryProvider.categoryList![categoryProvider.categoryIndex],
                                          subCategory: categoryProvider.subCategoryList![index-1].name,
                                        ),
                                      );
                                    },
                                    title: Text(categoryProvider.subCategoryList![index-1].name!,
                                      style: poppinsMedium.copyWith(fontSize: 13, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: const Icon(Icons.keyboard_arrow_right),
                                  );
                                },
                              ),
                            )
                          : const Expanded(child: SubCategoriesShimmer()),
                    ])
                  : categoryProvider.categoryList != null && categoryProvider.categoryList!.isEmpty
                  ? const NoDataScreen() : Center(child: CustomLoader(color: Theme.of(context).primaryColor));
            },
          ),
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String? title;
  final String? icon;
  final bool isSelected;

  const CategoryItem({Key? key, required this.title, required this.icon, required this.isSelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        color: isSelected ? Theme.of(context).primaryColor
            : Theme.of(context).cardColor
      ),
      child: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Container(
            height: 60,
            width: 60,
            alignment: Alignment.center,
            //padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? ColorResources.getCategoryBgColor(context)
                    : ColorResources.getGreyLightColor(context).withOpacity(0.05)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: FadeInImage.assetNetwork(
                placeholder: Images.placeholder(context),
                image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.categoryImageUrl}/$icon',
                fit: BoxFit.cover, width: 100, height: 100,
                imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 100, width: 100, fit: BoxFit.cover),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
            child: Text(title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: poppinsSemiBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraSmall,
                  color: isSelected ? Theme.of(context).canvasColor : Theme.of(context).textTheme.bodyLarge?.color
                )),
          ),
        ]),
      ),
    );
  }
}

class SubCategoriesShimmer extends StatelessWidget {
  const SubCategoriesShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (BuildContext context, int index) {
        return Shimmer(
          duration: const Duration(seconds: 2),
          enabled: Provider.of<CategoryProvider>(context).subCategoryList == null,
          child: Container(
            height: 40,
            margin: const EdgeInsets.only(left: 15, right: 15, top: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
          ),
        );
      },
    );
  }
}
