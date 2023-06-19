import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/base/error_response.dart';
import 'package:flutter_grocery/data/model/response/response_model.dart';
import 'package:flutter_grocery/data/model/response/userinfo_model.dart';
import 'package:flutter_grocery/data/repository/profile_repo.dart';
import 'package:flutter_grocery/helper/api_checker.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileRepo? profileRepo;

  ProfileProvider({required this.profileRepo});

  UserInfoModel? _userInfoModel;

  UserInfoModel? get userInfoModel => _userInfoModel;

   getUserInfo() async {
    _isLoading = true;
    ApiResponse apiResponse = await profileRepo!.getUserInfo();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

      _userInfoModel = UserInfoModel.fromJson(apiResponse.response!.data);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    _isLoading = false;
    notifyListeners();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  File? _file;
  PickedFile? _data;

  PickedFile? get data => _data;

  File? get file => _file;
  final picker = ImagePicker();

  void choosePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50, maxHeight: 500, maxWidth: 500);
    if (pickedFile != null) {
      _file = File(pickedFile.path);
    }
    notifyListeners();
  }

  void pickImage() async {
    _data = PickedFile(await picker.pickImage(source: ImageSource.gallery, imageQuality: 80).then((value) => value!.path));
    notifyListeners();
  }

  Future<ResponseModel> updateUserInfo(UserInfoModel updateUserModel, String pass, File? file, PickedFile? data, String token) async {
    _isLoading = true;
    notifyListeners();
    ResponseModel responseModel;
    http.StreamedResponse response = await profileRepo!.updateProfile(updateUserModel, pass, file, data, token);
    _isLoading = false;
    if (response.statusCode == 200) {
      Map map = jsonDecode(await response.stream.bytesToString());
      String? message = map["message"];
      _userInfoModel = updateUserModel;
      responseModel = ResponseModel(true, message);
    } else {
      responseModel = ResponseModel(
        false, ErrorResponse.fromJson(jsonDecode(await response.stream.bytesToString())).errors![0].message,
      );
    }
    notifyListeners();
    return responseModel;
  }
}
