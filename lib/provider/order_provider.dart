
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/body/place_order_body.dart';
import 'package:flutter_grocery/data/model/body/review_body.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/distance_model.dart';
import 'package:flutter_grocery/data/model/response/order_details_model.dart';
import 'package:flutter_grocery/data/model/response/order_model.dart';
import 'package:flutter_grocery/data/model/response/response_model.dart';
import 'package:flutter_grocery/data/model/response/timeslote_model.dart';
import 'package:flutter_grocery/data/repository/order_repo.dart';
import 'package:flutter_grocery/helper/api_checker.dart';
import 'package:flutter_grocery/data/model/response/delivery_man_model.dart';
import 'package:flutter_grocery/helper/date_converter.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:flutter_grocery/utill/app_constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class
OrderProvider extends ChangeNotifier {
  final OrderRepo? orderRepo;
  final SharedPreferences? sharedPreferences;
  OrderProvider({ required this.sharedPreferences,required this.orderRepo});

  List<OrderModel>? _runningOrderList;
  List<OrderModel>? _historyOrderList;
  List<OrderDetailsModel>? _orderDetails;
  int _paymentMethodIndex = 0;
  OrderModel? _trackModel;
  int _addressIndex = -1;
  bool _isLoading = false;
  bool _showCancelled = false;
  List<TimeSlotModel>? _timeSlots;
  List<TimeSlotModel>? _allTimeSlots;
  bool _isActiveOrder = true;
  int _branchIndex = 0;
  String? _orderType = 'delivery';
  ResponseModel? _responseModel;
  DeliveryManModel? _deliveryManModel;
  double _distance = -1;
  String _paymentMethod = '';



  List<TimeSlotModel>? get timeSlots => _timeSlots;
  List<TimeSlotModel>? get allTimeSlots => _allTimeSlots;
  List<OrderModel>? get runningOrderList => _runningOrderList;
  List<OrderModel>? get historyOrderList => _historyOrderList;
  List<OrderDetailsModel>? get orderDetails => _orderDetails;
  int get paymentMethodIndex => _paymentMethodIndex;
  OrderModel? get trackModel => _trackModel;
  int get addressIndex => _addressIndex;
  bool get isLoading => _isLoading;
  bool get showCancelled => _showCancelled;
  bool get isActiveOrder => _isActiveOrder;
  int get branchIndex => _branchIndex;
  String? get orderType => _orderType;
  ResponseModel? get responseModel => _responseModel;
  DeliveryManModel? get deliveryManModel => _deliveryManModel;
  double get distance => _distance;
  String get paymentMethod => _paymentMethod;


  Future<void> getOrderList(BuildContext context) async {
    ApiResponse apiResponse = await orderRepo!.getOrderList();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _runningOrderList = [];
      _historyOrderList = [];
      apiResponse.response!.data.forEach((order) {
        OrderModel orderModel = OrderModel.fromJson(order);
        if (orderModel.orderStatus == 'pending' ||
            orderModel.orderStatus == 'processing' ||
            orderModel.orderStatus == 'out_for_delivery' ||
            orderModel.orderStatus == 'confirmed') {
          _runningOrderList!.add(orderModel);
        } else if (orderModel.orderStatus == 'delivered'||
            orderModel.orderStatus == 'returned' ||
            orderModel.orderStatus == 'failed' ||
            orderModel.orderStatus == 'canceled') {
          _historyOrderList!.add(orderModel);
        }
      });
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<void> initializeTimeSlot() async {
    _distance = -1;
    ApiResponse apiResponse = await orderRepo!.getTimeSlot();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _timeSlots = [];
      _allTimeSlots = [];
      apiResponse.response!.data.forEach((timeSlot) {

        _timeSlots!.add(TimeSlotModel.fromJson(timeSlot));

        _allTimeSlots!.add(TimeSlotModel.fromJson(timeSlot));

      });
      validateSlot(_allTimeSlots, 0);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  List<String> getDates(BuildContext context) {
    return orderRepo!.getDates(context);
  }

  int _selectDateSlot = 0;
  int _selectTimeSlot = 0;

  int get selectDateSlot => _selectDateSlot;
  int get selectTimeSlot => _selectTimeSlot;

  void updateTimeSlot(int index) {
    _selectTimeSlot = index;
    notifyListeners();
  }

  void updateDateSlot(int index) {
    _selectDateSlot = index;
    if(_allTimeSlots != null) {
      validateSlot(_allTimeSlots, index);
    }
    _selectTimeSlot = index;
    notifyListeners();
  }

  void validateSlot(List<TimeSlotModel>? slots, int dateIndex) {
    _timeSlots = [];
    if(dateIndex == 0) {
      DateTime date = DateTime.now();
      for (var slot in slots!) {
        DateTime time = DateConverter.stringTimeToDateTime(slot.endTime!).subtract(const Duration(/*hours: 1*/minutes: 30));
        DateTime dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute, time.second);
        if (dateTime.isAfter(DateTime.now())) {
          _timeSlots!.add(slot);
        }
      }
    }else {
      _timeSlots!.addAll(_allTimeSlots!);
    }
  }

  double subTotal = 0;
  double discount = 0;
  double totalPrice=0;

  Future<List<OrderDetailsModel>?> getOrderDetails(String orderID) async {
    _orderDetails = null;
    _isLoading = true;
    _showCancelled = false;
    subTotal = 0;
    discount = 0;
    totalPrice = 0;
    notifyListeners();
    ApiResponse apiResponse = await orderRepo!.getOrderDetails(orderID, Provider.of<LocalizationProvider>(Get.context!, listen: false).locale.languageCode);
    _isLoading = false;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _orderDetails = [];
      apiResponse.response!.data.forEach((orderDetail) => _orderDetails!.add(OrderDetailsModel.fromJson(orderDetail)));
      for (var element in _orderDetails!) {
        try{
          subTotal += double.parse(element.productDetails!.price.toString());
          discount += double.parse(element.productDetails!.discount.toString());
          totalPrice += double.parse(element.price.toString());
        }catch(e){
          subTotal = 0;
          discount =0;
          totalPrice = 0;
        }

      }

    } else {
      _orderDetails = [];
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return _orderDetails;
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void changeActiveOrderStatus(bool status) {
    _isActiveOrder = status;
    notifyListeners();
  }

  Future<void> getDeliveryManData(String? orderID, BuildContext context) async {
    ApiResponse apiResponse = await orderRepo!.getDeliveryManData(orderID);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _deliveryManModel = DeliveryManModel.fromJson(apiResponse.response!.data);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  Future<ResponseModel> trackOrder(String? orderID, OrderModel? orderModel, BuildContext context, bool fromTracking) async {
    _trackModel = null;
    ResponseModel responseModel;
    if(!fromTracking) {
      _orderDetails = null;
    }
    _showCancelled = false;
    if(orderModel == null) {
      _isLoading = true;
      ApiResponse apiResponse = await orderRepo!.trackOrder(orderID);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        _trackModel = OrderModel.fromJson(apiResponse.response!.data);
        responseModel = ResponseModel(true, apiResponse.response!.data.toString());
      } else {
        responseModel = ResponseModel(false, apiResponse.error.errors[0].message);
        ApiChecker.checkApi(apiResponse);
      }
      _isLoading = false;
      notifyListeners();
    }else {
      _trackModel = orderModel;
      responseModel = ResponseModel(true, 'Successful');
    }
    return responseModel;
  }

  Future<void> placeOrder(PlaceOrderBody placeOrderBody, Function callback) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await orderRepo!.placeOrder(placeOrderBody);
    _isLoading = false;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      String? message = apiResponse.response!.data['message'];
      String orderID = apiResponse.response!.data['order_id'].toString();
      callback(true, message, orderID);
      debugPrint('-------- Order placed successfully $orderID ----------');
    } else {
      callback(false, ApiChecker.getError(apiResponse).errors![0].message, '-1');
    }
    notifyListeners();
  }

  void stopLoader() {
    _isLoading = false;
    notifyListeners();
  }

  void setAddressIndex(int index, {bool notify = true}) {
    _addressIndex = index;
    if (notify) {
      notifyListeners();
    }
  }

  void cancelOrder(String orderID, bool fromOrder, Function callback, ) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await orderRepo!.cancelOrder(orderID);
    _isLoading = false;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
     if(fromOrder){
       OrderModel? orderModel;
       for (var order in _runningOrderList!) {
         if (order.id.toString() == orderID) {
           orderModel = order;
         }
       }
       _runningOrderList!.remove(orderModel);
     }
      _showCancelled = true;
      callback(apiResponse.response!.data['message'], true, orderID);
    } else {
      callback(apiResponse.error.errors[0].message, false, '-1');
    }
    notifyListeners();
  }

  void setBranchIndex(int index) {
    _branchIndex = index;
    _addressIndex = -1;
    _distance = -1;
    notifyListeners();
  }

  void setOrderType(String? type, {bool notify = true}) {
    _orderType = type;
    if(notify) {
      notifyListeners();
    }
  }

  Future<void> updatePaymentMethod(String orderID, bool fromOrder, Function callback, ) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await orderRepo!.updatePaymentMethod(orderID);
    _isLoading = false;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      if(fromOrder){
        int? orderIndex;
        for(int index=0; index<_runningOrderList!.length; index++) {
          if(_runningOrderList![index].id.toString() == orderID) {
            orderIndex = index;
            break;
          }
        }
        if(orderIndex != null) {
          _runningOrderList![orderIndex].paymentMethod = 'cash_on_delivery';
        }
      }
      _trackModel!.paymentMethod = 'cash_on_delivery';
      callback(apiResponse.response!.data['message'], false);
    } else {
      callback(apiResponse.error.errors[0].message, true);
    }
    notifyListeners();
  }

  List<int> _ratingList = [];
  List<String> _reviewList = [];
  List<bool> _loadingList = [];
  List<bool> _submitList = [];
  int _deliveryManRating = 0;

  List<int> get ratingList => _ratingList;
  List<String> get reviewList => _reviewList;
  List<bool> get loadingList => _loadingList;
  List<bool> get submitList => _submitList;
  int get deliveryManRating => _deliveryManRating;

  void initRatingData(List<OrderDetailsModel> orderDetailsList) {
    _ratingList = [];
    _reviewList = [];
    _loadingList = [];
    _submitList = [];
    _deliveryManRating = 0;
    for (int i = 0; i < orderDetailsList.length; i++) {
      _ratingList.add(0);
      _reviewList.add('');
      _loadingList.add(false);
      _submitList.add(false);
    }
  }

  void setRating(int index, int rate) {
    _ratingList[index] = rate;
    notifyListeners();
  }

  void setReview(int index, String review) {
    _reviewList[index] = review;
  }

  void setDeliveryManRating(int rate) {
    _deliveryManRating = rate;
    notifyListeners();
  }

  Future<ResponseModel> submitReview(int index, ReviewBody reviewBody) async {
    _loadingList[index] = true;
    notifyListeners();

    ApiResponse response = await orderRepo!.submitReview(reviewBody);
    ResponseModel responseModel;
    if (response.response != null && response.response!.statusCode == 200) {
      _submitList[index] = true;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      notifyListeners();
    } else {
      String? errorMessage;
      if(response.error is String) {
        errorMessage = response.error.toString();
      }else {
        errorMessage = response.error.errors[0].message;
      }
      responseModel = ResponseModel(false, errorMessage);
    }
    _loadingList[index] = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> submitDeliveryManReview(ReviewBody reviewBody) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse response = await orderRepo!.submitDeliveryManReview(reviewBody);
    ResponseModel responseModel;
    if (response.response != null && response.response!.statusCode == 200) {
      _deliveryManRating = 0;
      responseModel = ResponseModel(true, 'Review submitted successfully');
      notifyListeners();
    } else {
      String? errorMessage;
      if(response.error is String) {
        errorMessage = response.error.toString();
      }else {
        errorMessage = response.error.errors[0].message;
      }
      responseModel = ResponseModel(false, errorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<bool> getDistanceInMeter(LatLng originLatLng, LatLng destinationLatLng) async {
    _distance = -1;
    bool isSuccess = false;
    ApiResponse response = await orderRepo!.getDistanceInMeter(originLatLng, destinationLatLng);
    try {
      if (response.response!.statusCode == 200 && response.response!.data['status'] == 'OK') {
        isSuccess = true;
        _distance = DistanceModel.fromJson(response.response!.data).rows![0].elements![0].distance!.value! / 1000;
      } else {
        _distance = Geolocator.distanceBetween(
          originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude,
        ) / 1000;
      }
    } catch (e) {
      _distance = Geolocator.distanceBetween(
        originLatLng.latitude, originLatLng.longitude, destinationLatLng.latitude, destinationLatLng.longitude,
      ) / 1000;
    }
    notifyListeners();
    return isSuccess;
  }

  Future<void> setPlaceOrder(String placeOrder)async{
    await sharedPreferences!.setString(AppConstants.placeOrderData, placeOrder);
  }
  String? getPlaceOrder(){
    return sharedPreferences!.getString(AppConstants.placeOrderData);
  }
  Future<void> clearPlaceOrder()async{
    await sharedPreferences!.remove(AppConstants.placeOrderData);
  }

  void clearPrevData() {
    _paymentMethod = '';
    _addressIndex = -1;
    _branchIndex = 0;
    _paymentMethodIndex = 0;
    _distance = -1;
  }

}
