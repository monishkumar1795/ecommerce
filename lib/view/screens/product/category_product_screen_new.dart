
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/category_model.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/coupon_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/product_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/base/web_product_shimmer.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
class CategoryProductScreenNew extends StatefulWidget {
  final CategoryModel categoryModel;
  final String? subCategoryName;
   const CategoryProductScreenNew({Key? key,required this.categoryModel, this.subCategoryName}) : super(key: key);

  @override
  State<CategoryProductScreenNew> createState() => _CategoryProductScreenNewState();
}

class _CategoryProductScreenNewState extends State<CategoryProductScreenNew> {

  void _loadData(BuildContext context) async {

    if (Provider.of<CategoryProvider>(context, listen: false).categorieselectedIndex == -1) {

     Provider.of<CategoryProvider>(context, listen: false).getCategory(widget.categoryModel.id, context);

     Provider.of<CategoryProvider>(context, listen: false).getSubCategoryList(context, widget.categoryModel.id.toString(),
         Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode);
     Provider.of<ProductProvider>(context, listen: false).initCategoryProductList(
       widget.categoryModel.id.toString(), context, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
     );

     // Provider.of<CategoryProvider>(context, listen: false).changeSelectedIndex(-1,notify: false);
    }
  }

  @override
  void initState() {
    _loadData(context);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    String? appBarText = 'Sub Categories';
    if(widget.subCategoryName != null && widget.subCategoryName != 'null') {
      appBarText = widget.subCategoryName;
    }else{
      appBarText =
      Provider.of<CategoryProvider>(context).categoryModel != null
          ? Provider.of<CategoryProvider>(context).categoryModel!.name! : 'name';
    }
    Provider.of<ProductProvider>(context, listen: false).initializeAllSortBy(context);
    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar())
      : CustomAppBar(
        title: appBarText,
        isCenter: false, isElevation: true,fromcategoriescreen: true,
      )) as PreferredSizeWidget?,
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          return Column(
            crossAxisAlignment: ResponsiveHelper.isDesktop(context)? CrossAxisAlignment.center : CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70,width: 1170,child: Consumer<CategoryProvider>(
                  builder: (context, categoryProvider, child){
                    return categoryProvider.subCategoryList != null ? Container(
                      margin: const EdgeInsets.symmetric(vertical: 15),
                      height: 32,
                      child: SizedBox(
                        width: ResponsiveHelper.isDesktop(context)? 1170 : MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                                  child: InkWell(
                                    onTap: (){
                                      categoryProvider.changeSelectedIndex(-1);
                                      Provider.of<ProductProvider>(context, listen: false).initCategoryProductList(
                                        widget.categoryModel.id.toString(), context, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
                                      );
                                    },
                                    hoverColor: Colors.transparent,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                      decoration: BoxDecoration(
                                          color: categoryProvider.categorieselectedIndex == -1 ? Theme.of(context).primaryColor : ColorResources.getGreyColor(context),
                                          borderRadius: BorderRadius.circular(7)),
                                      child: Text(
                                        getTranslated('all', context)!,
                                        style: poppinsRegular.copyWith(
                                          color: categoryProvider.categorieselectedIndex == -1 ? Theme.of(context).canvasColor : Colors.black ,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: categoryProvider.subCategoryList!.length ,
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemBuilder: (BuildContext context, int index){
                                      return InkWell(
                                        onTap: (){
                                          categoryProvider.changeSelectedIndex(index);

                                          Provider.of<ProductProvider>(context, listen: false).initCategoryProductList(
                                            categoryProvider.subCategoryList![index].id.toString(), context,
                                            Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
                                          );

                                        },
                                        hoverColor: Colors.transparent,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                          decoration: BoxDecoration(
                                              color: categoryProvider.categorieselectedIndex == index ? Theme.of(context).primaryColor : ColorResources.getGreyColor(context),
                                              borderRadius: BorderRadius.circular(7)),
                                          child: Text(
                                            categoryProvider.subCategoryList![index].name!,
                                            style: poppinsRegular.copyWith(
                                              color:  categoryProvider.categorieselectedIndex == index ? Theme.of(context).canvasColor : Colors.black,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                              ])),
                            ),
                           // if(ResponsiveHelper.isDesktop(context)) Spacer(),
                            if(ResponsiveHelper.isDesktop(context)) PopupMenuButton(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                elevation: 20,
                                enabled: true,
                                icon: const Icon(Icons.more_vert,color: Colors.black,),
                                onSelected: (dynamic value) {
                                  int index = Provider.of<ProductProvider>(context,listen: false).allSortBy.indexOf(value);

                                  Provider.of<ProductProvider>(context,listen: false).sortCategoryProduct(index);
                                },

                                itemBuilder:(context) {
                                  return Provider.of<ProductProvider>(context,listen: false).allSortBy.map((choice) {
                                    return PopupMenuItem(
                                      value: choice,
                                      child: Text("$choice"),
                                    );
                                  }).toList();
                                }
                            )
                          ],
                        ),
                      ),
                    ) : const SubcategoryTitleShimmer();
                  }),),
              Expanded(child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    productProvider.categoryProductList.isNotEmpty ?
                    Container(
                      width: 1170,
                      constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: ResponsiveHelper.isDesktop(context)? (1 / 1.1) : 3,
                          crossAxisCount: ResponsiveHelper.isDesktop(context)? 5 :ResponsiveHelper.isMobilePhone()?1:ResponsiveHelper.isTab(context)?2:1,
                          mainAxisSpacing: 13,
                          crossAxisSpacing: 13,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: Dimensions.paddingSizeSmall),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: productProvider.categoryProductList.length,
                        shrinkWrap: true,

                        itemBuilder: (BuildContext context, int index) {
                          return ProductWidget(product: productProvider.categoryProductList[index]);
                        },

                      ),
                    )  : Center(
                      child: SizedBox(
                        width: 1170,
                        child: productProvider.hasData!
                            ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                          child: ProductShimmer(isEnabled: Provider.of<ProductProvider>(context).categoryProductList.isEmpty),
                        )
                            : const NoDataScreen(isSearch: true),
                      ),
                    ),

                    ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),

                  ],


                ),
              )),

              _cartTile(context),

            ],
          );
        }
      ),
    );
  }

  Widget _cartTile(BuildContext context) {
    bool kmWiseCharge = Provider.of<SplashProvider>(context, listen: false).configModel!.deliveryManagement!.status ?? false;
    return Consumer<CartProvider>(
        builder: (context,cartProvider,_) {
          double? deliveryCharge = 0;
          (Provider.of<OrderProvider>(context).orderType == 'delivery' && !kmWiseCharge)
              ? deliveryCharge = Provider.of<SplashProvider>(context, listen: false).configModel!.deliveryCharge : deliveryCharge = 0;
          double itemPrice = 0;
          double discount = 0;
          double tax = 0;
          for (var cartModel in cartProvider.cartList) {
            itemPrice = itemPrice + (cartModel.price! * cartModel.quantity!);
            discount = discount + (cartModel.discount! * cartModel.quantity!);
            tax = tax + (cartModel.tax! * cartModel.quantity!);
          }
          double subTotal = itemPrice + tax;
          double total = subTotal - discount - Provider.of<CouponProvider>(context).discount! + deliveryCharge!;
        return (cartProvider.cartList.isNotEmpty && ResponsiveHelper.isMobile()) ? Container(
          width: 1170,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: InkWell(
            onTap: () {
              Navigator.pop(context);
              Provider.of<SplashProvider>(context, listen: false).setPageIndex(2);
            },

            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(12)
                ),
                child: Column(
                  children: [

                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(getTranslated('total_item', context)!,
                          style: poppinsMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color: Theme.of(context).cardColor,
                          )),

                      Text('${cartProvider.cartList.length} ${getTranslated('items', context)}',
                          style: poppinsMedium.copyWith(color: Theme.of(context).cardColor)),

                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(getTranslated('total_amount', context)!,
                          style: poppinsMedium.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                            color:Theme.of(context).cardColor,
                          )),

                      CustomDirectionality(child: Text(
                        PriceConverter.convertPrice(context, total),
                        style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).cardColor),
                      )),
                    ]),

                  ],
                ),
              ),
            ),
          ),
        ) : const SizedBox();
      }
    );
  }
}
class SubcategoryTitleShimmer extends StatelessWidget{
  const SubcategoryTitleShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: 20),
        itemCount: 5 ,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index){
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Shimmer(
              duration: const Duration(seconds: 2),
              enabled: true,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge, vertical: Dimensions.paddingSizeExtraSmall),
                alignment: Alignment.center,
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                    color:  Theme.of(context).textTheme.titleLarge!.color,
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                  height: 20, width: 60,
                  padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: ColorResources.getGreyColor(context),
                  ),
                ),
              ),
            ),
          );
        });
  }
}
class ProductShimmer extends StatelessWidget {
  final bool isEnabled;

  const ProductShimmer({Key? key, required this.isEnabled}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : 3,
        crossAxisCount: ResponsiveHelper.isDesktop(context)? 5 : ResponsiveHelper.isMobilePhone()?1:ResponsiveHelper.isTab(context)?2:1,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) => ResponsiveHelper.isDesktop(context)? const WebProductShimmer(isEnabled: true) : Container(
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
                border: Border.all(width: 2, color: Theme.of(context).textTheme.titleLarge!.color!),
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).textTheme.titleLarge!.color,
              ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(height: 15, width: MediaQuery.of(context).size.width, color: Theme.of(context).textTheme.titleLarge!.color),
                  const SizedBox(height: 2),
                  Container(height: 15, width: MediaQuery.of(context).size.width, color: Theme.of(context).textTheme.titleLarge!.color),
                  const SizedBox(height: 10),
                  Container(height: 10, width: 50, color: Theme.of(context).textTheme.titleLarge!.color),
                ]),
              ),
            ),

            Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(height: 15, width: 50, color: Theme.of(context).textTheme.titleLarge!.color),
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
      ),
      itemCount: 20,
    );
  }
}
