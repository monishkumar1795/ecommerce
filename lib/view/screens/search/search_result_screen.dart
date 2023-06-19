import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/search_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/product_shimmer.dart';
import 'package:flutter_grocery/view/base/product_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/base/web_product_shimmer.dart';
import 'package:flutter_grocery/view/screens/search/widget/filter_widget.dart';
import 'package:provider/provider.dart';

class SearchResultScreen extends StatefulWidget {
  final String? searchString;

  const SearchResultScreen({Key? key, this.searchString}) : super(key: key);

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {

  @override
  void initState() {
    Provider.of<SearchProvider>(context, listen: false).initHistoryList();
    Provider.of<SearchProvider>(context, listen: false).initializeAllSortBy(notify: false);
    Provider.of<SearchProvider>(context,listen: false).saveSearchAddress(widget.searchString, isUpdate: false);
    Provider.of<SearchProvider>(context,listen: false).searchProduct(widget.searchString!, context, isUpdate: false);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()) : null,
      body: SafeArea(child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
          child: Consumer<SearchProvider>(
            builder: (context, searchProvider, child) => SingleChildScrollView(
              child: Column(children: [
                Center(child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: ResponsiveHelper.isDesktop(context)
                        ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height,
                  ),
                  child: SizedBox(width: 1170, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 15),

                      !ResponsiveHelper.isDesktop(context)
                          ? Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 700 : 200]!,
                              spreadRadius: 0.5,
                              blurRadius: 0.5,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.searchString!,
                              style: poppinsLight.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6), fontSize: Dimensions.paddingSizeLarge),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: const Icon(Icons.close, color: Colors.red, size: 22),
                            )
                          ],
                        ),
                      )
                          : const SizedBox(),
                      const SizedBox(height: 13),

                      Container(
                        height: 48,
                        margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 700 : 200]!,
                              spreadRadius: 0.5,
                              blurRadius: 0.5,
                              offset: const Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                searchProvider.searchProductList!=null?
                                Text(
                                  "${searchProvider.searchProductList!.length}",
                                  style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor),
                                ):const SizedBox.shrink(),
                                Text(
                                  '${searchProvider.searchProductList!=null?"":0} ${getTranslated('items_found', context)}',
                                  style: poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                                )
                              ],
                            ),
                            searchProvider.searchProductList != null
                                ? InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      List<double?> prices = [];
                                      for (var product in searchProvider.filterProductList!) {
                                        prices.add(product.price);
                                      }
                                      prices.sort();
                                      double? maxValue = prices.isNotEmpty ? prices[prices.length-1] : 1000;

                                      return Dialog(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
                                        child: FilterWidget(maxValue: maxValue),
                                      );
                                    });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    border: Border.all(color: Theme.of(context).hintColor.withOpacity(0.6).withOpacity(.5))),
                                child: Row(
                                  children: [
                                    Icon(Icons.filter_list, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                                    Text(
                                      '  ${getTranslated('filter', context)}',
                                      style:
                                      poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6), fontSize: Dimensions.fontSizeSmall),
                                    )
                                  ],
                                ),
                              ),
                            )
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      searchProvider.searchProductList != null ? searchProvider.searchProductList!.isNotEmpty ?
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                            mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                            childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : 2.8,
                            crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 1),
                        itemCount: searchProvider.searchProductList!.length,
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : 0.0),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) => ProductWidget(
                          product: searchProvider.searchProductList![index],
                          productType: ProductType.searchItem,
                        ),

                      ) : const NoDataScreen(isSearch: true) :
                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                          mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                          childAspectRatio: ResponsiveHelper.isDesktop(context) ? (1/1.4) : 4,
                          crossAxisCount: ResponsiveHelper.isDesktop(context) ? 5 : ResponsiveHelper.isTab(context) ? 2 : 1,
                        ),
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 10,
                        itemBuilder: (context, index) => ResponsiveHelper.isDesktop(context)
                            ?  WebProductShimmer(isEnabled: searchProvider.searchProductList == null)
                            : ProductShimmer(isEnabled: searchProvider.searchProductList == null),
                      ),
                    ],
                  )),
                )),

                ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),
              ]),
            ),
          )),
      ),
    );
  }
}
