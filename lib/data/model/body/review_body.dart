class ReviewBody {
  String? _productId;
  String? _orderId;
  String? _deliveryManId;
  String? _comment;
  String? _rating;
  List<String>? _fileUpload;

  ReviewBody(
      {String? productId,
        String? orderId,
        String? deliveryManId,
        String? comment,
        String? rating,
        List<String>? fileUpload}) {
    _productId = productId;
    _orderId = orderId;
    _deliveryManId = deliveryManId;
    _comment = comment;
    _rating = rating;
    _fileUpload = fileUpload;
  }

  String? get productId => _productId;
  String? get orderId => _orderId;
  String? get deliveryManId => _deliveryManId;
  String? get comment => _comment;
  String? get rating => _rating;
  List<String>? get fileUpload => _fileUpload;

  ReviewBody.fromJson(Map<String, dynamic> json) {
    _productId = json['product_id'];
    _orderId = json['order_id'];
    _deliveryManId = json['delivery_man_id'];
    _comment = json['comment'];
    _rating = json['rating'];
    _fileUpload = json['fileUpload'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['product_id'] = _productId;
    data['order_id'] = _orderId;
    data['delivery_man_id'] = _deliveryManId;
    data['comment'] = _comment;
    data['rating'] = _rating;
    data['fileUpload'] = _fileUpload;
    return data;
  }
}
