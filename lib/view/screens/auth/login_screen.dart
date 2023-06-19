import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/user_log_data.dart';
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
import 'package:flutter_grocery/view/screens/auth/signup_screen.dart';
import 'package:flutter_grocery/view/screens/auth/widget/country_code_picker_widget.dart';
import 'package:flutter_grocery/view/screens/forgot_password/forgot_password_screen.dart';
import 'package:flutter_grocery/view/base/web_app_bar/web_app_bar.dart';
import 'package:flutter_grocery/view/screens/menu/menu_screen.dart';
import 'package:provider/provider.dart';

import 'widget/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _numberFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  TextEditingController? _emailController;
  TextEditingController? _passwordController;
  GlobalKey<FormState>? _formKeyLogin;
  bool email = true;
  bool phone =false;
  String? countryCode;

  @override
  void initState() {
    super.initState();
    _formKeyLogin = GlobalKey<FormState>();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();

    UserLogData? userData = Provider.of<AuthProvider>(context, listen: false).getUserData();


    if(userData != null) {
      if(Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification!) {
        _emailController!.text = userData.email!;
      }else{
        _emailController!.text = userData.phoneNumber!;
      }

      _passwordController!.text = userData.password!;


      countryCode = userData.countryCode;
    }else{
      countryCode = CountryCode.fromCountryCode(Provider.of<SplashProvider>(context, listen: false).configModel!.country!).code;
    }
  }

  @override
  void dispose() {
    _emailController!.dispose();
    _passwordController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final configModel = Provider.of<SplashProvider>(context,listen: false).configModel!;
    final socialStatus = configModel.socialLoginStatus;

    return Scaffold(
      appBar: ResponsiveHelper.isDesktop(context)? const PreferredSize(preferredSize: Size.fromHeight(120), child: WebAppBar()) :null,
      body: SafeArea(child: Center(child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: ResponsiveHelper.isDesktop(context)
            ? MediaQuery.of(context).size.height - 560 : MediaQuery.of(context).size.height),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeLarge),
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            ResponsiveHelper.isDesktop(context) ? const SizedBox(height: 30,) : const SizedBox(),
            Center(child: Container(
              width: width > 700 ? 700 : width,
              padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: 100,vertical: 50) :  width > 700 ? const EdgeInsets.all(Dimensions.paddingSizeDefault) : null,
              decoration: width > 700 ? BoxDecoration(
                color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(10),
                boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 5, spreadRadius: 1)],
              ) : null,
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, child) => Form(key: _formKeyLogin, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset(
                        Images.appLogo,
                        height: ResponsiveHelper.isDesktop(context)
                            ? MediaQuery.of(context).size.height*0.15
                            : MediaQuery.of(context).size.height / 4.5,
                        fit: BoxFit.scaleDown,
                      ),
                    )),
                    //SizedBox(height: 20),

                    Center(child: Text(
                      getTranslated('login', context)!,
                      style: poppinsMedium.copyWith(fontSize: 24, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                    )),
                    const SizedBox(height: 35),

                    Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification! ?
                    Text(
                      getTranslated('email', context)!,
                      style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
                    ):Text(
                      getTranslated('mobile_number', context)!,
                      style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification! ?
                    CustomTextField(
                      hintText: getTranslated('demo_gmail', context),
                      isShowBorder: true,
                      focusNode: _emailFocus,
                      nextFocus: _passwordFocus,
                      controller: _emailController,
                      inputType: TextInputType.emailAddress,
                    ):Row(children: [
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
                        focusNode: _numberFocus,
                        nextFocus: _passwordFocus,
                        controller: _emailController,
                        inputType: TextInputType.phone,
                      )),

                    ]),
                    const SizedBox(height: Dimensions.paddingSizeLarge),

                    Text(
                      getTranslated('password', context)!,
                      style: poppinsRegular.copyWith(color: Theme.of(context).hintColor.withOpacity(0.6)),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),

                    CustomTextField(
                      hintText: getTranslated('password_hint', context),
                      isShowBorder: true,
                      isPassword: true,
                      isShowSuffixIcon: true,
                      focusNode: _passwordFocus,
                      controller: _passwordController,
                      inputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 20),

                    // for remember me section
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      InkWell(
                        onTap: () => authProvider.toggleRememberMe(),
                        child: Padding(
                          padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                          child: Row(children: [
                            Container(
                              width: 18, height: 18,
                              decoration: BoxDecoration(
                                color: authProvider.isActiveRememberMe ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                border: Border.all(color: authProvider.isActiveRememberMe ? Colors.transparent : Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: authProvider.isActiveRememberMe
                                  ? const Icon(Icons.done, color: Colors.white, size: 17)
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Text(
                              getTranslated('remember_me', context)!,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .copyWith(fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).hintColor.withOpacity(0.6)),
                            ),
                          ]),
                        ),
                      ),

                      InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(RouteHelper.forgetPassword, arguments: const ForgotPasswordScreen());
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            getTranslated('forgot_password', context)!,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium!
                                .copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor.withOpacity(0.6)),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 10),

                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      authProvider.loginErrorMessage!.isNotEmpty
                          ? CircleAvatar(backgroundColor: Theme.of(context).colorScheme.error, radius: 5)
                          : const SizedBox.shrink(),
                      const SizedBox(width: 8),

                      Expanded(child: Text(
                        authProvider.loginErrorMessage ?? "",
                        style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )),

                    ]),
                    const SizedBox(height: 10),

                    // for login button

                    !authProvider.isLoading ? CustomButton(
                      buttonText: getTranslated('login', context),
                      onPressed: () async {
                        String email = _emailController!.text.trim();
                        String? dialCode = CountryCode.fromCountryCode(countryCode!).dialCode;
                        if(!Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification!) {
                          email = dialCode! + _emailController!.text.trim();
                        }
                        String password = _passwordController!.text.trim();
                        if (email.isEmpty) {
                          if(Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification!){
                            showCustomSnackBar(getTranslated('enter_email_address', context)!);
                          }else {
                            showCustomSnackBar(getTranslated('enter_phone_number', context)!);
                          }
                        }else if (Provider.of<SplashProvider>(context, listen: false).configModel!.emailVerification!
                            && EmailChecker.isNotValid(email)) {
                          showCustomSnackBar(getTranslated('enter_valid_email', context)!);
                        }else if (password.isEmpty) {
                          showCustomSnackBar(getTranslated('enter_password', context)!);
                        }else if (password.length < 6) {
                          showCustomSnackBar(getTranslated('password_should_be', context)!);
                        }else {
                          authProvider.login(email, password).then((status) async {
                            
                            if (status.isSuccess) {
                              if (authProvider.isActiveRememberMe) {
                                authProvider.saveUserNumberAndPassword(UserLogData(
                                  countryCode:  dialCode,
                                  phoneNumber: configModel.emailVerification! ? null : _emailController!.text,
                                  email: configModel.emailVerification! ? _emailController!.text : null,
                                  password: password,
                                ));
                              } else {
                                authProvider.clearUserLogData();
                              }

                             Navigator.pushNamedAndRemoveUntil(context, RouteHelper.menu, (route) => false, arguments: const MenuScreen());
                            }
                          });
                        }
                      },
                    ) : Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        )),
                    const SizedBox(height: 20),


                    // for create an account
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(RouteHelper.signUp, arguments: const SignUpScreen());
                      },
                      child: Padding(padding: const EdgeInsets.all(8.0), child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated('create_an_account', context)!,
                              style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor.withOpacity(0.6)),
                            ),
                            const SizedBox(width: Dimensions.paddingSizeSmall),

                            Text(
                              getTranslated('signup', context)!,
                              style: poppinsMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6)),
                            ),
                          ])),
                    ),

                    if(socialStatus!.isFacebook! || socialStatus.isGoogle!)
                      const Center(child: SocialLoginWidget()),


                    Center(child: Text(getTranslated('OR', context)!, style: poppinsRegular.copyWith(fontSize: 12))),

                    Center(child: TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(1, 40),
                      ),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, RouteHelper.menu, arguments: const MenuScreen());
                      },
                      child: RichText(text: TextSpan(children: [
                        TextSpan(text: '${getTranslated('continue_as_a', context)} ',  style: poppinsRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor.withOpacity(0.6))),
                        TextSpan(text: getTranslated('guest', context), style: poppinsRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color)),
                      ])),

                    )),
                  ],
                )),
              ),
            )),

            ResponsiveHelper.isDesktop(context) ? const SizedBox(height: 50,) : const SizedBox(),

            ResponsiveHelper.isDesktop(context) ? const FooterView() : const SizedBox(),
          ]),
        ),
      ))),

    );
  }
}
