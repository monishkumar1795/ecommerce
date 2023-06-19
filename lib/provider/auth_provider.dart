// ignore_for_file: empty_catches

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/base/error_response.dart';
import 'package:flutter_grocery/data/model/response/response_model.dart';
import 'package:flutter_grocery/data/model/response/signup_model.dart';
import 'package:flutter_grocery/data/model/response/user_log_data.dart';
import 'package:flutter_grocery/data/model/social_login_model.dart';
import 'package:flutter_grocery/data/repository/auth_repo.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

import '../helper/api_checker.dart';
import '../view/screens/auth/login_screen.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepo? authRepo;

  AuthProvider({required this.authRepo});

  // for registration section
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String? _registrationErrorMessage = '';

  String? get registrationErrorMessage => _registrationErrorMessage;
  // GoogleSignIn _googleSignIn = GoogleSignIn();
  // GoogleSignInAccount googleAccount;

  updateRegistrationErrorMessage(String message) {
    _registrationErrorMessage = message;
    notifyListeners();
  }

  Future<ResponseModel> registration(SignUpModel signUpModel) async {
    _isLoading = true;
    _registrationErrorMessage = '';
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.registration(signUpModel);
    ResponseModel responseModel;
    String? token;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      try{
        if(map["token"]== null || map["token"] == 'null') {
          token = map["temporary_token"];
        }else {
          token = map["token"];
        }
      }catch(e) {
        token = map["temporary_token"];
      }

      login(signUpModel.email, signUpModel.password);


      authRepo!.saveUserToken(token!);
      await authRepo!.updateToken();
      responseModel = ResponseModel(true, 'successful');
    } else {

      _registrationErrorMessage = ErrorResponse.fromJson(apiResponse.error).errors![0].message;
      responseModel = ResponseModel(false, _registrationErrorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  // for login section
  String? _loginErrorMessage = '';

  String? get loginErrorMessage => _loginErrorMessage;

  Future<ResponseModel> login(String? email, String? password) async {
    _isLoading = true;
    _loginErrorMessage = '';
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.login(email: email, password: password);
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      String token = map["token"];
      authRepo!.saveUserToken(token);
      await authRepo!.updateToken();
      responseModel = ResponseModel(true, 'successful');
    } else {

      _loginErrorMessage = ErrorResponse.fromJson(apiResponse.error).errors![0].message;
      responseModel = ResponseModel(false,_loginErrorMessage);
    }
    _isLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future deleteUser(BuildContext context) async {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(context, listen: false);
    _isLoading = true;
    notifyListeners();
    ApiResponse response = await authRepo!.deleteUser();
    _isLoading = false;
    if (response.response!.statusCode == 200) {
      splashProvider.removeSharedData();
      showCustomSnackBar('your_account_remove_successfully'.tr );
      Navigator.pushAndRemoveUntil(Get.context!, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
    }else{
      Navigator.of(Get.context!).pop();
      ApiChecker.checkApi(response);
    }
  }

  // for forgot password
  bool _isForgotPasswordLoading = false;

  bool get isForgotPasswordLoading => _isForgotPasswordLoading;

  Future<ResponseModel> forgetPassword(String? email) async {
    _isForgotPasswordLoading = true;
    resendButtonLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.forgetPassword(email);
    ResponseModel responseModel;

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {
      responseModel = ResponseModel(false, ErrorResponse.fromJson(apiResponse.error).errors![0].message);
    }
    _isForgotPasswordLoading = false;
    resendButtonLoading = false;

    notifyListeners();

    return responseModel;
  }

  Timer? _timer;
  int? currentTime;

  void startVerifyTimer(){
    _timer?.cancel();
    currentTime = Provider.of<SplashProvider>(Get.context!, listen: false).configModel!.otpResendTime ?? 0;


   _timer =  Timer.periodic(const Duration(seconds: 1), (_){

      if(currentTime! > 0) {
        currentTime = currentTime! - 1;
      }else{
        _timer?.cancel();
      }notifyListeners();
    });

  }



  Future<ResponseModel> resetPassword(String? mail, String? resetToken, String password, String confirmPassword) async {
    _isForgotPasswordLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.resetPassword(mail, resetToken, password, confirmPassword);
    _isForgotPasswordLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {

      responseModel = ResponseModel(false, ErrorResponse.fromJson(apiResponse.error).errors![0].message);
    }
    return responseModel;
  }

  Future<void> updateToken() async {
    ApiResponse apiResponse = await authRepo!.updateToken();
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {

    } else {
      //ErrorResponse.fromJson(apiResponse.error).errors[0].message;
    }
  }

  // for phone verification
  bool _isPhoneNumberVerificationButtonLoading = false;
  bool resendButtonLoading = false;

  bool get isPhoneNumberVerificationButtonLoading => _isPhoneNumberVerificationButtonLoading;
  String? _verificationMsg = '';

  String? get verificationMessage => _verificationMsg;
  String _email = '';

  String get email => _email;

  updateEmail(String email) {
    _email = email;
    notifyListeners();
  }

  Future<ResponseModel> checkEmail(String? email) async {
    _isPhoneNumberVerificationButtonLoading = true;
    resendButtonLoading = true;
    _verificationMsg = '';
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.checkEmail(email);
    _isPhoneNumberVerificationButtonLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      // startVerifyTimer();

      responseModel = ResponseModel(true, apiResponse.response!.data["token"]);
    } else {
      String? errorMessage = ErrorResponse.fromJson(apiResponse.error).errors![0].message;

      responseModel = ResponseModel(false, errorMessage);
      _verificationMsg = errorMessage;
    }
    resendButtonLoading = false;
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> verifyToken(String? email) async {
    _isPhoneNumberVerificationButtonLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.verifyToken(email, _verificationCode);
    _isPhoneNumberVerificationButtonLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {

      responseModel = ResponseModel(false, ErrorResponse.fromJson(apiResponse.error).errors![0].message);
    }
    return responseModel;
  }

  Future<ResponseModel> verifyEmail(String? email) async {
    _isPhoneNumberVerificationButtonLoading = true;
    _verificationMsg = '';
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.verifyEmail(email, _verificationCode);
    _isPhoneNumberVerificationButtonLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {
      String? errorMessage = ErrorResponse.fromJson(apiResponse.error).errors![0].message;

      responseModel = ResponseModel(false, errorMessage);
      _verificationMsg = errorMessage;
    }
    notifyListeners();
    return responseModel;
  }


  //phone

  Future<ResponseModel> checkPhone(String phone) async {
    _isPhoneNumberVerificationButtonLoading = true;
    _verificationMsg = '';
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.checkPhone(phone);
    _isPhoneNumberVerificationButtonLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      responseModel = ResponseModel(true, apiResponse.response!.data["token"]);
    } else {
      String errorMessage = ApiChecker.getError(apiResponse).errors![0].message ?? '';

      responseModel = ResponseModel(false, errorMessage);
      _verificationMsg = errorMessage;
    }
    notifyListeners();
    return responseModel;
  }

  Future<ResponseModel> verifyPhone(String phone) async {
    _isPhoneNumberVerificationButtonLoading = true;
    _verificationMsg = '';
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.verifyPhone(phone, _verificationCode);
    _isPhoneNumberVerificationButtonLoading = false;
    notifyListeners();
    ResponseModel responseModel;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      // startVerifyTimer();
      responseModel = ResponseModel(true, apiResponse.response!.data["message"]);
    } else {
      String? errorMessage = ErrorResponse.fromJson(apiResponse.error).errors![0].message;
      responseModel = ResponseModel(false, errorMessage);
      _verificationMsg = errorMessage;
    }
    notifyListeners();
    return responseModel;
  }



  // for verification Code
  String _verificationCode = '';

  String get verificationCode => _verificationCode;
  bool _isEnableVerificationCode = false;

  bool get isEnableVerificationCode => _isEnableVerificationCode;

  updateVerificationCode(String query) {
    if (query.length == 4) {
      _isEnableVerificationCode = true;
    } else {
      _isEnableVerificationCode = false;
    }
    _verificationCode = query;
    notifyListeners();
  }

  // for Remember Me Section

  bool _isActiveRememberMe = false;

  bool get isActiveRememberMe => _isActiveRememberMe;

  toggleRememberMe() {
    _isActiveRememberMe = !_isActiveRememberMe;
    notifyListeners();
  }
  clearRememberMe(){
    _isActiveRememberMe = false;
    notifyListeners();
  }

  bool isLoggedIn() {
    return authRepo!.isLoggedIn();
  }

  Future<bool> clearSharedData() async {
    return await authRepo!.clearSharedData();
  }

  void saveUserNumberAndPassword(UserLogData userLogData) {
    authRepo!.saveUserNumberAndPassword(jsonEncode(userLogData.toJson()));
  }

  UserLogData? getUserData() {
    UserLogData? userData;
    try{
      userData = UserLogData.fromJson(jsonDecode(authRepo!.getUserLogData()));
    }catch(error) {
      debugPrint('error ====> $error');

    }
    return userData;
  }

  Future<bool> clearUserLogData() async {
    return authRepo!.clearUserLog();
  }

  String getUserToken() {
    return authRepo!.getUserToken();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
  );
  GoogleSignInAccount? googleAccount;

  Future<GoogleSignInAuthentication> googleLogin() async {
    GoogleSignInAuthentication auth;
    googleAccount = await _googleSignIn.signIn();
    auth = await googleAccount!.authentication;
    return auth;
  }

  Future socialLogin(SocialLoginModel socialLogin, Function callback) async {
    _isLoading = true;
    notifyListeners();
    ApiResponse apiResponse = await authRepo!.socialLogin(socialLogin);
    _isLoading = false;
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      Map map = apiResponse.response!.data;
      String? message = '';
      String? token = '';
      try{
        message = map['error_message'] ?? '';

      }catch(e){

      }
      try{
        token = map['token'];

      }catch(e){

      }

      if(token != null){
        authRepo!.saveUserToken(token);
        await updateFirebaseToken();
      }

      callback(true, token, message);
      notifyListeners();

    }else {

      String? errorMessage = ErrorResponse.fromJson(apiResponse.error).errors![0].message;
      callback(false, '',errorMessage);
      notifyListeners();
    }
  }

  Future<void> socialLogout() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.disconnect();
    await FacebookAuth.instance.logOut();
  }

  Future updateFirebaseToken() async {
    if(await authRepo!.getDeviceToken() != '@'){
      await authRepo!.updateToken();
    }
  }


}
