import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/data/model/response/userinfo_model.dart';

class OrderModel {
  int? _id;
  int? _userId;
  double? _orderAmount;
  double? _couponDiscountAmount;
  String? _couponDiscountTitle;
  String? _paymentStatus;
  String? _orderStatus;
  double? _totalTaxAmount;
  String? _paymentMethod;
  String? _transactionReference;
  int? _deliveryAddressId;
  String? _createdAt;
  String? _updatedAt;
  int? _checked;
  int? _deliveryManId;
  double? _deliveryCharge;
  String? _orderNote;
  String? _couponCode;
  String? _orderType;
  int? _branchId;
  int? _timeSlotId;
  String? _date;
  String? _deliveryDate;
  int? _detailsCount;
  UserInfoModel? _customer;
  DeliveryMan? _deliveryMan;
  DeliveryAddress? _deliveryAddress;
  double? _extraDiscount;

  OrderModel(
      {int? id,
        int? userId,
        double? orderAmount,
        double? couponDiscountAmount,
        String? couponDiscountTitle,
        String? paymentStatus,
        String? orderStatus,
        double? totalTaxAmount,
        String? paymentMethod,
        String? transactionReference,
        int? deliveryAddressId,
        String? createdAt,
        String? updatedAt,
        int? checked,
        int? deliveryManId,
        double? deliveryCharge,
        String? orderNote,
        String? couponCode,
        String? orderType,
        int? branchId,
        int? timeSlotId,
        String? date,
        String? deliveryDate,
        int? detailsCount,
        UserInfoModel? customer,
        DeliveryMan? deliveryMan,
      DeliveryAddress? deliveryAddress,
        double? extraDiscount,
      }) {
    _id = id;
    _userId = userId;
    _orderAmount = orderAmount;
    _couponDiscountAmount = couponDiscountAmount;
    _couponDiscountTitle = couponDiscountTitle;
    _paymentStatus = paymentStatus;
    _orderStatus = orderStatus;
    _totalTaxAmount = totalTaxAmount;
    _paymentMethod = paymentMethod;
    _transactionReference = transactionReference;
    _deliveryAddressId = deliveryAddressId;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _checked = checked;
    _deliveryManId = deliveryManId;
    _deliveryCharge = deliveryCharge;
    _orderNote = orderNote;
    _couponCode = couponCode;
    _orderType = orderType;
    _branchId = branchId;
    _timeSlotId = timeSlotId;
    _date = date;
    _deliveryDate = deliveryDate;
    _detailsCount = detailsCount;
    _customer = customer;
    _deliveryMan = deliveryMan;
    _deliveryAddress = deliveryAddress;
    _extraDiscount = extraDiscount;
  }

  int? get id => _id;
  int? get userId => _userId;
  double? get orderAmount => _orderAmount;
  double? get couponDiscountAmount => _couponDiscountAmount;
  String? get couponDiscountTitle => _couponDiscountTitle;
  String? get paymentStatus => _paymentStatus;
  String? get orderStatus => _orderStatus;
  double? get totalTaxAmount => _totalTaxAmount;
  // ignore: unnecessary_getters_setters
  String? get paymentMethod => _paymentMethod;
  // ignore: unnecessary_getters_setters
  set paymentMethod(String? value) {
    _paymentMethod = value;
  }
  String? get transactionReference => _transactionReference;
  int? get deliveryAddressId => _deliveryAddressId;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get checked => _checked;
  int? get deliveryManId => _deliveryManId;
  double? get deliveryCharge => _deliveryCharge;
  String? get orderNote => _orderNote;
  String? get couponCode => _couponCode;
  String? get orderType => _orderType;
  int? get branchId => _branchId;
  int? get timeSlotId => _timeSlotId;
  String? get date => _date;
  String? get deliveryDate => _deliveryDate;
  int? get detailsCount => _detailsCount;
  UserInfoModel? get customer => _customer;
  DeliveryMan? get deliveryMan => _deliveryMan;
  DeliveryAddress? get deliveryAddress => _deliveryAddress;
  double? get extraDiscount => _extraDiscount;

  OrderModel.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _userId = json['user_id'];
    _orderAmount = json['order_amount'].toDouble();
    _couponDiscountAmount = json['coupon_discount_amount'].toDouble();
    _couponDiscountTitle = json['coupon_discount_title'];
    _paymentStatus = json['payment_status'];
    _orderStatus = json['order_status'];
    _totalTaxAmount = json['total_tax_amount'].toDouble();
    _paymentMethod = json['payment_method'];
    _transactionReference = json['transaction_reference'];
    _deliveryAddressId = json['delivery_address_id'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _checked = json['checked'];
    _deliveryManId = json['delivery_man_id'];
    _deliveryCharge = json['delivery_charge'].toDouble();
    _orderNote = json['order_note'];
    _couponCode = json['coupon_code'];
    _orderType = json['order_type'];
    _branchId = json['branch_id'];
    _timeSlotId = json['time_slot_id'];
    _date = json['date'];
    _deliveryDate = json['delivery_date'];
    _detailsCount = json['details_count'];
    _customer = json['customer'] != null
        ? UserInfoModel.fromJson(json['customer'])
        : null;
    _deliveryMan = json['delivery_man'] != null
        ? DeliveryMan.fromJson(json['delivery_man'])
        : null;
    _deliveryAddress = json['delivery_address'] != null
        ? DeliveryAddress.fromJson(json['delivery_address'])
        : null;
    if(json['extra_discount'] != null){
      try{
        _extraDiscount = double.parse(json['extra_discount']);
      }catch(e){
        _extraDiscount = json['extra_discount'];
      }
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['user_id'] = _userId;
    data['order_amount'] = _orderAmount;
    data['coupon_discount_amount'] = _couponDiscountAmount;
    data['coupon_discount_title'] = _couponDiscountTitle;
    data['payment_status'] = _paymentStatus;
    data['order_status'] = _orderStatus;
    data['total_tax_amount'] = _totalTaxAmount;
    data['payment_method'] = _paymentMethod;
    data['transaction_reference'] = _transactionReference;
    data['delivery_address_id'] = _deliveryAddressId;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['checked'] = _checked;
    data['delivery_man_id'] = _deliveryManId;
    data['delivery_charge'] = _deliveryCharge;
    data['order_note'] = _orderNote;
    data['coupon_code'] = _couponCode;
    data['order_type'] = _orderType;
    data['branch_id'] = _branchId;
    data['time_slot_id'] = _timeSlotId;
    data['date'] = _date;
    data['delivery_date'] = _deliveryDate;
    data['details_count'] = _detailsCount;
    if (_customer != null) {
      data['customer'] = _customer!.toJson();
    }
    if (_deliveryMan != null) {
      data['delivery_man'] = _deliveryMan!.toJson();
    }
    if (_deliveryAddress != null) {
      data['delivery_address'] = _deliveryAddress!.toJson();
    }
    data['extra_discount'] = _extraDiscount;
    return data;
  }
}

class DeliveryMan {
  int? _id;
  String? _fName;
  String? _lName;
  String? _phone;
  String? _email;
  String? _identityNumber;
  String? _identityType;
  String? _identityImage;
  String? _image;
  String? _password;
  String? _createdAt;
  String? _updatedAt;
  String? _authToken;
  String? _fcmToken;
  List<Rating>? _rating;

  DeliveryMan(
      {int? id,
        String? fName,
        String? lName,
        String? phone,
        String? email,
        String? identityNumber,
        String? identityType,
        String? identityImage,
        String? image,
        String? password,
        String? createdAt,
        String? updatedAt,
        String? authToken,
        String? fcmToken,
        List<Rating>? rating}) {
    _id = id;
    _fName = fName;
    _lName = lName;
    _phone = phone;
    _email = email;
    _identityNumber = identityNumber;
    _identityType = identityType;
    _identityImage = identityImage;
    _image = image;
    _password = password;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _authToken = authToken;
    _fcmToken = fcmToken;
    _rating = rating;
  }

  int? get id => _id;
  String? get fName => _fName;
  String? get lName => _lName;
  String? get phone => _phone;
  String? get email => _email;
  String? get identityNumber => _identityNumber;
  String? get identityType => _identityType;
  String? get identityImage => _identityImage;
  String? get image => _image;
  String? get password => _password;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  String? get authToken => _authToken;
  String? get fcmToken => _fcmToken;
  List<Rating>? get rating => _rating;

  DeliveryMan.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _fName = json['f_name'];
    _lName = json['l_name'];
    _phone = json['phone'];
    _email = json['email'];
    _identityNumber = json['identity_number'];
    _identityType = json['identity_type'];
    _identityImage = json['identity_image'];
    _image = json['image'];
    _password = json['password'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _authToken = json['auth_token'];
    _fcmToken = json['fcm_token'];
    if (json['rating'] != null) {
      _rating = [];
      json['rating'].forEach((v) {
        _rating!.add(Rating.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['f_name'] = _fName;
    data['l_name'] = _lName;
    data['phone'] = _phone;
    data['email'] = _email;
    data['identity_number'] = _identityNumber;
    data['identity_type'] = _identityType;
    data['identity_image'] = _identityImage;
    data['image'] = _image;
    data['password'] = _password;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['auth_token'] = _authToken;
    data['fcm_token'] = _fcmToken;
    if (_rating != null) {
      data['rating'] = _rating!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DeliveryAddress {
  int? _id;
  String? _addressType;
  String? _contactPersonNumber;
  String? _address;
  String? _latitude;
  String? _longitude;
  String? _createdAt;
  String? _updatedAt;
  int? _userId;
  String? _contactPersonName;

  DeliveryAddress(
      {int? id,
        String? addressType,
        String? contactPersonNumber,
        String? address,
        String? latitude,
        String? longitude,
        String? createdAt,
        String? updatedAt,
        int? userId,
        String? contactPersonName}) {
    _id = id;
    _addressType = addressType;
    _contactPersonNumber = contactPersonNumber;
    _address = address;
    _latitude = latitude;
    _longitude = longitude;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
    _userId = userId;
    _contactPersonName = contactPersonName;
  }

  int? get id => _id;
  String? get addressType => _addressType;
  String? get contactPersonNumber => _contactPersonNumber;
  String? get address => _address;
  String? get latitude => _latitude;
  String? get longitude => _longitude;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;
  int? get userId => _userId;
  String? get contactPersonName => _contactPersonName;

  DeliveryAddress.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _addressType = json['address_type'];
    _contactPersonNumber = json['contact_person_number'];
    _address = json['address'];
    _latitude = json['latitude'];
    _longitude = json['longitude'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
    _userId = json['user_id'];
    _contactPersonName = json['contact_person_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _id;
    data['address_type'] = _addressType;
    data['contact_person_number'] = _contactPersonNumber;
    data['address'] = _address;
    data['latitude'] = _latitude;
    data['longitude'] = _longitude;
    data['created_at'] = _createdAt;
    data['updated_at'] = _updatedAt;
    data['user_id'] = _userId;
    data['contact_person_name'] = _contactPersonName;
    return data;
  }
}