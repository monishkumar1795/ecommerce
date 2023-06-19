import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/category_model.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/data/repository/category_repo.dart';
import 'package:flutter_grocery/helper/api_checker.dart';
import 'package:flutter_grocery/provider/localization_provider.dart';
import 'package:provider/provider.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryRepo? categoryRepo;

  CategoryProvider({required this.categoryRepo});

  int _categorieselectedIndex = -1;
  int _categoryIndex = 0;

  int get categorieselectedIndex => _categorieselectedIndex;
  int get categoryIndex => _categoryIndex;

  List<CategoryModel>? _categoryList;
  List<CategoryModel>? _subCategoryList = [];
  List<Product> _categoryProductList = [];
  final List<Product> _categoryAllProductList = [];
  CategoryModel? _categoryModel;
  bool _pageFirstIndex = true;
  bool _pageLastIndex = false;

  List<CategoryModel>? get categoryList => _categoryList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;
  List<Product> get categoryProductList => _categoryProductList;
  CategoryModel? get categoryModel => _categoryModel;
  bool get pageFirstIndex => _pageFirstIndex;
  bool get pageLastIndex => _pageLastIndex;


  Future<ApiResponse> getCategoryList( BuildContext context,String? languageCode, bool reload, {int? id}) async {
    ApiResponse apiResponse = await categoryRepo!.getCategoryList(languageCode);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _categoryList = [];
      apiResponse.response!.data.forEach((category) => _categoryList!.add(CategoryModel.fromJson(category)));
      _categorieselectedIndex = -1;
      _categoryIndex = 0;
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
    return apiResponse;
  }

  void getCategory(int? id, BuildContext context) async {
    if(_categoryList == null) {
      await getCategoryList(context,Provider.of<LocalizationProvider>(context, listen: false).locale.languageCode, true);
      _categoryModel = _categoryList!.firstWhere((category) => category.id == id);
      notifyListeners();
    }else {
      try{
        _categoryModel = _categoryList!.firstWhere((category) => category.id == id);
      }catch(e){
        debugPrint('error : $e');
      }
    }
  }

  void getSubCategoryList(BuildContext context, String categoryID, String languageCode) async {
    _subCategoryList = null;

    ApiResponse apiResponse = await categoryRepo!.getSubCategoryList(categoryID,languageCode);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _subCategoryList = [];
      apiResponse.response!.data.forEach((category) => _subCategoryList!.add(CategoryModel.fromJson(category)));
      getCategoryProductList(categoryID,languageCode);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void getCategoryProductList(String categoryID,String languageCode) async {
    _categoryProductList = [];

    ApiResponse apiResponse = await categoryRepo!.getCategoryProductList(categoryID,languageCode);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _categoryProductList = [];
      apiResponse.response!.data.forEach((category) => _categoryProductList.add(Product.fromJson(category)));
      _categoryAllProductList.addAll(_categoryProductList);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  int _selectCategory = -1;

  int get selectCategory => _selectCategory;

  updateSelectCategory(int index) {
    _selectCategory = index;
    notifyListeners();
  }

  void changeSelectedIndex(int selectedIndex, {bool notify = true}) {
    _categorieselectedIndex = selectedIndex;
    if(notify) {
      notifyListeners();
    }
  }

  void changeIndex(int selectedIndex, {bool notify = true}) {
    _categoryIndex = selectedIndex;
    if(notify) {
      notifyListeners();
    }
  }


  updateProductCurrentIndex(int index, int totalLength) {
    if(index > 0) {
      _pageFirstIndex = false;
      notifyListeners();
    }else{
      _pageFirstIndex = true;
      notifyListeners();
    }
    if(index + 1  == totalLength) {
      _pageLastIndex = true;
      notifyListeners();
    }else {
      _pageLastIndex = false;
      notifyListeners();
    }
  }

}
