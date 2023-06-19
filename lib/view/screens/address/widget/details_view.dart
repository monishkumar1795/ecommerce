
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/address_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_text_field.dart';
import 'package:flutter_grocery/view/screens/address/widget/buttons_view.dart';

class DetailsView extends StatelessWidget {
  final LocationProvider locationProvider;
  final TextEditingController contactPersonNameController;
  final TextEditingController contactPersonNumberController;
  final FocusNode addressNode;
  final FocusNode nameNode;
  final FocusNode numberNode;
  final bool isEnableUpdate;
  final bool fromCheckout;
  final AddressModel? address;
  final TextEditingController locationTextController;
  final TextEditingController streetNumberController;
  final TextEditingController houseNumberController;
  final TextEditingController florNumberController;
  final FocusNode stateNode;
  final FocusNode houseNode;
  final FocusNode florNode;
  const DetailsView({
    Key? key,
    required this.locationProvider,
    required this.contactPersonNameController,
    required this.contactPersonNumberController,
    required this.addressNode, required this.nameNode,
    required this.numberNode,
    required this.isEnableUpdate,
    required this.fromCheckout,
    required this.address,
    required this.locationTextController,
    required this.streetNumberController,
    required this.houseNumberController,
    required this.stateNode,
    required this.houseNode,
    required this.florNumberController,
    required this.florNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    locationTextController.text = locationProvider.address!;

    return Container(
      decoration: ResponsiveHelper.isDesktop(context) ?  BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: ColorResources.cartShadowColor.withOpacity(0.2),
              blurRadius: 10,
            )
          ]
      ) : const BoxDecoration(),
      //margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: Dimensions.paddingSizeLarge),
      padding: ResponsiveHelper.isDesktop(context) ?  const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge,vertical: Dimensions.paddingSizeLarge) : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              getTranslated('delivery_address', context)!,
              style:
              Theme.of(context).textTheme.displaySmall!.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6), fontSize: Dimensions.fontSizeLarge),
            ),
          ),
          // for Address Field
          Text(
            getTranslated('address_line_01', context)!,
            style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          CustomTextField(
            hintText: getTranslated('address_line_02', context),
            isShowBorder: true,
            inputType: TextInputType.streetAddress,
            inputAction: TextInputAction.next,
            focusNode: addressNode,
            nextFocus: stateNode,
            controller: locationTextController,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            '${getTranslated('street', context)} ${getTranslated('number', context)}',
            style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          CustomTextField(
            hintText: getTranslated('ex_10_th', context),
            isShowBorder: true,
            inputType: TextInputType.streetAddress,
            inputAction: TextInputAction.next,
            focusNode: stateNode,
            nextFocus: houseNode,
            controller: streetNumberController,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            '${getTranslated('house', context)} / ${
                getTranslated('floor', context)} ${
                getTranslated('number', context)}',
            style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(children: [
            Expanded(
              child: CustomTextField(
                hintText: getTranslated('ex_2', context),
                isShowBorder: true,
                inputType: TextInputType.streetAddress,
                inputAction: TextInputAction.next,
                focusNode: houseNode,
                nextFocus: florNode,
                controller: houseNumberController,
              ),
            ),

            const SizedBox(width: Dimensions.paddingSizeLarge),

            Expanded(
              child: CustomTextField(
                hintText: getTranslated('ex_2b', context),
                isShowBorder: true,
                inputType: TextInputType.streetAddress,
                inputAction: TextInputAction.next,
                focusNode: florNode,
                nextFocus: nameNode,
                controller: florNumberController,
              ),
            ),

          ],),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // for Contact Person Name
          Text(
            getTranslated('contact_person_name', context)!,
            style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextField(
            hintText: getTranslated('enter_contact_person_name', context),
            isShowBorder: true,
            inputType: TextInputType.name,
            controller: contactPersonNameController,
            focusNode: nameNode,
            nextFocus: numberNode,
            inputAction: TextInputAction.next,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // for Contact Person Number
          Text(
            getTranslated('contact_person_number', context)!,
            style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          CustomTextField(
            hintText: getTranslated('enter_contact_person_number', context),
            isShowBorder: true,
            inputType: TextInputType.phone,
            inputAction: TextInputAction.done,
            focusNode: numberNode,
            controller: contactPersonNumberController,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          if(ResponsiveHelper.isDesktop(context)) Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: ButtonsView(
              locationProvider: locationProvider,
              isEnableUpdate: isEnableUpdate,
              fromCheckout: fromCheckout,
              contactPersonNumberController: contactPersonNumberController,
              contactPersonNameController: contactPersonNameController,
              address: address,
              location: locationTextController.text,
              streetNumberController: streetNumberController,
              houseNumberController: houseNumberController,
              floorNumberController: florNumberController,
            ),
          )
        ],
      ),
    );
  }
}