import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/provider/order_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/no_data_screen.dart';
import 'package:provider/provider.dart';

import 'order_card.dart';

class OrderView extends StatelessWidget {
  final bool isRunning;
  const OrderView({Key? key, required this.isRunning}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Consumer<OrderProvider>(
        builder: (context, order, index) {
          List<OrderModel>? orderList;
          if (order.runningOrderList != null) {
            orderList = isRunning ? order.runningOrderList!.reversed.toList() : order.historyOrderList!.reversed.toList();
          }

          return orderList != null ? orderList.isNotEmpty ? RefreshIndicator(
            onRefresh: () async {
              await Provider.of<OrderProvider>(context, listen: false).getOrderList(context);
              },

            backgroundColor: Theme.of(context).primaryColor,
            child: ListView(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 400 : MediaQuery.of(context).size.height),
                    child: SizedBox(
                      width: 1170,
                      child: ResponsiveHelper.isDesktop(context)
                          ?  GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisSpacing:  13 ,
                                  mainAxisSpacing: 13 ,
                                  childAspectRatio: 3 ,
                                  crossAxisCount:  2 ),
                              itemCount: orderList.length,
                              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                return OrderCard(orderList: orderList,index: index);
                              },
                            )
                          : ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                              itemCount: orderList.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return OrderCard(orderList: orderList,index: index);
                                },
                            ),
                    ),
                  ),
                ),

                ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),
              ],
            ),
          )
              : const NoDataScreen(isOrder: true)
              : Center(child: CustomLoader(color: Theme.of(context).primaryColor));
        },
      ),
    );
  }
}

