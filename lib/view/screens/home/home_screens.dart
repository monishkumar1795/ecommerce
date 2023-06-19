import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/banner_provider.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/flash_deal_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/wishlist_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/title_row.dart';
import 'package:flutter_grocery/view/base/title_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/home/widget/banners_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/category_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/home_item_view.dart';
import 'package:flutter_grocery/view/screens/home/widget/product_view.dart';
import 'package:flutter_grocery/view/screens/home_items_screen/widget/flash_deals_view.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  static Future<void> loadData(bool reload, BuildContext context) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final flashDealProvider = Provider.of<FlashDealProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final withLListProvider = Provider.of<WishListProvider>(context, listen: false);
    final localizationProvider = Provider.of<LocalizationProvider>(context, listen: false);

    ConfigModel config = Provider.of<SplashProvider>(context, listen: false).configModel!;
    if(reload) {
      Provider.of<SplashProvider>(context, listen: false).initConfig();
    }
    Provider.of<CategoryProvider>(context, listen: false).getCategoryList(
      context, localizationProvider.locale.languageCode, reload,
    );

    Provider.of<BannerProvider>(context, listen: false).getBannerList(context, reload);

    await Provider.of<ProductProvider>(context, listen: false).getItemList(
    '1', true, localizationProvider.locale.languageCode,
      ProductType.dailyItem,
    );

    if(config.mostReviewedProductStatus!) {
      await productProvider.getItemList(
       '1', true, localizationProvider.locale.languageCode,
        ProductType.mostReviewed,
      );
    }

    if(config.featuredProductStatus!) {
      await productProvider.getItemList(
        '1', true, localizationProvider.locale.languageCode,
        ProductType.featuredItem,
      );
    }
    if(config.trendingProductStatus!) {
      await productProvider.getItemList(
        '1', true, localizationProvider.locale.languageCode,
        ProductType.trendingProduct,
      );
    }

    if(config.recommendedProductStatus!) {
      await productProvider.getItemList('1', true, localizationProvider.locale.languageCode,
        ProductType.recommendProduct,
      );
    }

    await productProvider.getItemList(
      '1', true, localizationProvider.locale.languageCode,
      ProductType.popularProduct,
    );

    await productProvider.getLatestProductList('1', true);
    if(authProvider.isLoggedIn()) {
      await withLListProvider.getWishList();
    }

    if(config.flashDealProductStatus!) {
      await flashDealProvider.getFlashDealList(true, false);
    }

  }
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final ScrollController scrollController = ScrollController();

    return Consumer<SplashProvider>(builder: (context, splashProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            Provider.of<ProductProvider>(context, listen: false).offset = 1;
            Provider.of<ProductProvider>(context, listen: false).popularOffset = 1;
            await HomeScreen.loadData(true, context);
          },
          backgroundColor: Theme.of(context).primaryColor,
          child: Scaffold(
            appBar: ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar())  : null,
            body: SingleChildScrollView(
              controller: scrollController,
              child: Column(children: [
                Center(child: SizedBox(
                  width: 1170,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: ResponsiveHelper.isDesktop(context)
                          ? MediaQuery.of(context).size.height - 400
                          : MediaQuery.of(context).size.height,
                    ),
                    child: Column(
                        children: [

                          Consumer<BannerProvider>(builder: (context, banner, child) {
                            return banner.bannerList == null ? const BannersView() : banner.bannerList!.isEmpty ? const SizedBox() : const BannersView();
                          }),

                          // Category
                          Consumer<CategoryProvider>(builder: (context, category, child) {
                            return category.categoryList == null ? const CategoryView() : category.categoryList!.isEmpty ? const SizedBox() : const CategoryView();
                          }),

                          // Category
                          SizedBox(height: ResponsiveHelper.isDesktop(context) ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall),

                          if(splashProvider.configModel!.flashDealProductStatus!)
                            Consumer<FlashDealProvider>(builder: (context, flashDealProvider, child) {
                              return  flashDealProvider.flashDealList != null
                                  && flashDealProvider.flashDealList!.isEmpty
                                  ? const SizedBox() :
                              Column(children: [
                                TitleRow(
                                  isDetailsPage: false,
                                  title: getTranslated('flash_deal', context),
                                  eventDuration: flashDealProvider.flashDeal != null
                                      ? flashDealProvider.duration : null,
                                  onTap: () => Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.flashSale)),

                                ),
                                const SizedBox(height: Dimensions.paddingSizeDefault),

                                !ResponsiveHelper.isDesktop(context) ?
                                SizedBox(
                                  height: MediaQuery.of(context).size.width *.77,
                                  child: const Padding(
                                    padding: EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                                    child: FlashDealsView(isHomeScreen: true),
                                  ),
                                ) : HomeItemView(productList: flashDealProvider.flashDealList)



                              ]);
                            }
                            ),



                          TitleWidget(title: getTranslated('daily_needs', context) ,onTap: () {
                            Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.dailyItem));
                          }),

                          Consumer<ProductProvider>(builder: (context, productProvider, child) {
                            return productProvider.dailyItemList == null ? HomeItemView(productList: productProvider.dailyItemList) : productProvider.dailyItemList!.isEmpty
                                ? const SizedBox() : HomeItemView(productList: productProvider.dailyItemList);
                          }),

                          if(splashProvider.configModel!.featuredProductStatus!) Column(children: [
                            TitleWidget(title: getTranslated(ProductType.featuredItem, context) ,onTap: () {
                              Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.featuredItem));
                            }),

                            Consumer<ProductProvider>(builder: (context, productProvider, child) {
                              return productProvider.featuredProductList == null
                                  ? HomeItemView(productList: productProvider.featuredProductList)
                                  : productProvider.featuredProductList!.isEmpty ? const SizedBox()
                                  : HomeItemView(productList: productProvider.featuredProductList);
                            }),
                          ]),

                          if(splashProvider.configModel!.mostReviewedProductStatus!) Column(children: [
                            TitleWidget(title: getTranslated(ProductType.mostReviewed, context) ,onTap: () {
                              Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.mostReviewed));
                            }),

                            Consumer<ProductProvider>(builder: (context, productProvider, child) {
                              return productProvider.mostViewedProductList == null
                                  ? HomeItemView(productList: productProvider.mostViewedProductList)
                                  : productProvider.mostViewedProductList!.isEmpty ? const SizedBox()
                                  : HomeItemView(productList: productProvider.mostViewedProductList);
                            }),
                          ]),

                          if(splashProvider.configModel!.trendingProductStatus!) Column(children: [
                            TitleWidget(title: getTranslated(ProductType.trendingProduct, context) ,onTap: () {
                              Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.trendingProduct));
                            }),

                            Consumer<ProductProvider>(builder: (context, productProvider, child) {
                              return productProvider.trendingProduct == null
                                  ? HomeItemView(productList: productProvider.trendingProduct)
                                  : productProvider.trendingProduct!.isEmpty ? const SizedBox()
                                  : HomeItemView(productList: productProvider.trendingProduct);
                            }),

                          ]),


                          if(splashProvider.configModel!.recommendedProductStatus!) Column(children: [
                            TitleWidget(title: getTranslated(ProductType.recommendProduct, context) ,onTap: () {
                              Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.recommendProduct));
                            }),

                            Consumer<ProductProvider>(builder: (context, productProvider, child) {
                              return productProvider.recommendProduct == null
                                  ? HomeItemView(productList: productProvider.recommendProduct)
                                  : productProvider.recommendProduct!.isEmpty ? const SizedBox()
                                  : HomeItemView(productList: productProvider.recommendProduct);
                            }),

                          ]),


                          TitleWidget(title: getTranslated(ProductType.popularProduct, context) ,onTap: () {
                            Navigator.pushNamed(context, RouteHelper.getHomeItemRoute(ProductType.popularProduct));
                          }),

                          Consumer<ProductProvider>(builder: (context, productProvider, child) {
                            return productProvider.latestProductList == null ? HomeItemView(productList: productProvider.latestProductList) : productProvider.latestProductList!.isEmpty
                                ? const SizedBox() : HomeItemView(productList: productProvider.latestProductList);
                          }),


                          ResponsiveHelper.isMobilePhone() ? const SizedBox(height: 10) : const SizedBox.shrink(),
                          TitleWidget(title: getTranslated('latest_items', context)),
                          ProductView(scrollController: scrollController),


                        ]),
                  ),
                )),

                ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),

              ]),
            ),
          ),
        );
      }
    );
  }
}
