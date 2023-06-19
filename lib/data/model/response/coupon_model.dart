class CouponModel {
  int? id;
  String? title;
  String? code;
  String? startDate;
  String? expireDate;
  double? minPurchase;
  double? maxDiscount;
  double? discount;
  String? discountType;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? couponType;

  CouponModel(
      {this.id,
        this.title,
        this.code,
        this.startDate,
        this.expireDate,
        this.minPurchase,
        this.maxDiscount,
        this.discount,
        this.discountType,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.couponType,
      });

  CouponModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    code = json['code'];
    startDate = json['start_date'];
    expireDate = json['expire_date'];
    minPurchase = json['min_purchase'].toDouble();
    maxDiscount = json['max_discount'].toDouble();
    discount = json['discount'].toDouble();
    discountType = json['discount_type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    couponType = json['coupon_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['code'] = code;
    data['start_date'] = startDate;
    data['expire_date'] = expireDate;
    data['min_purchase'] = minPurchase;
    data['max_discount'] = maxDiscount;
    data['discount'] = discount;
    data['discount_type'] = discountType;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['coupon_type'] = couponType;
    return data;
  }
}

class CouponApplyModel {
  final double  discount;
  final String  discountType;

  CouponApplyModel(this.discount, this.discountType);
}
