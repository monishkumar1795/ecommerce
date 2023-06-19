
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/address_model.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:provider/provider.dart';
class AddressWidget extends StatelessWidget {

  final AddressModel addressModel;
  final int index;
  const AddressWidget({Key? key, required this.addressModel, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {

      return Padding(
        padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
        child: InkWell(
          onTap: () {

            // if(addressModel != null) {
            //   Navigator.push(context, MaterialPageRoute(builder: (_) => MapWidget(address: addressModel)));
            // }
          },
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 700 : 200]!, spreadRadius: 0.5, blurRadius: 0.5)
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, color: Theme.of(context).primaryColor, size: 25),
                          const SizedBox(width: Dimensions.paddingSizeDefault),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  addressModel.addressType!,
                                  style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeLarge),
                                ),
                                Text(
                                  addressModel.address!,
                                  style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6), fontSize: Dimensions.fontSizeLarge),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      padding: const EdgeInsets.all(0),
                      onSelected: (String result) {
                        if (result == 'delete') {
                          showDialog(context: context, barrierDismissible: false, builder: (context) => Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                            ),
                          ));
                          Provider.of<LocationProvider>(context, listen: false).deleteUserAddressByID(addressModel.id, index,
                                  (bool isSuccessful, String message) {
                            Navigator.pop(context);
                                    showCustomSnackBar(message, isError: isSuccessful);
                              });
                        } else {
                          Provider.of<LocationProvider>(context, listen: false).updateAddressStatusMessage(message: '');
                          Navigator.of(context).pushNamed(
                            RouteHelper.getUpdateAddressRoute(
                              addressModel
                            ),
                            // arguments: AddNewAddressScreen(isEnableUpdate: true, address: addressModel),
                          );
                        }
                      },
                      itemBuilder: (BuildContext c) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'edit',
                          child: Text(getTranslated('edit', context)!, style: poppinsMedium),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(getTranslated('delete', context)!, style: poppinsMedium),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
}
