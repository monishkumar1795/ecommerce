import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/helper/email_checker.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/base/custom_button.dart';
import 'package:flutter_grocery/view/base/custom_snackbar.dart';
import 'package:flutter_grocery/view/base/custom_text_field.dart';
import 'package:flutter_grocery/view/base/footer_view.dart';
import 'package:flutter_grocery/view/screens/auth/create_account_screen.dart';
import 'package:flutter_grocery/view/screens/auth/widget/country_code_picker_widget.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  TextEditingController? _emailController;
  final FocusNode _emailFocus = FocusNode();
  bool email = true;
  bool phone =false;
  String? countryCode;
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    countryCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.country!).code;
  }


  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()) :null,
      body: SafeArea(
        child: Scrollbar(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.all(0) : const EdgeInsets.all(Dimensions.paddingSizeLarge),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height - 560 : MediaQuery.of(context).size.height),
                child: Center(
                  child: Column(
                    children: [
                      ResponsiveHelper.isDesktop(context) ? const SizedBox(height: 50,) : const SizedBox(),
                      Container(
                        width: size.width > 700 ? 700 : size.width,
                        padding: ResponsiveHelper.isDesktop(context)? const EdgeInsets.symmetric(horizontal: 100,vertical: 50) : size.width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
                        decoration: size.width > 700 ? BoxDecoration(
                          color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 5, spreadRadius: 1)],
                        ) : null,
                        child: Consumer<AuthProvider>(
                          builder: (context, authProvider, child) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 30),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Image.asset(
                                    Images.appLogo,
                                    height: ResponsiveHelper.isDesktop(context) ? MediaQuery.of(context).size.height*0.15 : MediaQuery.of(context).size.height / 4.5,
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                  child: Text(
                                getTranslated('signup', context)!,
                                style: poppinsMedium.copyWith(fontSize: 24, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                              )),
                              const SizedBox(height: 35),
                              Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification! ? Text(
                                getTranslated('email', context)!,
                                style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
                              ) : Text(
                                getTranslated('mobile_number', context)!,
                                style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
                              ),
                              const SizedBox(height: Dimensions.paddingSizeSmall),
                              Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification! ? CustomTextField(
                                hintText: getTranslated('demo_gmail', context),
                                isShowBorder: true,
                                inputAction: TextInputAction.done,
                                inputType: TextInputType.emailAddress,
                                controller: _emailController,
                                focusNode: _emailFocus,
                              ) : Row(children: [
                                CountryCodePickerWidget(
                                  onChanged: (CountryCode value) {
                                    countryCode = value.code;
                                  },
                                  initialSelection: countryCode,
                                  favorite: [countryCode!],
                                  showDropDownButton: true,
                                  padding: EdgeInsets.zero,
                                  showFlagMain: true,
                                  textStyle: TextStyle(color: Theme.of(context).textTheme.displayLarge!.color),

                                ),
                                Expanded(child: CustomTextField(
                                  hintText: getTranslated('number_hint', context),
                                  isShowBorder: true,
                                  controller: _emailController,
                                  inputType: TextInputType.phone,
                                  inputAction: TextInputAction.done,
                                )),
                              ]),
                              const SizedBox(height: 6),
                              const SizedBox(height: Dimensions.paddingSizeSmall),

                              const Padding(padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge), child: Divider(height: 1)),


                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  authProvider.verificationMessage!.isNotEmpty
                                      ? CircleAvatar(backgroundColor: Theme.of(context).colorScheme.error, radius: 5)
                                      : const SizedBox.shrink(),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      authProvider.verificationMessage ?? "",
                                      style: Theme.of(context).textTheme.displayMedium!.copyWith(
                                            fontSize: Dimensions.fontSizeSmall,
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                    ),
                                  )
                                ],
                              ),

                              // for continue button
                              const SizedBox(height: 12),
                              !authProvider.isPhoneNumberVerificationButtonLoading
                                  ? CustomButton(
                                buttonText: getTranslated('continue', context),
                                onPressed: () {
                                  String email = _emailController!.text.trim();
                                  if (email.isEmpty) {
                                    if(Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification!) {
                                      showCustomSnackBar(getTranslated('enter_email_address', context)!);
                                    }else {
                                      showCustomSnackBar(getTranslated('enter_phone_number', context)!);
                                    }
                                  }else if (Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification!
                                      && EmailChecker.isNotValid(email)) {
                                    showCustomSnackBar(getTranslated('enter_valid_email', context)!);
                                  }else {
                                    if(Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification!){
                                      authProvider.checkEmail(email).then((value) async {
                                        if (value.isSuccess) {
                                          authProvider.updateEmail(email);
                                          if (value.message == 'active') {
                                            Navigator.of(context).pushNamed(
                                              RouteHelper.getVerifyRoute('sign-up', email),
                                            );
                                          } else {
                                            Navigator.of(context).pushNamed(RouteHelper.createAccount, arguments: const CreateAccountScreen());
                                          }
                                        }
                                      });

                                    }else{
                                      String phoneNumber = '${CountryCode.fromCountryCode(countryCode!).dialCode}$email';
                                      authProvider.checkPhone(phoneNumber).then((value) async {
                                        if (value.isSuccess) {
                                          authProvider.updateEmail(phoneNumber);
                                          if (value.message == 'active') {
                                            Navigator.of(context).pushNamed(
                                              RouteHelper.getVerifyRoute('sign-up', phoneNumber),
                                            );
                                          } else {
                                            Navigator.of(context).pushNamed(RouteHelper.createAccount, arguments: const CreateAccountScreen());
                                          }
                                        }
                                      });

                                    }

                                  }
                                },
                              ) : Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor))),

                              // for create an account
                              const SizedBox(height: 10),
                              InkWell(
                                onTap: ()=> Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        getTranslated('already_have_account', context)!,
                                        style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor.withOpacity(0.6)),
                                      ),
                                      const SizedBox(width: Dimensions.paddingSizeSmall),
                                      Text(
                                        getTranslated('login', context)!,
                                        style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      ),
                      ResponsiveHelper.isDesktop(context) ? const SizedBox(height: 50,) : const SizedBox(),
                      ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
