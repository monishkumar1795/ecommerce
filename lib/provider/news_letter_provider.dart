import 'package:flutter/material.dart';
import 'package:flutter_grocery/localization/app_localization.dart';
import '../data/model/response/base/api_response.dart';
import '../data/repository/news_letter_repo.dart';
import '../view/base/custom_snackbar.dart';

class NewsLetterProvider extends ChangeNotifier {
  final NewsLetterRepo? newsLetterRepo;
  NewsLetterProvider({required this.newsLetterRepo});


  Future<void> addToNewsLetter( String email) async {
    ApiResponse apiResponse = await newsLetterRepo!.addToNewsLetter(email);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      showCustomSnackBar('successfully_subscribe'.tr,isError: false);
      notifyListeners();
    } else {

      showCustomSnackBar('mail_already_exist'.tr);
    }
  }
}
