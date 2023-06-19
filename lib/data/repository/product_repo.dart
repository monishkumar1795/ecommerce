import 'package:dio/dio.dart';
import 'package:flutter_grocery/data/datasource/remote/dio/dio_client.dart';
import 'package:flutter_grocery/data/datasource/remote/exception/api_error_handler.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/helper/product_type.dart';
import 'package:flutter_grocery/utill/app_constants.dart';

class ProductRepo {
  final DioClient? dioClient;

  ProductRepo({required this.dioClient});

  Future<ApiResponse> getPopularProductList(String offset, String languageCode) async {
    try {
      final response = await dioClient!.get('${AppConstants.popularProductURI}?limit=10&&offset=$offset',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);

    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getLatestProductList(String offset) async {
    try {
      final response = await dioClient!.get('${AppConstants.latestProductURI}?limit=10&&offset=$offset');
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getItemList(String offset, String? languageCode, String? productType) async {
    try {
      String? apiUrl;
      if(productType == ProductType.featuredItem){
        apiUrl = AppConstants.featuredProduct;
      }else if(productType == ProductType.dailyItem){
        apiUrl = AppConstants.dailyItemUri;
      } else if(productType == ProductType.popularProduct){
        apiUrl = AppConstants.popularProductURI;
      }else if(productType == ProductType.mostReviewed){
        apiUrl = AppConstants.mostReviewedProduct;
      }
      else if(productType == ProductType.recommendProduct){
        apiUrl = AppConstants.recommendProduct;
      } else if(productType == ProductType.trendingProduct){
        apiUrl = AppConstants.trendingProduct;
      }
      //_apiUrl = AppConstants.popularProductURI;

      final response = await dioClient!.get('$apiUrl?limit=10&&offset=$offset',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getProductDetails(String productID, String languageCode, bool searchQuery) async {
    try {
      String params = productID;
      if(searchQuery) {
        params = '$productID?attribute=product';
      }
      final response = await dioClient!.get('${AppConstants.productDetailsUri}$params',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> searchProduct(String productId, String languageCode) async {
    try {
      final response = await dioClient!.get(
        '${AppConstants.searchProductUri}$productId',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponse> getBrandOrCategoryProductList(String id, String languageCode) async {
    try {
      String uri = '${AppConstants.categoryProductUri}$id';

      final response = await dioClient!.get(uri, options: Options(headers: {'X-localization': languageCode}));
      return ApiResponse.withSuccess(response);
    } catch (e) {
      return ApiResponse.withError(ApiErrorHandler.getMessage(e));
    }
  }

}
