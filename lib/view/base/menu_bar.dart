import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/view/base/mars_menu_bar.dart';
import 'package:provider/provider.dart';
class MenuBarWidget extends StatelessWidget {
  const MenuBarWidget({Key? key}) : super(key: key);

  List<MenuItems> getMenus(BuildContext context) {
    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    return [
      MenuItems(
        title: 'home'.tr,
        icon: Icons.home_filled,
       onTap: () => Navigator.pushNamed(context, RouteHelper.menu)
      ),
      MenuItems(
        title: 'all_categories'.tr,
        icon: Icons.category,
        onTap: () => Navigator.pushNamed(context, RouteHelper.categories),
      ),

      MenuItems(
        title: 'useful_links'.tr,
        icon: Icons.settings,
        children: [
          MenuItems(
            title: 'privacy_policy'.tr,
            onTap: () => Navigator.pushNamed(context, RouteHelper.getPolicyRoute()),
          ),
          MenuItems(
            title: 'terms_and_condition'.tr,
            onTap: () => Navigator.pushNamed(context, RouteHelper.getTermsRoute()),
          ),
          MenuItems(
            title: 'about_us'.tr,
            onTap: () => Navigator.pushNamed(context, RouteHelper.getAboutUsRoute()),
          ),

        ],
      ),


      MenuItems(
        title: 'search'.tr,
        icon: Icons.search,
        onTap: () =>  Navigator.pushNamed(context, RouteHelper.searchProduct),
      ),

      MenuItems(
        title: 'menu'.tr,
        icon: Icons.menu,
        onTap: () => Navigator.pushNamed(context, RouteHelper.profileMenus),
      ),


      isLoggedIn ?  MenuItems(
        title: 'profile'.tr,
        icon: Icons.person,
       onTap: () => Navigator.pushNamed(context, RouteHelper.profile),
      ):  MenuItems(
        title: 'login'.tr,
        icon: Icons.lock,
        onTap: () => Navigator.pushNamed(context, RouteHelper.login),
      ),
      MenuItems(
        title: '',
        icon: Icons.shopping_cart,
         onTap: () => Navigator.pushNamed(context, RouteHelper.cart),
      ),

    ];
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
    width: 800,
      child: PlutoMenuBarWidget(
        backgroundColor: Theme.of(context).cardColor,
        gradient: false,
        goBackButtonText: 'Back',
        textStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color),
        moreIconColor: Theme.of(context).textTheme.bodyLarge!.color,
        menuIconColor: Theme.of(context).textTheme.bodyLarge!.color,
        menus: getMenus(context),

      ),
    );
  }
}