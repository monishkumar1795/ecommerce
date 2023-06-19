import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../provider/theme_provider.dart';

class Images {
  // SVG
  static const String moreIcon = 'assets/image/more_icon.png';
  static const String englandFlag = 'assets/image/england.png';
  static const String maintenance = 'assets/image/maintenance.png';
  static const String chat = 'assets/image/chat.png';
  static const String language = 'assets/image/language.png';
  static const String privacyPolicy = 'assets/image/privacy_policy.png';
  static const String coupon = 'assets/image/coupon.png';
  static const String home = 'assets/image/home.png';
  static const String list = 'assets/image/list.png';
  static const String location = 'assets/image/location.png';
  static const String logOut = 'assets/image/log_out.png';
  static const String orderBag = 'assets/image/order_bag.png';
  static const String box = 'assets/image/box.png';
  static const String notFound = 'assets/image/not_found.png';
  static const String shoppingCart = 'assets/image/shopping_cart.png';
  static const String settings = 'assets/image/settings.png';
  static const String orderList = 'assets/image/order_list.png';
  static const String orderPlaced = 'assets/image/order_placed.png';
  static const String aboutUs = 'assets/image/about_us.png';
  static const String privacy = 'assets/image/privacy.png';
  static const String lock = 'assets/image/lock.png';
  static const String grofreshText = 'assets/image/GroFresh.png';
  static const String search = 'assets/image/search.png';
  static const String profile = 'assets/image/profile.png';
  static const String notification = 'assets/image/notification.png';
  static const String shoppingCartBold = 'assets/image/cart_bold.png';
  static const String termsAndConditions = 'assets/image/terms_and_conditions.png';
  static const String login = 'assets/image/login.png';
  static const String close = 'assets/image/clear.png';
  static const String arabicFlag = 'assets/image/arabic.png';
  static const String support = 'assets/image/support.png';
  static const String profilePlaceholder = 'assets/image/pro_place_holder.png';
  static const String google = 'assets/image/google.png';
  static const String faq = 'assets/image/faq.png';
  static const String translateLogo = 'assets/image/translate_logo.png';
  static const String loyaltyIcon = 'assets/image/loyalty_icon.png';
  static const String referralIcon = 'assets/image/referral_icon.png';
  static const String earningImage = 'assets/image/earning.png';
  static const String convertedImage = 'assets/image/converted.png';
  static const String loyal = 'assets/image/loyal.png';
  static const String returnPolicy = 'assets/image/return_policy.png';
  static const String refundPolicy = 'assets/image/refund_policy.png';
  static const String cancellationPolicy = 'assets/image/cancellation_policy.png';
  static const String whatsapp = 'assets/image/whatsapp.png';
  static const String telegram = 'assets/image/telegram.png';
  static const String messenger = 'assets/image/messenger.png';
  static const String favouriteIcon = 'assets/image/favourite_icon.png';
  static const String gifBoxDark = 'assets/image/gift_box_dark.gif';
  static const String gifBox = 'assets/image/giftbox.gif';
  static const String loyaltyBackground = 'assets/image/loyalty_background.png';
  static const String walletBackground = 'assets/image/wallet_background.png';







  // Image
  static const String appLogo = 'assets/image/app_logo.png';
  static const String onBoarding1 = 'assets/image/on_boarding_1.png';
  static const String onBoarding2 = 'assets/image/on_boarding_2.png';
  static const String onBoarding3 = 'assets/image/on_boarding_3.png';
  static const String closeLock = 'assets/image/close_lock.png';
  static const String openLock = 'assets/image/open_lock.png';
  static const String emailWithBackground = 'assets/image/email_with_background.png';
  static const String cartIcon = 'assets/image/cart.png';
  static const String couponBg = 'assets/image/coupon_bg.png';
  static const String percentage = 'assets/image/percentage.png';
  static const String line = 'assets/image/line.png';
  static const String call = 'assets/image/call.png';
  static const String placeholderLight = 'assets/image/placeholder.jpg';
  static const String placeholderDark = 'assets/image/placeholder.jpeg';
  static String placeholder(BuildContext context) {
    return Provider.of<ThemeProvider>(context).darkTheme ? placeholderDark : placeholderLight;
  }
  static const String update = 'assets/image/update.png';

  static const String camera = 'assets/image/camera.png';
  static const String mapMarker = 'assets/image/marker.png';
  static const String restaurantMarker = 'assets/image/restaurant_marker.png';
  static const String deliveryBoyMarker = 'assets/image/delivery_boy_marker.png';
  static const String destinationMarker = 'assets/image/destination_marker.png';
  static const String unselectedRestaurantMarker = 'assets/image/unselected_restaurant_marker.png';
  static const String wallet = 'assets/image/wallet.png';
  static const String facebook = 'assets/image/facebook.png';
  static const String twitter = 'assets/image/twitter.png';
  static const String youtube = 'assets/image/youtube.png';
  static const String playStore = 'assets/image/play_store.png';
  static const String appStore = 'assets/image/app_store.png';
  static const String send = 'assets/image/send.png';
  static const String image = 'assets/image/image.png';
  static const String linkedInIcon = 'assets/image/linkedin_icon.png';
  static const String inStaGramIcon = 'assets/image/instagram_icon.png';
  static const String pinterest = 'assets/image/pinterest.png';
  static const String referBanner = 'assets/image/refer_banner.png';
  static const String iMark = 'assets/image/i_mark.png';
  static const String flashDeal = 'assets/image/flash_deal.png';


  static String getShareIcon(String name) => 'assets/image/$name.png';
  static String getPaymentImage(String name) => 'assets/payment/$name.png';


}
