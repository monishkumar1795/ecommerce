
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/category_model.dart';
import 'package:flutter_grocery/data/model/response/language_model.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:flutter_grocery/provider/category_provider.dart';
import 'package:flutter_grocery/provider/language_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/search_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_dialog.dart';
import 'package:flutter_grocery/view/base/text_hover.dart';
import 'package:flutter_grocery/view/base/web_app_bar/widget/language_hover_widget.dart';
import 'package:flutter_grocery/view/screens/menu/widget/sign_out_confirmation_dialog.dart';
import 'package:flutter_grocery/view/screens/search/search_result_screen.dart';
import 'package:flutter_grocery/view/screens/settings/widget/currency_dialog.dart';
import 'package:provider/provider.dart';

import '../../screens/home/web/category_hover_widget.dart';
import '../custom_text_field.dart';

class WebAppBar extends StatefulWidget implements PreferredSizeWidget {
  const WebAppBar({Key? key}) : super(key: key);


  @override
  State<WebAppBar> createState() => _WebAppBarState();

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}

class _WebAppBarState extends State<WebAppBar> {
  String? chooseLanguage;
  
  List<PopupMenuEntry<Object>> popUpMenuList(BuildContext context) {
    List<PopupMenuEntry<Object>> list = <PopupMenuEntry<Object>>[];
    List<CategoryModel>? categoryList =  Provider.of<CategoryProvider>(context, listen: false).categoryList;
    list.add(
        PopupMenuItem(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          value: categoryList,
          child: MouseRegion(
            onExit: (_)=> Navigator.of(context).pop(),
            child: CategoryHoverWidget(categoryList: categoryList),
          ),
        ));
    return list;
  }

  List<PopupMenuEntry<Object>> popUpLanguageList(BuildContext context) {
    List<PopupMenuEntry<Object>> languagePopupMenuEntryList = <PopupMenuEntry<Object>>[];
    List<LanguageModel> languageList =  AppConstants.languages;
    languagePopupMenuEntryList.add(
        PopupMenuItem(
          padding: EdgeInsets.zero,
          value: languageList,
          child: MouseRegion(
            onExit: (_)=> Navigator.of(context).pop(),
            child: LanguageHoverWidget(languageList: languageList),
          ),
        ));
    return languagePopupMenuEntryList;
  }

  _showPopupMenu(Offset offset, BuildContext context, bool isCategory) async {
    double left = offset.dx;
    double top = offset.dy;
    final RenderBox overlay = Overlay
        .of(context)
        .context
        .findRenderObject() as RenderBox;
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          left, top, overlay.size.width, overlay.size.height),
      items: isCategory ? popUpMenuList(context) : popUpLanguageList(context),
      elevation: 8.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(12),
        ),
      ),

    );
  }

  @override
  void initState() {

    // _loadData(context, true);

    super.initState();
  }

    @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    Provider.of<LanguageProvider>(context, listen: false).initializeAllLanguages(context);
    LanguageModel currentLanguage = AppConstants.languages.firstWhere((language) => language.languageCode == Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode);
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 20,
            offset: const Offset(0,10),
          )
        ]
      ),
      child: Column(
        children: [
          Container(
            color: ColorResources.getAppBarHeaderColor(context),
            height: 45,
            child: Center(
              child: SizedBox( width: 1170,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                        child: Text('dark_mode'.tr, style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6), fontSize: Dimensions.paddingSizeDefault)),
                      ),
                      // StatusWidget(),
                      Transform.scale(
                        scale: 1,
                        child: Switch(
                          onChanged: (bool isActive) =>Provider.of<ThemeProvider>(context, listen: false).toggleTheme(),
                          value: Provider.of<ThemeProvider>(context).darkTheme,
                          activeColor: Colors.black26,
                          activeTrackColor: Colors.grey,
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Theme.of(context).primaryColor,

                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),

                      SizedBox(
                        height: Dimensions.paddingSizeLarge,

                        child: MouseRegion(
                          onHover: (details){
                            _showPopupMenu(details.position, context, false);
                          },
                          child: InkWell(
                            onTap: () => showAnimatedDialog(context, const CurrencyDialog()),
                            // onTap: () => Navigator.pushNamed(context, RouteHelper.getLanguageRoute('menu')),
                            child: Row(
                              children: [
                               Image.asset(Images.translateLogo, height: Dimensions.paddingSizeLarge, width: Dimensions.paddingSizeLarge),
                               const SizedBox(width: Dimensions.paddingSizeSmall),
                                Text('${currentLanguage.languageName}',style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))),
                                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                Icon(Icons.expand_more, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))
                              ],
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(width: Dimensions.paddingSizeExtraLarge),


                      isLoggedIn ? InkWell(
                        onTap: () => showDialog(context: context, barrierDismissible: false, builder: (context) => const SignOutConfirmationDialog()),
                        child: Row(children: [
                          Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                            child: Image.asset(Images.lock,height: 16,fit: BoxFit.contain, color: Theme.of(context).primaryColor),
                          ),

                          Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                            child: Text('log_out'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))),
                          ),

                        ],),
                      )
                          : InkWell(
                        onTap: () {
                            Navigator.pushNamed(context, RouteHelper.login);

                        },
                        child:  Row(children: [
                          Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                            child: Image.asset(Images.lock,height: 16,fit: BoxFit.contain, color: Theme.of(context).primaryColor),
                          ),
                          Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                            child: Text('login'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))),
                          ),
                        ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(color: Theme.of(context).cardColor,
              child: Center(
                child: SizedBox(
                    width: 1170,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(children: [
                          InkWell(
                            onTap: () {
                              Provider.of<ProductProvider>(context, listen: false).offset = 1;
                              if(ModalRoute.of(context)!.settings.name != RouteHelper.getMainRoute()) {
                                Navigator.pushNamed(context, RouteHelper.getMainRoute());
                              }
                            },
                            child: Row(
                              children: [
                                SizedBox(height: 50,
                                    child: Consumer<SplashProvider>(
                                      builder:(context, splash, child) => FadeInImage.assetNetwork(
                                        placeholder: Images.appLogo,
                                        image: splash.baseUrls != null ? '${splash.baseUrls!.ecommerceImageUrl}/${splash.configModel!.ecommerceLogo}' : '',fit: BoxFit.contain,
                                        imageErrorBuilder: (c,b,v)=> Image.asset(Images.appLogo),
                                      ),
                                    ) ),
                                const SizedBox(width: Dimensions.paddingSizeSmall),
                              ],
                            ),
                          ),

                          const SizedBox(width: 40),

                          TextHover(builder: (isHovered) {
                            return InkWell(
                              onTap: () {
                                Provider.of<ProductProvider>(context, listen: false).offset = 1;
                                if(ModalRoute.of(context)!.settings.name != RouteHelper.getMainRoute()) {
                                  Navigator.pushNamed(context, RouteHelper.getMainRoute());
                                }
                              },
                              child: Text('home'.tr, style: isHovered ?
                              poppinsSemiBold.copyWith(color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeLarge) :
                              poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                                  fontSize: Dimensions.fontSizeLarge)),
                            );
                          }),
                          const SizedBox(width: 40),



                          TextHover(
                            builder: (isHovered) {
                              return MouseRegion(onHover: (details){
                                if(Provider.of<CategoryProvider>(context, listen: false).categoryList != null){
                                  _showPopupMenu(details.position, context,true);
                                }

                              },
                                child: Text('categories'.tr,
                                    style: isHovered ? poppinsSemiBold.copyWith(color: Theme.of(context).primaryColor,
                                        fontSize: Dimensions.fontSizeLarge) :
                                    poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                                        fontSize: Dimensions.fontSizeLarge)
                                ),);
                            },),
                          const SizedBox(width: 40),


                          TextHover(
                              builder: (isHovered) {
                                return InkWell(
                                    onTap: () => Navigator.pushNamed(context, RouteHelper.favorite),
                                    child: SizedBox(
                                      width: 120,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                        child: Text('favourite'.tr, maxLines: 1,overflow: TextOverflow.ellipsis,
                                            style: isHovered ? poppinsSemiBold.copyWith(color: Theme.of(context).primaryColor,
                                                fontSize: Dimensions.fontSizeLarge) :
                                            poppinsMedium.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                                                fontSize: Dimensions.fontSizeLarge)
                                        ),
                                      ),
                                    ));
                              }
                          ),
                        ],),





                        Row(children: [
                          Container(
                            width: 400,
                            decoration: BoxDecoration(
                              color: ColorResources.getGreyColor(context),
                              borderRadius: BorderRadius.circular(Dimensions.radiusSizeDefault),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 0,vertical: 2),
                            child: Consumer<SearchProvider>(
                                builder: (context,search,_) {
                                  return CustomTextField(
                                    hintText: 'searchItem_here'.tr,
                                    isShowBorder: false,
                                    fillColor: Colors.transparent,
                                    isElevation: false,
                                    isShowSuffixIcon: true,
                                    suffixAssetUrl: !search.isSearch ? Images.close : Images.search,
                                    onChanged: (str){
                                      str.length = 0;
                                      search.getSearchText(str);
                                      },

                                    onSuffixTap: () {
                                      if(search.searchController.text.isNotEmpty && search.isSearch == true){

                                        Navigator.pushNamed(context, RouteHelper.getSearchResultRoute(search.searchController.text),
                                            arguments: SearchResultScreen(searchString: search.searchController.text));
                                        search.searchDone();
                                      }
                                      else if (search.searchController.text.isNotEmpty && search.isSearch == false) {
                                        search.searchController.clear();
                                        search.getSearchText('');
                                        search.searchDone();
                                      }
                                    },
                                    controller: search.searchController,
                                    inputAction: TextInputAction.search,
                                    isIcon: true,
                                    onSubmit: (text) {
                                      if (search.searchController.text.isNotEmpty) {

                                        Navigator.pushNamed(context, RouteHelper.getSearchResultRoute(search.searchController.text));

                                        search.searchDone();
                                      }

                                    },);
                                }
                            ),
                          ),
                          const SizedBox(width: 40),

                          InkWell(
                            onTap: (){
                              Navigator.pushNamed(context, RouteHelper.cart);
                            },
                            child: SizedBox(
                              child: Stack(
                                clipBehavior: Clip.none, children: [
                                SizedBox(
                                    height: 30,width: 30,
                                    child: Image.asset(Images.shoppingCartBold,color: Theme.of(context).primaryColor)
                                ),
                                Positioned(
                                    top: -10,
                                    right: -10,
                                    child: int.parse(Provider.of<CartProvider>(context).cartList.length.toString()) <=0 ? const SizedBox() : Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                      child: Text('${Provider.of<CartProvider>(context).cartList.length}',style: poppinsRegular.copyWith(color: Colors.white,fontSize: Dimensions.fontSizeSmall)),
                                    )),
                              ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),

                          IconButton(onPressed: () => Navigator.pushNamed(context, RouteHelper.profileMenus),
                              icon: Icon(Icons.menu,size: Dimensions.fontSizeOverLarge, color: Theme.of(context).primaryColor)),
                          const SizedBox(width: Dimensions.paddingSizeSmall)
                        ],)



                      ],
                    )
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Size get preferredSize => const Size(double.maxFinite, 160);
}

