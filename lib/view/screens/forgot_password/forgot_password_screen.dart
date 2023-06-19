import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/config_model.dart';
import 'package:flutter_grocery/helper/email_checker.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_app_bar.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_loader.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/custom_text_field.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/auth/widget/country_code_picker_widget.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  String? _countryDialCode;

  @override
  void initState() {
    super.initState();

    _countryDialCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.country!).dialCode;
  }

  @override
  Widget build(BuildContext context) {
    final ConfigModel configModel = Provider.of<SplashProvider>(context, listen: false).configModel!;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: (ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()): CustomAppBar(title: getTranslated('forgot_password', context))) as PreferredSizeWidget?,
      body: Center(child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(children: [
          Center(child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context)
                ? MediaQuery.of(context).size.height - 560 : MediaQuery.of(context).size.height),
            child: Container(
              width: width > 1170 ? 700 : width,
              padding: width > 1170 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
              margin: width > 1170 ? const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge) : null,
              decoration: width > 700 ? BoxDecoration(
                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 5, spreadRadius: 1)],
              ) : null,
              child: Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return Column(
                    children: [
                      const SizedBox(height: 55),
                      Image.asset(Images.closeLock, width: 142, height: 142, color: Theme.of(context).primaryColor),
                      const SizedBox(height: 40),

                      Center(child: Text(
                        getTranslated( configModel.phoneVerification!
                            ? 'please_enter_your_number': 'please_enter_your_email', context)!,
                        textAlign: TextAlign.center,
                        style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
                      )),

                      Padding(
                        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 80),

                            configModel.phoneVerification! ? Text(
                              getTranslated('mobile_number', context)!,
                              style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
                            ) : Text(
                              getTranslated('email', context)!,
                              style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
                            ),
                            const SizedBox(height: Dimensions.paddingSizeSmall),

                            configModel.phoneVerification! ? Row(children: [
                              CountryCodePickerWidget(
                                onChanged: (CountryCode countryCode) {
                                  _countryDialCode = countryCode.dialCode;
                                },
                                initialSelection: _countryDialCode,
                                favorite: [_countryDialCode!],
                                showDropDownButton: true,
                                padding: EdgeInsets.zero,
                                showFlagMain: true,
                                textStyle: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),

                              ),

                              Expanded(child: CustomTextField(
                                hintText: getTranslated('number_hint', context),
                                isShowBorder: true,
                                controller: _emailController,
                                inputAction: TextInputAction.done,
                                inputType: TextInputType.phone,
                              )),
                            ]) : CustomTextField(
                              hintText: getTranslated('demo_gmail', context),
                              isShowBorder: true,
                              controller: _emailController,
                              inputType: TextInputType.emailAddress,
                              inputAction: TextInputAction.done,
                            ),
                            const SizedBox(height: 24),

                            !auth.isForgotPasswordLoading
                                ? SizedBox(
                              width: double.infinity,
                              child: CustomButton(
                                buttonText: getTranslated('send', context),
                                onPressed: () {
                                  String email = _emailController.text.trim();
                                  if(configModel.phoneVerification!) {
                                    String phone = _countryDialCode!+email;
                                    if (email.isEmpty) {
                                      showCustomSnackBar(getTranslated('enter_phone_number', context)!);
                                    } else {
                                      Provider.of<AuthProvider>(context, listen: false).forgetPassword(phone).then((value) {
                                        if (value.isSuccess) {
                                          Navigator.of(context).pushNamed(
                                            RouteHelper.getVerifyRoute('forget-password', phone),
                                          );
                                        } else {
                                          showCustomSnackBar(value.message!);
                                        }
                                      });
                                    }
                                  }else {
                                    if (email.isEmpty) {
                                      showCustomSnackBar(getTranslated('enter_email_address', context)!);
                                    } else if (EmailChecker.isNotValid(email)) {
                                      showCustomSnackBar(getTranslated('enter_valid_email', context)!);
                                    } else {
                                      Provider.of<AuthProvider>(context, listen: false).forgetPassword(email).then((value) {
                                        if (value.isSuccess) {
                                          Navigator.of(context).pushNamed(
                                            RouteHelper.getVerifyRoute('forget-password', email),
                                          );
                                        } else {
                                          showCustomSnackBar(value.message!);
                                        }
                                      });
                                    }
                                  }
                                },
                              ),
                            )
                                : Center(
                                child: CustomLoader(color: Theme.of(context).primaryColor)),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          )),

          ResponsiveHelper.isDesktop(context)? const FooterView() : const SizedBox.shrink(),
        ]),
      )),
    );
  }
}
