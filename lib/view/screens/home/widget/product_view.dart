import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/product_shimmer.dart';
import 'package:flutter_grocery/view/base/product_widget.dart';
import 'package:flutter_grocery/view/base/web_product_shimmer.dart';
import 'package:provider/provider.dart';

class ProductView extends StatefulWidget {
  final ScrollController? scrollController;
  const ProductView({Key? key, this.scrollController}) : super(key: key);

  @override
  State<ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {

  int? pageSize;

  @override
  void initState() {
    Provider.of<ProductProvider>(context, listen: false).getLatestProductList( '1', true);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final ProductProvider productProvider = Provider.of<ProductProvider>(context, listen: false);

    void seeMoreItems(){
      pageSize = (Provider.of<ProductProvider>(context, listen: false).latestPageSize! / 10).ceil();

      if (productProvider.offset < pageSize!) {
        productProvider.offset++;
        productProvider.showBottomLoader();
        productProvider.getLatestProductList( productProvider.offset.toString(), false);
      }
    }


     if(!ResponsiveHelper.isDesktop(context)) {
        if(widget.scrollController!.hasClients) {
          widget.scrollController?.addListener(() {
            if (widget.scrollController!.position.maxScrollExtent ==
                widget.scrollController!.position.pixels
                && productProvider
                    .latestProductList != null
                && !Provider
                    .of<ProductProvider>(context, listen: false)
                    .isLoading) {
              pageSize = (productProvider.latestPageSize! / 10).ceil();
              if (productProvider.offset < pageSize!) {
                productProvider.offset++;
                productProvider.showBottomLoader();
                productProvider.getLatestProductList(productProvider.offset.toString(), false);
              }
            }
          });
        }
     }
    return Consumer<ProductProvider>(
      builder: (context, prodProvider, child) {
        List<Product>? productList;
        productList = prodProvider.latestProductList;

        return Column(children: [

          productList != null
              ? productList.isNotEmpty
              ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                        mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                        childAspectRatio:ResponsiveHelper.isDesktop(context) ? (1/1.4) : 3.0,
                        crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 1),
                    itemCount: productList.length,
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: Dimensions.paddingSizeLarge),
                    // padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (BuildContext context, int index) {
                      return ProductWidget(product: productList![index], productType: ProductType.latestProduct,);
                    },
                  )
              : const NoDataScreen(isSearch: true)
              : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                    mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                    childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : 4,
                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 1),
                itemCount: 10,
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  return ResponsiveHelper.isDesktop(context)
                      ?  WebProductShimmer(isEnabled: productList == null)
                      : ProductShimmer(isEnabled: productList == null);
                },
            ),

          Padding(
            padding: ResponsiveHelper.isDesktop(context)? const EdgeInsets.only(top: 40,bottom: 70) :  const EdgeInsets.all(0),
            child: ResponsiveHelper.isDesktop(context)?
            prodProvider.isLoading ?
                Center(child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: CustomLoader(color: Theme.of(context).primaryColor),
                ))
                :(productProvider.offset == pageSize) ? const SizedBox() : SizedBox(
                  width: 500,
                  child: ElevatedButton(
                      style : ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                      onPressed: (){
                        seeMoreItems();
                      },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(getTranslated('see_more', context)!, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeOverLarge)),
                    ),
                  ),

                )
                :prodProvider.isLoading ? Center(child: Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    child: CustomLoader(color: Theme.of(context).primaryColor),
                  )) : const SizedBox.shrink(),
          ),



        ]);
      },
    );
  }
}
