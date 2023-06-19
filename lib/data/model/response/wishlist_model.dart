import 'package:flutter_grocery/data/model/response/product_model.dart';
class WishListModel {
  int? _totalSize;
  String? _limit;
  String? _offset;
  List<Product>? _products;

  WishListModel(
      {int? totalSize,
        String? limit,
        String? offset,
        List<Product>? products}) {
    if (totalSize != null) {
      _totalSize = totalSize;
    }
    if (limit != null) {
      _limit = limit;
    }
    if (offset != null) {
      _offset = offset;
    }
    if (products != null) {
      _products = products;
    }
  }

  set totalSize(int totalSize) => _totalSize = totalSize;
  set limit(String limit) => _limit = limit;

  set offset(String offset) => _offset = offset;
  List<Product>? get products => _products;

  WishListModel.fromJson(Map<String, dynamic> json) {
    _totalSize = int.tryParse('${json['total_size']}');
    _limit = '${json['limit']}';
    _offset = '${json['offset']}';
    if (json['products'] != null) {
      _products = <Product>[];
      json['products'].forEach((v) {
        _products!.add(Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = _totalSize;
    data['limit'] = _limit;
    data['offset'] = _offset;
    if (_products != null) {
      data['products'] = _products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}


