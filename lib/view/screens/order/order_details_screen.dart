 import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/order_details_model.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/data/model/response/timeslote_model.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/helper/price_converter.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/provider/location_provider.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/provider/product_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/provider/theme_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_directionality.dart';
import 'package:flutter_grocery/view/base/custom_divider.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:flutter_grocery/view/screens/address/widget/map_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/order/widget/cancel_dialog.dart';
import 'package:flutter_grocery/view/screens/order/widget/change_method_dialog.dart';
import 'package:flutter_grocery/view/screens/review/rate_review_screen.dart';
import 'package:provider/provider.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  const OrderDetailsScreen({Key? key, required this.orderModel, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
 final GlobalKey<ScaffoldMessengerState> _scaffold = GlobalKey();
 late bool _isCashOnDeliveryActive;

  void _loadData(BuildContext context) async {
    final splashProvider = Provider.of<SplashProvider>(context, listen: false);
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);


    await orderProvider.trackOrder(widget.orderId.toString(), widget.orderModel, context, false);
    if (widget.orderModel == null) {
      await splashProvider.initConfig();
    }
    await locationProvider.initAddressList();
    await orderProvider.initializeTimeSlot();
    orderProvider.getOrderDetails(widget.orderId.toString());
  }

  @override
  void initState() {
    super.initState();
    _loadData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      appBar: (ResponsiveHelper.isDesktop(context) ? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()): CustomAppBar(
        title: 'order_details'.tr,
      )) as PreferredSizeWidget?,
      body: Consumer<OrderProvider>(
        builder: (context, order, child) {
          double? deliveryCharge = 0;
          double itemsPrice = 0;
          double discount = 0;
          double extraDiscount = 0;
          double tax = 0;
          bool? isVatInclude = false;
          TimeSlotModel? timeSlot;
          if(order.orderDetails != null) {
            deliveryCharge = order.trackModel!.deliveryCharge;
            for(OrderDetailsModel orderDetails in order.orderDetails!) {
              itemsPrice = itemsPrice + (orderDetails.price! * orderDetails.quantity!);
              discount = discount + (orderDetails.discountOnProduct! * orderDetails.quantity!);
              tax = tax + (orderDetails.taxAmount! * orderDetails.quantity!);
              isVatInclude = orderDetails.isVatInclude;
            }




            try{
              TimeSlotModel timeSlotModel = order.allTimeSlots!.firstWhere((timeSlot) => timeSlot.id == order.trackModel!.timeSlotId);
              timeSlot = timeSlotModel;
            }catch(c) {
              timeSlot = null;
            }
          }
          if( order.trackModel != null &&  order.trackModel!.extraDiscount != null) {
            extraDiscount  = order.trackModel!.extraDiscount ?? 0.0;
          }
          double subTotal = itemsPrice + (isVatInclude! ? 0 : tax);
          double total = subTotal - discount -extraDiscount + deliveryCharge! - (
              order.trackModel != null ? order.trackModel!.couponDiscountAmount! : 0
          );
          _isCashOnDeliveryActive = Provider.of<SplashProvider>(context, listen: false).configModel!.cashOnDelivery == 'true';

          return order.orderDetails != null ? order.orderDetails!.isNotEmpty
              ? ResponsiveHelper.isDesktop(context) ? ListView(children: [
            Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height),
                child: Container(
                  width: 1170,
                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).cardColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 700 : 300]!,
                                    spreadRadius: 1, blurRadius: 5,
                                  )
                                ]
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(children: [
                                  Text('${'order_id'.tr}:', style: poppinsRegular),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(order.trackModel!.id.toString(), style: poppinsMedium),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  const Expanded(child: SizedBox()),
                                  const Icon(Icons.watch_later, size: 17),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(DateConverter.isoStringToLocalDateOnly(order.trackModel!.createdAt!), style: poppinsMedium),
                                ]),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                if(timeSlot != null) Row(children: [
                                  Text('${'delivered_time'.tr}:', style: poppinsRegular),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(DateConverter.convertTimeRange(timeSlot.startTime!, timeSlot.endTime!, context), style: poppinsMedium),
                                ]),
                                const SizedBox(height: Dimensions.paddingSizeLarge),

                                Row(children: [
                                  Text('${'item'.tr}:', style: poppinsRegular),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                                  Text(order.orderDetails!.length.toString(), style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor)),
                                  const Expanded(child: SizedBox()),

                                  order.trackModel!.orderType == 'delivery' ? TextButton.icon(
                                    onPressed: () {
                                      if(order.trackModel!.deliveryAddress != null) {
                                        Navigator.push(context, MaterialPageRoute(builder: (_) => MapWidget(address: order.trackModel!.deliveryAddress)));
                                      }
                                      else{
                                        showCustomSnackBar('address_not_found'.tr);
                                      }
                                    },
                                    icon: Icon(Icons.map, size: 18, color: Theme.of(context).primaryColor,),
                                    label: Text('delivery_address'.tr, style: poppinsRegular.copyWith( color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                                    style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: const BorderSide(width: 1)),
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                                        minimumSize: const Size(1, 30)
                                    ),
                                  ) : order.trackModel!.orderType == 'pos' ? Text('pos_order'.tr, style: poppinsRegular) : Text('self_pickup'.tr, style: poppinsRegular),
                                ]),
                                const Divider(height: 20),

                                // Payment info
                                Align(
                                  alignment: Alignment.center,
                                  child: Text('payment_info'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                                ),
                                const SizedBox(height: 10),

                                Row(children: [
                                  Expanded(flex: 2, child: Text('${'status'.tr}:', style: poppinsRegular)),
                                  Expanded(flex: 8, child: Text(
                                    getTranslated(order.trackModel!.paymentStatus, context)!,
                                    style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
                                  )),
                                ]),
                                const SizedBox(height: 5),

                                Row(children: [
                                  Expanded(flex: 2, child: Text('method'.tr, style: poppinsRegular)),
                                  Builder(
                                    builder: (context) => Expanded(flex: 8, child: Row(children: [
                                      (order.trackModel!.paymentMethod != null && order.trackModel!.paymentMethod!.isNotEmpty) && order.trackModel!.paymentMethod == 'cash_on_delivery' ? Text(
                                        'cash_on_delivery'.tr,style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
                                      ) :
                                      Text(
                                        (order.trackModel!.paymentMethod != null && order.trackModel!.paymentMethod!.isNotEmpty)
                                            ? '${order.trackModel!.paymentMethod![0].toUpperCase()}${order.trackModel!.paymentMethod!.substring(1).replaceAll('_', ' ')}'
                                            : 'Digital Payment',
                                        style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
                                      ),
                                      (order.trackModel!.paymentStatus != 'paid' && order.trackModel!.paymentMethod != 'cash_on_delivery'
                                          && order.trackModel!.orderStatus != 'delivered') ? InkWell(
                                        onTap: () {
                                          if(!_isCashOnDeliveryActive){
                                            showCustomSnackBar('cash_on_delivery_is_not_activated'.tr,isError: true);
                                          }else{
                                            showDialog(context: context, barrierDismissible: false, builder: (context) => ChangeMethodDialog(
                                                orderID: order.trackModel!.id.toString(),
                                                fromOrder: widget.orderModel !=null,
                                                callback: (String message, bool isSuccess) {
                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 600), backgroundColor: isSuccess ? Colors.green : Colors.red));
                                                }),);
                                          }

                                        },
                                        child: Container(
                                          alignment: Alignment.center,
                                          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2),
                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).primaryColor.withOpacity(0.3)),
                                          child: Text('change'.tr, style: poppinsRegular.copyWith(
                                            fontSize: 10, color: Theme.of(context).textTheme.bodyLarge!.color,
                                          )),
                                        ),
                                      ) : const SizedBox(),
                                    ])),
                                  ),


                                ]),
                                const Divider(height: 40),

                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: order.orderDetails!.length,
                                  itemBuilder: (context, index) {
                                    return order.orderDetails![index].productDetails != null?
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: FadeInImage.assetNetwork(
                                            placeholder: Images.placeholder(context),
                                            image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/'
                                                '${order.orderDetails![index].productDetails!.image!.isNotEmpty ?
                                            order.orderDetails![index].productDetails!.image![0] : ''
                                            }',
                                            height: 70, width: 80, fit: BoxFit.cover,
                                            imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 70, width: 80, fit: BoxFit.cover),
                                          ),
                                        ),
                                        const SizedBox(width: Dimensions.paddingSizeSmall),

                                        Expanded(
                                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    order.orderDetails![index].productDetails!.name!,
                                                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Text('${'quantity'.tr}:', style: poppinsRegular),
                                                const SizedBox(
                                                  width: 5.0,
                                                ),
                                                Text(order.orderDetails![index].quantity.toString(), style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor)),
                                              ],
                                            ),
                                            const SizedBox(height: Dimensions.paddingSizeExtraSmall),

                                            Row(children: [
                                              CustomDirectionality(child: Text(
                                                PriceConverter.convertPrice(context, order.orderDetails![index].price! - order.orderDetails![index].discountOnProduct!.toDouble()),
                                                style: poppinsRegular,
                                              )),
                                              const SizedBox(width: 5),

                                              order.orderDetails![index].discountOnProduct! > 0 ?
                                              Expanded(child: CustomDirectionality(child: Text(
                                                PriceConverter.convertPrice(context, order.orderDetails![index].price!.toDouble()),
                                                style: poppinsRegular.copyWith(
                                                  decoration: TextDecoration.lineThrough,
                                                  fontSize: Dimensions.fontSizeSmall,
                                                  color: Theme.of(context).hintColor.withOpacity(0.6),
                                                ),
                                              ))) : const SizedBox(),
                                            ]),
                                            const SizedBox(height: Dimensions.paddingSizeSmall),

                                            order.orderDetails![index].variation!.isNotEmpty ?
                                            Row(children: [
                                              order.orderDetails![index].variation != ''&& order.orderDetails![index].variation != null?
                                              Container(height: 10, width: 10, decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Theme.of(context).textTheme.bodyLarge!.color,
                                              )) : const SizedBox.shrink(),
                                              const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                              Text(order.orderDetails![index].variation?? '',
                                                style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                              ),
                                            ]):const SizedBox() ,
                                          ]),
                                        ),
                                      ]),
                                      const Divider(height: 40),

                                    ]): const SizedBox.shrink();
                                  },
                                ),

                                (order.trackModel!.orderNote != null && order.trackModel!.orderNote!.isNotEmpty) ? Container(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('${'order_note'.tr} : ${order.trackModel!.orderNote!}', style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))),
                                ) : const SizedBox(),
                              ],),
                          ),),


                        const SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).cardColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme ? 700 : 300]!,
                                    spreadRadius: 1, blurRadius: 5,
                                  )
                                ]
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('items_price'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                  CustomDirectionality(child: Text(
                                    PriceConverter.convertPrice(context, itemsPrice),
                                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                                  )),
                                ]),
                                const SizedBox(height: 10),

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('${'tax'.tr} ${isVatInclude ? '(${'include'.tr})' : ''}',
                                      style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                  CustomDirectionality(child: Text(
                                    '${isVatInclude ? '' : '(+)'} ${PriceConverter.convertPrice(context, tax)}',
                                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                                  )),
                                ]),
                                const SizedBox(height: 10),

                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                  child: CustomDivider(color: Theme.of(context).textTheme.bodyLarge!.color),
                                ),

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('subtotal'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                  CustomDirectionality(child: Text(
                                    PriceConverter.convertPrice(context, subTotal),
                                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                                  )),
                                ]),
                                const SizedBox(height: 10),

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('discount'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                  CustomDirectionality(child: Text(
                                    '(-) ${PriceConverter.convertPrice(context, discount)}',
                                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                                  )),
                                ]),
                                const SizedBox(height: 10),

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('coupon_discount'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                  CustomDirectionality(child: Text(
                                    '(-) ${PriceConverter.convertPrice(context, order.trackModel!.couponDiscountAmount)}',
                                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                                  )),
                                ]),
                                const SizedBox(height: 10),

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('delivery_fee'.tr, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

                                  CustomDirectionality(child: Text(
                                    '(+) ${PriceConverter.convertPrice(context, deliveryCharge)}',
                                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
                                  )),
                                ]),

                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                                  child: CustomDivider(),
                                ),

                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  Text('total_amount'.tr, style: poppinsRegular.copyWith(
                                    fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor,
                                  )),

                                  CustomDirectionality(child: Text(
                                    PriceConverter.convertPrice(context, total),
                                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                                  )),
                                ]),

                                !order.showCancelled ? Center(
                                  child: SizedBox(
                                    width: 1170,
                                    child: Row(children: [
                                      order.trackModel!.orderStatus == 'pending' ? Expanded(child: Padding(
                                        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            minimumSize: const Size(1, 50),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: BorderSide(width: 2, color: ColorResources.getGreyColor(context))),
                                          ),
                                          onPressed: () {
                                            showDialog(context: context, barrierDismissible: false, builder: (context) => OrderCancelDialog(
                                              orderID: order.trackModel!.id.toString(),
                                              fromOrder: widget.orderModel !=null,
                                              callback: (String message, bool isSuccess, String orderID) {
                                                if (isSuccess) {
                                                  Provider.of<ProductProvider>(context, listen: false).getItemList(
                                                    '1', true, Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
                                                    ProductType.popularProduct,
                                                  );

                                                  showCustomSnackBar('$message. ${'order_id'.tr}: $orderID', isError: false);
                                                } else {
                                                  showCustomSnackBar(message, isError: false);
                                                }
                                              },
                                            ));
                                          },
                                          child: Text('cancel_order'.tr, style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                            color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                                            fontSize: Dimensions.fontSizeLarge,
                                          )),
                                        ),
                                      )) : const SizedBox(),


                                    ]),
                                  ),
                                ) : Container(
                                  width: 1170,
                                  height: 50,
                                  margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text('order_cancelled'.tr, style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor)),
                                ),

                                (order.trackModel!.orderStatus == 'confirmed' || order.trackModel!.orderStatus == 'processing'
                                    || order.trackModel!.orderStatus == 'out_for_delivery') ? Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  child: CustomButton(
                                    buttonText: 'track_order'.tr,
                                    onPressed: () {
                                      Navigator.pushNamed(context, RouteHelper.getOrderTrackingRoute(order.trackModel!.id));
                                    },
                                  ),
                                ) : const SizedBox(),

                                order.trackModel!.orderStatus == 'delivered' && order.trackModel!.orderType !='pos'? Padding(
                                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                  child: CustomButton(
                                    buttonText: 'review'.tr,
                                    onPressed: () {
                                      List<OrderDetailsModel> orderDetailsList = [];
                                      List<int?> orderIdList = [];
                                      for (var orderDetails in order.orderDetails!) {
                                        if(!orderIdList.contains(orderDetails.productDetails!.id)) {
                                          orderDetailsList.add(orderDetails);
                                          orderIdList.add(orderDetails.productDetails!.id);
                                        }
                                      }
                                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => RateReviewScreen(
                                        orderDetailsList: orderDetailsList,
                                        deliveryMan: order.trackModel!.deliveryMan,
                                      )));
                                    },
                                  ),
                                ) : const SizedBox(),
                                if(order.trackModel!.deliveryMan != null && (order.trackModel!.orderStatus == 'processing' || order.trackModel!.orderStatus == 'out_for_delivery'))
                                  Center(
                                    child: Container(
                                      width:  double.infinity ,
                                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                                      child: CustomButton(buttonText: 'chat_with_delivery_man'.tr, onPressed: (){
                                        Navigator.pushNamed(context, RouteHelper.getChatRoute(orderModel: order.trackModel));
                                      }),
                                    ),
                                  ),

                              ],),




                          ),),
                      ],),
                  ),
                ),
              ),
            ),
            ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),
          ],) : Column(children: [
            Expanded(child: Scrollbar(child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Center(child: SizedBox(
                width: 1170,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text('${getTranslated('order_id', context)}:', style: poppinsRegular),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(order.trackModel!.id.toString(), style: poppinsMedium),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      const Expanded(child: SizedBox()),
                      const Icon(Icons.watch_later, size: 17),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(DateConverter.isoStringToLocalDateOnly(order.trackModel!.createdAt!), style: poppinsMedium),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    if(timeSlot != null) Row(children: [
                      Text('${getTranslated('delivered_time', context)}:', style: poppinsRegular),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(DateConverter.convertTimeRange(timeSlot.startTime!, timeSlot.endTime!, context), style: poppinsMedium),
                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Row(children: [
                      Text('${getTranslated('item', context)}:', style: poppinsRegular),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text(order.orderDetails!.length.toString(), style: poppinsMedium.copyWith(color: Theme.of(context).primaryColor)),
                      const Expanded(child: SizedBox()),

                      order.trackModel!.orderType == 'delivery' ? TextButton.icon(
                        onPressed: () {
                          if(order.trackModel!.deliveryAddress != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => MapWidget(address: order.trackModel!.deliveryAddress)));
                          }
                          else{
                            showCustomSnackBar(getTranslated('address_not_found', context)!, isError: true);
                          }
                        },
                        icon: Icon(Icons.map, size: 18, color: Theme.of(context).primaryColor,),
                        label: Text(getTranslated('delivery_address', context)!, style: poppinsRegular.copyWith( color: Theme.of(context).primaryColor, fontSize: Dimensions.fontSizeSmall)),
                        style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5), side: const BorderSide(width: 1)),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                            minimumSize: const Size(1, 30)
                        ),
                      ) : order.trackModel!.orderType == 'pos' ? Text(getTranslated('pos_order', context)!, style: poppinsRegular) : Text(getTranslated('self_pickup', context)!, style: poppinsRegular),
                    ]),
                    const Divider(height: 20),


                    // Payment info
                    Align(
                      alignment: Alignment.center,
                      child: Text(getTranslated('payment_info', context)!, style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(flex: 2, child: Text('${getTranslated('status', context)}:', style: poppinsRegular)),
                      Expanded(flex: 8, child: Text(
                        getTranslated(order.trackModel!.paymentStatus, context)!,
                        style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
                      )),
                    ]),
                    const SizedBox(height: 5),
                    Row(children: [
                      Expanded(flex: 2, child: Text(getTranslated('method', context)!, style: poppinsRegular)),
                      Builder(
                        builder: (context) => Expanded(flex: 8, child: Row(children: [
                          (order.trackModel!.paymentMethod != null && order.trackModel!.paymentMethod!.isNotEmpty) && order.trackModel!.paymentMethod == 'cash_on_delivery' ? Text(
                            getTranslated('cash_on_delivery', context)!,style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
                          ) :
                          Text(
                            (order.trackModel!.paymentMethod != null && order.trackModel!.paymentMethod!.isNotEmpty)
                                ? '${order.trackModel!.paymentMethod![0].toUpperCase()}${order.trackModel!.paymentMethod!.substring(1).replaceAll('_', ' ')}'
                                : 'Digital Payment',
                            style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor),
                          ),
                          (order.trackModel!.paymentStatus != 'paid' && order.trackModel!.paymentMethod != 'cash_on_delivery'
                              && order.trackModel!.orderStatus != 'delivered') ? InkWell(
                            onTap: () {
                              if(!_isCashOnDeliveryActive){
                                showCustomSnackBar(getTranslated('cash_on_delivery_is_not_activated', context)!,isError: true);
                              }else{
                                showDialog(context: context, barrierDismissible: false, builder: (context) => ChangeMethodDialog(
                                    orderID: order.trackModel!.id.toString(),
                                    fromOrder: widget.orderModel != null,
                                    callback: (String message, bool isError) {
                                      showCustomSnackBar(message, isError: isError);
                                    }),);
                              }

                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall, vertical: 2),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).primaryColor.withOpacity(0.3)),
                              child: Text(getTranslated('change', context)!, style: poppinsRegular.copyWith(
                                fontSize: 10, color: Theme.of(context).textTheme.bodyLarge!.color,
                              )),
                            ),
                          ) : const SizedBox(),
                        ])),
                      ),


                    ]),
                    const Divider(height: 40),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: order.orderDetails!.length,
                      itemBuilder: (context, index) {

                        return order.orderDetails![index].productDetails != null?
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FadeInImage.assetNetwork(
                                placeholder: Images.placeholder(context),
                                image: '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.productImageUrl}/'
                                    '${order.orderDetails![index].productDetails!.image!.isNotEmpty
                                    ? order.orderDetails![index].productDetails!.image![0] : ''}',
                                height: 70, width: 80, fit: BoxFit.cover,
                                imageErrorBuilder: (c, o, s) => Image.asset(Images.placeholder(context), height: 70, width: 80, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        order.orderDetails![index].productDetails!.name!,
                                        style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text('${getTranslated('quantity', context)}:', style: poppinsRegular),
                                    const SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(order.orderDetails![index].quantity.toString(), style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor)),
                                  ],
                                ),
                                const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                Row(children: [
                                  CustomDirectionality(child: Text(
                                    PriceConverter.convertPrice(context, order.orderDetails![index].price! - order.orderDetails![index].discountOnProduct!.toDouble()),
                                    style: poppinsRegular,
                                  )),
                                  const SizedBox(width: 5),

                                  order.orderDetails![index].discountOnProduct! > 0 ?
                                  Expanded(child: CustomDirectionality(
                                    child: Text(
                                      PriceConverter.convertPrice(context, order.orderDetails![index].price!.toDouble()),
                                      style: poppinsRegular.copyWith(
                                        decoration: TextDecoration.lineThrough,
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: Theme.of(context).hintColor.withOpacity(0.6),
                                      ),
                                    ),
                                  )) : const SizedBox(),
                                ]),
                                const SizedBox(height: Dimensions.paddingSizeSmall),

                                order.orderDetails![index].variation != ''&& order.orderDetails![index].variation != null?
                                Row(children: [
                                  Container(height: 10, width: 10, decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).textTheme.bodyLarge!.color,
                                  )),
                                  const SizedBox(width: Dimensions.paddingSizeExtraSmall),

                                  Text(order.orderDetails![index].variation ?? '',
                                    style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                                  ),
                                ]):const SizedBox(),
                              ]),
                            ),
                          ]),
                          const Divider(height: 40),
                        ]): const SizedBox.shrink();/*Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('product was deleted or product not found',style: TextStyle(color: Colors.red),),
                                );*/
                      },
                    ),

                    (order.trackModel!.orderNote != null && order.trackModel!.orderNote!.isNotEmpty) ? Container(
                      padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeLarge),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(width: 1, color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6)),
                      ),
                      child: Text(order.trackModel!.orderNote!, style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6))),
                    ) : const SizedBox(),

                    // Total
                    ItemView(
                      title: getTranslated('items_price', context)!,
                      subTitle: PriceConverter.convertPrice(context, itemsPrice),
                    ),
                    const SizedBox(height: 10),

                    ItemView(
                      title: '${getTranslated('tax', context)} ${isVatInclude
                          ? '(${getTranslated('include', context)})' : ''}',
                      subTitle: '${isVatInclude ? '' : '(+)'} ${PriceConverter.convertPrice(context, tax)}',
                    ),
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: CustomDivider(color: Theme.of(context).textTheme.bodyLarge!.color),
                    ),

                    ItemView(
                      title: getTranslated('subtotal', context)!,
                      subTitle: PriceConverter.convertPrice(context, subTotal),
                    ),
                    const SizedBox(height: 10),

                    ItemView(
                      title: getTranslated('discount', context)!,
                      subTitle: '(-) ${PriceConverter.convertPrice(context, discount)}',
                    ),
                    const SizedBox(height: 10),

                    order.trackModel!.orderType=="pos"?
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: ItemView(
                        title: getTranslated('extra_discount', context)!,
                        subTitle: '(-) ${PriceConverter.convertPrice(context, extraDiscount)}',
                      ),
                    ):const SizedBox(),

                    ItemView(
                      title:getTranslated('coupon_discount', context)!,
                      subTitle: '(-) ${PriceConverter.convertPrice(context, order.trackModel!.couponDiscountAmount)}',
                    ),
                    const SizedBox(height: 10),

                    ItemView(
                      title: getTranslated('delivery_fee', context)!,
                      subTitle: '(+) ${PriceConverter.convertPrice(context, deliveryCharge)}',
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: CustomDivider(),
                    ),

                    ItemView(
                      title: getTranslated('total_amount', context)!,
                      subTitle: PriceConverter.convertPrice(context, total),
                      style: poppinsRegular.copyWith(
                        fontSize: Dimensions.fontSizeExtraLarge,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),),
            ),)),

            !order.showCancelled ? Center(
              child: SizedBox(width: 1170, child: Row(children: [
                order.trackModel!.orderStatus == 'pending' ? Expanded(child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                  child: TextButton(
                    style: TextButton.styleFrom(minimumSize: const Size(1, 50), shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), side: BorderSide(width: 2, color: ColorResources.getGreyColor(context)),
                    )), onPressed: () {
                    showDialog(context: context, barrierDismissible: false, builder: (context) => OrderCancelDialog(
                      orderID: order.trackModel!.id.toString(),
                      fromOrder: widget.orderModel !=null,
                      callback: (String message, bool isSuccess, String orderID) {
                        if (isSuccess) {
                          Provider.of<ProductProvider>(context, listen: false).getItemList('1',
                            true,Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode,
                            ProductType.popularProduct,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('$message. ${getTranslated('order_id', context)}: $orderID'),
                            backgroundColor: Colors.green,
                          ));
                        }else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
                        }},
                    ));},
                    child: Text(getTranslated('cancel_order', context)!, style: Theme.of(context).textTheme.displaySmall!.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                      fontSize: Dimensions.fontSizeLarge,
                    )),
                  ),
                )) : const SizedBox(),


              ]),
              ),
            ) :
            Container(
              width: 1170,
              height: 50,
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(getTranslated('order_cancelled', context)!, style: poppinsRegular.copyWith(color: Theme.of(context).primaryColor)),
            ),

            (order.trackModel!.orderStatus == 'confirmed' || order.trackModel!.orderStatus == 'processing'
                || order.trackModel!.orderStatus == 'out_for_delivery' && order.trackModel!.orderType !='pos'
            ) ? Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: CustomButton(
                buttonText: getTranslated('track_order', context),
                onPressed: () {
                  Navigator.pushNamed(context, RouteHelper.getOrderTrackingRoute(order.trackModel!.id));
                },
              ),
            ) : const SizedBox(),

            order.trackModel!.orderStatus == 'delivered' && order.trackModel!.orderType != 'pos'? Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: CustomButton(
                buttonText: 'review'.tr,
                onPressed: () {
                  List<OrderDetailsModel> orderDetailsList = [];
                  List<int?> orderIdList = [];
                  for (var orderDetails in order.orderDetails!) {
                    if(!orderIdList.contains(orderDetails.productDetails!.id)) {
                      orderDetailsList.add(orderDetails);
                      orderIdList.add(orderDetails.productDetails!.id);
                    }
                  }
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => RateReviewScreen(
                    orderDetailsList: orderDetailsList,
                    deliveryMan: order.trackModel!.deliveryMan,
                  )));
                },
              ),
            ) : const SizedBox(),

            if(order.trackModel!.deliveryMan != null && (order.trackModel!.orderStatus == 'processing' || order.trackModel!.orderStatus == 'out_for_delivery'))
              Center(child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: CustomButton(buttonText: 'chat_with_delivery_man'.tr, onPressed: (){
                  Navigator.pushNamed(context, RouteHelper.getChatRoute(orderModel: order.trackModel));
                }),
              ),),
            ],
          )
              :  NoDataScreen(isOrder: true, title: 'order_not_found'.tr,) : Center(child: CustomLoader(color: Theme.of(context).primaryColor));
        },
      ),
    );
  }
}

class ItemView extends StatelessWidget {
  const ItemView({
    Key? key,
    required this.title,
    required this.subTitle,
    this.style,
  }) : super(key: key);

  final String title;
  final String subTitle;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: style ?? poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),

      CustomDirectionality(child: Text(
        subTitle,
        style: style ?? poppinsRegular.copyWith(fontSize: Dimensions.fontSizeLarge),
      )),
    ]);
  }
}
