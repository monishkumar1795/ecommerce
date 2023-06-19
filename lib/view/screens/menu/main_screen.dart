import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/html_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/profile_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/third_party_chat_widget.dart';
import 'package:flutter_grocery/view/screens/address/address_screen.dart';
import 'package:flutter_grocery/view/screens/cart/cart_screen.dart';
import 'package:flutter_grocery/view/screens/category/all_category_screen.dart';
import 'package:flutter_grocery/view/screens/chat/chat_screen.dart';
import 'package:flutter_grocery/view/screens/coupon/coupon_screen.dart';
import 'package:flutter_grocery/view/screens/home/home_screens.dart';
import 'package:flutter_grocery/view/screens/html/html_viewer_screen.dart';
import 'package:flutter_grocery/view/screens/menu/widget/custom_drawer.dart';
import 'package:flutter_grocery/view/screens/order/my_order_screen.dart';
import 'package:flutter_grocery/view/screens/refer_and_earn/refer_and_earn_screen.dart';
import 'package:flutter_grocery/view/screens/settings/setting_screen.dart';
import 'package:flutter_grocery/view/screens/wallet/wallet_screen.dart';
import 'package:flutter_grocery/view/screens/wishlist/wishlist_screen.dart';
import 'package:provider/provider.dart';




List<MainScreenModel> screenList = [
  MainScreenModel(const HomeScreen(), 'home', Images.home),
  MainScreenModel(const Allcategoriescreen(), 'all_categories', Images.list),
  MainScreenModel(const CartScreen(), 'shopping_bag', Images.orderBag),
  MainScreenModel(const WishListScreen(), 'favourite', Images.favouriteIcon),
  MainScreenModel(const MyOrderScreen(), 'my_order', Images.orderList),
  MainScreenModel(const AddressScreen(), 'address', Images.location),
  MainScreenModel(const CouponScreen(), 'coupon', Images.coupon),
  MainScreenModel(const ChatScreen(orderModel: null,), 'live_chat', Images.chat),
  MainScreenModel(const SettingsScreen(), 'settings', Images.settings),
  if(Provider.of<SplashProvider>(Get.context!, listen: false).configModel!.walletStatus!)
    MainScreenModel(const WalletScreen(fromWallet: true), 'wallet', Images.wallet),
  if(Provider.of<SplashProvider>(Get.context!, listen: false).configModel!.loyaltyPointStatus!)
    MainScreenModel(const WalletScreen(fromWallet: false), 'loyalty_point', Images.loyaltyIcon),
  MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.termsAndCondition), 'terms_and_condition', Images.termsAndConditions),
  MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.privacyPolicy), 'privacy_policy', Images.privacy),
  MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.aboutUs), 'about_us', Images.aboutUs),
  if(Provider.of<SplashProvider>(Get.context!, listen: false).configModel!.returnPolicyStatus!)
    MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.returnPolicy), 'return_policy', Images.returnPolicy),

  if(Provider.of<SplashProvider>(Get.context!, listen: false).configModel!.refundPolicyStatus!)
    MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.refundPolicy), 'refund_policy', Images.refundPolicy),

  if(Provider.of<SplashProvider>(Get.context!, listen: false).configModel!.cancellationPolicyStatus!)
    MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.cancellationPolicy), 'cancellation_policy', Images.cancellationPolicy),

  MainScreenModel(const HtmlViewerScreen(htmlType: HtmlType.faq), 'faq', Images.faq),
];


class MainScreen extends StatefulWidget {
  final CustomDrawerController drawerController;
  const MainScreen({Key? key, required this.drawerController}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  @override
  void initState() {
    HomeScreen.loadData(true, Get.context!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SplashProvider>(
      builder: (context, splash, child) {
        return WillPopScope(
          onWillPop: () async {
            if (splash.pageIndex != 0) {
              splash.setPageIndex(0);
              return false;
            } else {
              return true;
            }
          },
          child: Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                final referMenu = MainScreenModel(const ReferAndEarnScreen(), 'referAndEarn', Images.referralIcon);
                if(splash.configModel!.referEarnStatus!
                    && profileProvider.userInfoModel != null
                    && profileProvider.userInfoModel!.referCode != null
                    && screenList[9].title != 'referAndEarn'){
                  screenList.removeWhere((menu) => menu.screen == referMenu.screen);
                  screenList.insert(9, referMenu);

                }

              return Consumer<LocationProvider>(
                builder: (context, locationProvider, child) => Scaffold(
                  floatingActionButton: !ResponsiveHelper.isDesktop(context) ?  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 50.0),
                    child: ThirdPartyChatWidget(configModel: splash.configModel!,),
                  ) : null,
                  appBar: ResponsiveHelper.isDesktop(context) ? null : AppBar(
                    backgroundColor: Theme.of(context).cardColor,
                    leading: IconButton(
                        icon: Image.asset(Images.moreIcon, color: Theme.of(context).primaryColor, height: 30, width: 30),
                        onPressed: () {
                          widget.drawerController.toggle();
                        }),
                    title: splash.pageIndex == 0 ? Row(children: [
                      Image.asset(Images.appLogo, width: 25),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(child: Text(
                        AppConstants.appName, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor),
                      )),
                    ]) : Text(
                      getTranslated(screenList[splash.pageIndex].title, context)!,
                      style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
                    ),

                    actions: splash.pageIndex == 0 ? [
                      IconButton(
                          icon: Stack(clipBehavior: Clip.none, children: [
                            Image.asset(Images.cartIcon, color: Theme.of(context).textTheme.bodyLarge!.color, width: 25),
                            Positioned(
                              top: -7,
                              right: -2,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).primaryColor),
                                child: Text('${Provider.of<CartProvider>(context).cartList.length}',
                                    style: TextStyle(color: Theme.of(context).cardColor, fontSize: 10)),
                              ),
                            ),
                          ]),
                          onPressed: () {
                           ResponsiveHelper.isMobilePhone()? splash.setPageIndex(2): Navigator.pushNamed(context, RouteHelper.cart);
                          }),
                      IconButton(
                          icon: Icon(Icons.search, size: 30, color: Theme.of(context).textTheme.bodyLarge!.color),
                          onPressed: () {
                            Navigator.pushNamed(context, RouteHelper.searchProduct);
                          }),
                    ]
                        : splash.pageIndex == 2
                        ? [
                      Center(
                          child: Consumer<CartProvider>(
                            builder: (context, cartProvider, _) {
                              return Text('${cartProvider.cartList.length} ${getTranslated('items', context)}',
                                  style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor));
                            }
                          )),
                      const SizedBox(width: 20)
                    ] : null,
                  ),

                  body: screenList[splash.pageIndex].screen,
                ),
              );
            }
          ),
        );
      },
    );
  }
}

class MainScreenModel{
  final Widget screen;
  final String title;
  final String icon;
  MainScreenModel(this.screen, this.title, this.icon);
}