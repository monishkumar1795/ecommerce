
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/app_bar_base.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/order/widget/order_button.dart';
import 'package:flutter_grocery/view/screens/order/widget/order_view.dart';
import 'package:provider/provider.dart';

class MyOrderScreen extends StatelessWidget {
  const MyOrderScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(isLoggedIn) {
      Provider.of<OrderProvider>(context, listen: false).getOrderList(context);
    }
    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone()
          ? null: (ResponsiveHelper.isDesktop(context)
          ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar())
          : const AppBarBase()) as PreferredSizeWidget?,

      body: SafeArea(
        child: isLoggedIn ? Scrollbar(
          child: Center(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child)
              => orderProvider.runningOrderList != null ? Column(
                children: [
                  SizedBox(
                    width: 1170,
                    child: Padding(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          OrderButton(title: 'active'.tr, isActive: true),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                          OrderButton(title: 'past_order'.tr, isActive: false),
                        ],
                      ),
                    ),
                  ),

                  Expanded(child: OrderView(isRunning: orderProvider.isActiveOrder ? true : false))
                ],
              ) : Center(child: CustomLoader(color: Theme.of(context).primaryColor)),
            ),
          ),
        ) : const NotLoggedInScreen(),
      ),
    );
  }
}
// Provider.of<OrderProvider>(context, listen: false).runningOrderList != null ? ResponsiveHelper.isDesktop(context) ? FooterView() : SizedBox() : SizedBox(),




