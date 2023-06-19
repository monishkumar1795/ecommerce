import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/address_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/app_bar_base.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/screens/address/widget/adress_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:provider/provider.dart';
import 'add_new_address_screen.dart';


class AddressScreen extends StatefulWidget {

  final AddressModel? addressModel;
  const AddressScreen({Key? key, this.addressModel}) : super(key: key);

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late bool _isLoggedIn;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(_isLoggedIn) {
      Provider.of<LocationProvider>(context, listen: false).initAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ResponsiveHelper.isMobilePhone()? null: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()) : const AppBarBase()) as PreferredSizeWidget?,
        body: _isLoggedIn ? Consumer<LocationProvider>(
          builder: (context, locationProvider, child) {
            return RefreshIndicator(
              onRefresh: () async {
                await Provider.of<LocationProvider>(context, listen: false).initAddressList();
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 560 : MediaQuery.of(context).size.height),
                  child: Column( mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 1170,
                          padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          margin: EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 20 : 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              Text(
                                getTranslated('saved_address', context)!,
                                style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                              ),
                              InkWell(
                               // onTap:() =>  Navigator.pushNamed(context, RouteHelper.getAddAddressRoute('address', 'add', AddressModel())),
                                 onTap:() {Provider.of<LocationProvider>(context, listen: false).updateAddressStatusMessage(message: '');
                                  Navigator.of(context).pushNamed(RouteHelper.getAddAddressRoute('address', 'add', AddressModel()), arguments: const AddNewAddressScreen());
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                                  decoration: BoxDecoration(
                                    color: ResponsiveHelper.isDesktop(context)? Theme.of(context).primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),

                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.add, color: ResponsiveHelper.isDesktop(context)? Colors.white : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                                      Text(
                                        getTranslated('add_new', context)!,
                                        style: poppinsRegular.copyWith(color: ResponsiveHelper.isDesktop(context)? Colors.white : Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      locationProvider.addressList != null ? locationProvider.addressList!.isNotEmpty ?

                      Scrollbar(
                        child: Column(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 1170,
                                child: ResponsiveHelper.isDesktop(context)
                                    ?  GridView.builder(
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                                      mainAxisSpacing: ResponsiveHelper.isDesktop(context) ? 13 : 5,
                                      childAspectRatio:ResponsiveHelper.isDesktop(context) ? 4.5 : ResponsiveHelper.isTab(context) ? 4 : 3.5,
                                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 2 : ResponsiveHelper.isTab(context) ? 2 : 1),
                                  itemCount: locationProvider.addressList!.length,
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    return AddressWidget(
                                      addressModel: locationProvider.addressList![index],
                                      index: index,
                                    );
                                  },
                                )
                                    : ListView.builder(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  itemCount: locationProvider.addressList!.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) => AddressWidget(
                                    addressModel: locationProvider.addressList![index],
                                    index: index,
                                  ),
                                ),
                              ),
                            ),
                            locationProvider.addressList!.length <= 4 ?  const SizedBox(height: 300) : const SizedBox(),
                            ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),
                          ],
                        ),
                      )
                          : const NoDataScreen()
                          : Center(child: CustomLoader(color: Theme.of(context).primaryColor)),
                    ],
                  ),
                ),
              ),
            );
          },
        ) : const NotLoggedInScreen(),
    );
  }
}