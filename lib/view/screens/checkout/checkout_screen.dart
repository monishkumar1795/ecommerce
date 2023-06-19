import 'dart:collection';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_grocery/data/model/response/address_model.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/not_login_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/address/add_new_address_screen.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/delivery_fee_dialog.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/details_view.dart';
import 'package:flutter_grocery/view/screens/checkout/widget/place_order_button_view.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  final double amount;
  final String? orderType;
  final double? discount;
  final String? couponCode;
  final String freeDeliveryType;
  const CheckoutScreen({Key? key, required this.amount, required this.orderType, required this.discount, required this.couponCode,required this.freeDeliveryType}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey();
  final TextEditingController _noteController = TextEditingController();
  late GoogleMapController _mapController;
  List<Branches>? _branches = [];
  bool _loading = true;
  Set<Marker> _markers = HashSet<Marker>();
  late bool _isLoggedIn;
  final List<String> _paymentList = [];

  @override
  void initState() {
    super.initState();
    Provider.of<OrderProvider>(context, listen: false).clearPrevData();

    _isLoggedIn = Provider.of<AuthProvider>(context, listen: false).isLoggedIn();
    if(_isLoggedIn ) {
      Provider.of<OrderProvider>(context, listen: false).setAddressIndex(-1, notify: false);
      Provider.of<OrderProvider>(context, listen: false).initializeTimeSlot();
      Provider.of<LocationProvider>(context, listen: false).initAddressList();
      _branches = Provider.of<SplashProvider>(context, listen: false).configModel!.branches;
    }

    if(Provider.of<SplashProvider>(context, listen: false).configModel!.cashOnDelivery == 'true') {
      _paymentList.add('cash_on_delivery');
    }

    if(Provider.of<SplashProvider>(context, listen: false).configModel!.offlinePayment!) {
      _paymentList.add('offline_payment');
    }

    if(Provider.of<SplashProvider>(context, listen: false).configModel!.walletStatus!) {
      _paymentList.add('wallet_payment');
    }

    for (var method in Provider.of<SplashProvider>(context, listen: false).configModel!.activePaymentMethodList!) {
      if(!_paymentList.contains(method)) {
        _paymentList.add(method);
      }

    }
  }

  double setDeliveryCharge(double charge){
    return charge;

  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    bool kmWiseCharge = configModel.deliveryManagement!.status!;
    bool selfPickup = widget.orderType == 'self_pickup';

    return Scaffold(
      key: _scaffoldKey,
      appBar: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar())  : CustomAppBar(title: getTranslated('checkout', context))) as PreferredSizeWidget?,
      body:  _isLoggedIn ? Consumer<OrderProvider>(
        builder: (context, order, child) {
          double deliveryCharge = order.distance * configModel.deliveryManagement!.shippingPerKm!;

          if(deliveryCharge < configModel.deliveryManagement!.minShippingCharge!) {
            deliveryCharge = configModel.deliveryManagement!.minShippingCharge!;
          }




           if((!kmWiseCharge || order.distance == -1) ||
              (configModel.freeDeliveryStatus!
                  && (widget.amount + widget.discount!) > configModel.freeDeliveryOverAmount!)) {
            deliveryCharge = 0;
          }


          return Consumer<LocationProvider>(
            builder: (context, address, child) {
              return Column(
                children: [

                  Expanded(child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Center(child: SizedBox(width: 1170, child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(flex: 4, child: Container(
                            margin: ResponsiveHelper.isDesktop(context) ?  const EdgeInsets.symmetric(
                              horizontal: Dimensions.paddingSizeSmall,
                              vertical: Dimensions.paddingSizeLarge,
                            ) : const EdgeInsets.all(0),

                            decoration:ResponsiveHelper.isDesktop(context) ? BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color:ColorResources.cartShadowColor.withOpacity(0.2),
                                    blurRadius: 10,
                                  )
                                ]
                            ) : const BoxDecoration(),
                            child: Column(children: [
                              //Branch
                              if (_branches!.isNotEmpty) Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                                  child: Text(getTranslated('select_branch', context)!, style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                ),

                                SizedBox(
                                  height: 50,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _branches!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                                        child: InkWell(
                                          onTap: () {
                                            try {
                                              order.setBranchIndex(index);
                                              double.parse(_branches![index].latitude!);
                                              _setMarkers(index);
                                            // ignore: empty_catches
                                            }catch(e) {}
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeExtraSmall, horizontal: Dimensions.paddingSizeSmall),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: index == order.branchIndex ? Theme.of(context).primaryColor : Theme.of(context).canvasColor,
                                              borderRadius: BorderRadius.circular(5),
                                            ),
                                            child: Text(_branches![index].name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: poppinsMedium.copyWith(
                                              color: index == order.branchIndex ? Colors.white : Theme.of(context).textTheme.bodyLarge!.color,
                                            )),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                Container(
                                  height: 200,
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).cardColor,
                                  ),
                                  child: Stack(children: [
                                    GoogleMap(
                                      minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                                      mapType: MapType.normal,
                                      initialCameraPosition: CameraPosition(target: LatLng(
                                        double.parse(_branches![0].latitude!),
                                        double.parse(_branches![0].longitude!),
                                      ), zoom: 8),
                                      zoomControlsEnabled: true,
                                      markers: _markers,
                                      onMapCreated: (GoogleMapController controller) async {
                                        await Geolocator.requestPermission();
                                        _mapController = controller;
                                        _loading = false;
                                        _setMarkers(0);
                                      },
                                    ),
                                    _loading ? Center(child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                                    )) : const SizedBox(),
                                  ]),
                                ),
                              ]) else const SizedBox(),

                              // Address
                              !selfPickup ? Column(children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                  child: Row(children: [
                                    Text(getTranslated('delivery_address', context)!, style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                    const Expanded(child: SizedBox()),
                                    TextButton.icon(
                                      onPressed: () => Navigator.pushNamed(context, RouteHelper.getAddAddressRoute('checkout', 'add', AddressModel()), arguments: const AddNewAddressScreen(fromCheckout: true)),
                                      icon: const Icon(Icons.add),
                                      label: Text(getTranslated('add', context)!, style: poppinsRegular),
                                    ),
                                  ]),
                                ),

                                address.addressList != null ? address.addressList!.isNotEmpty ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                  itemCount: address.addressList!.length,
                                  itemBuilder: (context, index) {
                                    bool isAvailable = _branches!.length == 1 && (_branches![0].latitude == null || _branches![0].latitude!.isEmpty);
                                    if(!isAvailable) {
                                      double distance = Geolocator.distanceBetween(
                                        double.parse(_branches![order.branchIndex].latitude!), double.parse(_branches![order.branchIndex].longitude!),
                                        double.parse(address.addressList![index].latitude!), double.parse(address.addressList![index].longitude!),
                                      ) / 1000;
                                      isAvailable = distance < _branches![order.branchIndex].coverage!;
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                                      child: InkWell(
                                        onTap: () async {
                                          if(isAvailable) {
                                            order.setAddressIndex(index);
                                            if(kmWiseCharge) {
                                              showDialog(context: context, builder: (context) => Center(child: Container(
                                                height: 100, width: 100, decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                                              ),
                                                alignment: Alignment.center,
                                                child: CustomLoader(color: Theme.of(context).primaryColor),
                                              )), barrierDismissible: false);
                                              bool isSuccess = await order.getDistanceInMeter(
                                                LatLng(
                                                  double.parse(_branches![order.branchIndex].latitude!),
                                                  double.parse(_branches![order.branchIndex].longitude!),
                                                ),
                                                LatLng(
                                                  double.parse(address.addressList![index].latitude!),
                                                  double.parse(address.addressList![index].longitude!),
                                                ),
                                              );
                                              Navigator.pop(Get.context!);
                                              if(isSuccess) {
                                               await showDialog(context: Get.context!, builder: (context) => DeliveryFeeDialog(
                                                  freeDelivery: widget.freeDeliveryType == 'free_delivery',
                                                  amount: widget.amount, distance: order.distance,
                                                  callBack: (deliveryChargeAmount){
                                                    deliveryCharge = deliveryChargeAmount;
                                                  }
                                                ));

                                              }else {
                                                showCustomSnackBar('failed_to_fetch_distance'.tr);
                                              }
                                            }
                                          }
                                        },
                                        child: Stack(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).cardColor,
                                                borderRadius: BorderRadius.circular(10),
                                                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: .5, blurRadius: .5)],
                                              ),
                                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                                  child: Container(
                                                    width: 20, height: 20,
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).cardColor,
                                                      border: Border.all(
                                                        color: index == order.addressIndex ? Theme.of(context).primaryColor
                                                            : Theme.of(context).hintColor.withOpacity(0.6).withOpacity(0.6),
                                                        width: index == order.addressIndex ? 7 : 5,
                                                      ),
                                                      shape: BoxShape.circle,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                                                  Text(address.addressList![index].addressType!, style: poppinsBold.copyWith(
                                                    fontSize: Dimensions.fontSizeSmall,
                                                    color: index == order.addressIndex ? Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)
                                                        : Theme.of(context).hintColor.withOpacity(0.6).withOpacity(.8),
                                                  )),
                                                  Text(address.addressList![index].address!, style: poppinsRegular.copyWith(
                                                    color: index == order.addressIndex ? Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)
                                                        : Theme.of(context).hintColor.withOpacity(0.6).withOpacity(.8),
                                                  ), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                ])),
                                              ]),
                                            ),

                                            !isAvailable ? Positioned(
                                              top: 0, left: 0, bottom: 10, right: 0,
                                              child: Container(
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.black.withOpacity(0.6)),
                                                child: Text(
                                                  getTranslated('out_of_coverage_for_this_branch', context)!,
                                                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                                                  style: poppinsRegular.copyWith(color: Colors.white, fontSize: 10),
                                                ),
                                              ),
                                            ) : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ) : Center(child: Text(getTranslated('no_address_found', context)!))
                                    : Center(child: CustomLoader(color: Theme.of(context).primaryColor)),
                                const SizedBox(height: 20),
                              ]) : const SizedBox(),

                              // Time Slot
                              Align(
                                alignment: Provider.of<LocalizationProvider>(context, listen: false).isLtr
                                    ? Alignment.topLeft : Alignment.topRight,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                                    child: Text(getTranslated('preference_time', context)!, style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                  ),
                                  const SizedBox(height: 10),

                                  SizedBox(
                                    height: 52,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      shrinkWrap: true,
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: 3,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 18, bottom: 2, top: 2),
                                          child: InkWell(
                                            onTap: () => order.updateDateSlot(index),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: order.selectDateSlot == index ? Theme.of(context).primaryColor
                                                    : Colors.white,
                                                borderRadius: BorderRadius.circular(7),
                                                boxShadow: [ BoxShadow(color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 800 : 100]!, spreadRadius: .5, blurRadius: .5)],),
                                              child: Text(
                                                index == 0 ? getTranslated('today', context)! : index == 1 ? getTranslated('tomorrow', context)!
                                                    : DateConverter.estimatedDate(DateTime.now().add(const Duration(days: 2))),
                                                style: poppinsRegular.copyWith(
                                                    fontSize: Dimensions.fontSizeLarge,
                                                    color: order.selectDateSlot == index ? Colors.white : Colors.grey[500]
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  order.timeSlots != null ? SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
                                    children: order.timeSlots!.map((timeSlotModel) {
                                      int index = order.timeSlots!.indexOf(timeSlotModel);
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                                        child: InkWell(
                                          onTap: () => order.updateTimeSlot(index),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: order.selectTimeSlot == index
                                                  ? Theme.of(context).primaryColor
                                                  : Colors.white,
                                              borderRadius: BorderRadius.circular(7),
                                              boxShadow: [BoxShadow(
                                                color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 800 : 100]!,
                                                spreadRadius: .5, blurRadius: .5,
                                              )],
                                            ),
                                            child: Text(
                                              '${DateConverter.stringToStringTime(order.timeSlots![index].startTime!, context)} '
                                                  '- ${DateConverter.stringToStringTime(order.timeSlots![index].endTime!, context)}',
                                              style: poppinsRegular.copyWith(
                                                fontSize: Dimensions.fontSizeLarge,
                                                color: order.selectTimeSlot == index
                                                    ? Colors.white : Colors.grey[500],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  )) : Center(child: CustomLoader(color: Theme.of(context).primaryColor)),


                                  const SizedBox(height: 20),
                                ]),
                              ),

                              if(!ResponsiveHelper.isDesktop(context))
                                DetailsView(
                                  freeDelivery: widget.freeDeliveryType == 'free_delivery',
                                  amount: widget.amount,
                                  paymentList: _paymentList,
                                  noteController: _noteController,
                                  kmWiseCharge: kmWiseCharge,
                                  selfPickup: selfPickup,
                                  deliveryCharge: deliveryCharge,
                                ),

                            ]),
                          )),

                          if(ResponsiveHelper.isDesktop(context))
                            Expanded(flex: 4, child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                                vertical: Dimensions.paddingSizeLarge,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color:ColorResources.cartShadowColor.withOpacity(0.2),
                                    blurRadius: 10,
                                  )
                                ],
                              ),
                              child: Column(children: [
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                Builder(
                                  builder: (context) {

                                    return DetailsView(
                                      freeDelivery: widget.freeDeliveryType == 'free_delivery',
                                      amount: widget.amount,
                                      paymentList: _paymentList,
                                      noteController: _noteController,
                                      kmWiseCharge: kmWiseCharge,
                                      selfPickup: selfPickup,
                                      deliveryCharge: deliveryCharge,
                                    );
                                  }
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraLarge),

                                PlaceOrderButtonView(
                                  amount: widget.amount,
                                  couponCode: widget.couponCode,
                                  deliveryCharge: deliveryCharge,
                                  kmWiseCharge: kmWiseCharge,
                                  noteController: _noteController,
                                  orderType: widget.orderType,
                                  selfPickUp: selfPickup,
                                )


                              ]),
                            )),


                        ]))),
                  )),

                 if(!ResponsiveHelper.isDesktop(context))
                   Center(child: PlaceOrderButtonView(
                     amount: widget.amount, couponCode: widget.couponCode, deliveryCharge: deliveryCharge,
                     kmWiseCharge: kmWiseCharge, noteController: _noteController, orderType: widget.orderType,
                     selfPickUp: selfPickup,
                  )),

                ],
              );
            },
          );
        },
      ) : const NotLoggedInScreen()
    );
  }

  void _setMarkers(int selectedIndex) async {
    late BitmapDescriptor bitmapDescriptor;
    late BitmapDescriptor bitmapDescriptorUnSelect;
    await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(25, 30)), Images.restaurantMarker).then((marker) {
      bitmapDescriptor = marker;
    });
    await BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(20, 20)), Images.unselectedRestaurantMarker).then((marker) {
      bitmapDescriptorUnSelect = marker;
    });
    // Marker
    _markers = HashSet<Marker>();
    for(int index=0; index<_branches!.length; index++) {
      _markers.add(Marker(
        markerId: MarkerId('branch_$index'),
        position: LatLng(double.tryParse(_branches![index].latitude!)!, double.tryParse(_branches![index].longitude!)!),
        infoWindow: InfoWindow(title: _branches![index].name, snippet: _branches![index].address),
        icon: selectedIndex == index ? bitmapDescriptor : bitmapDescriptorUnSelect,
      ));
    }

    _mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(
      double.tryParse(_branches![selectedIndex].latitude!)!,
      double.tryParse(_branches![selectedIndex].longitude!)!,
    ), zoom: ResponsiveHelper.isMobile() ? 12 : 16)));

    setState(() {});
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath, {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!.buffer.asUint8List();
  }

}


