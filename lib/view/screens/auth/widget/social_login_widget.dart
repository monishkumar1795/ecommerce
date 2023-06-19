import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_grocery/data/model/social_login_model.dart';
import 'package:flutter_grocery/helper/responsive_helper.dart';
import 'package:flutter_grocery/helper/route_helper.dart';
import 'package:flutter_grocery/localization/language_constraints.dart';
import 'package:flutter_grocery/main.dart';
import 'package:flutter_grocery/provider/auth_provider.dart';
import 'package:flutter_grocery/provider/splash_provider.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/images.dart';
import 'package:flutter_grocery/utill/styles.dart';
import 'package:flutter_grocery/view/screens/menu/menu_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class SocialLoginWidget extends StatefulWidget {
  const SocialLoginWidget({Key? key}) : super(key: key);

  @override
  State<SocialLoginWidget> createState() => _SocialLoginWidgetState();
}

class _SocialLoginWidgetState extends State<SocialLoginWidget> {
  SocialLoginModel socialLogin = SocialLoginModel();

  void route(
      bool isRoute,
      String? token,
      String? errorMessage,
      ) async {
    if (isRoute) {
      if(token != null){
        Navigator.pushNamedAndRemoveUntil(context, RouteHelper.menu, (route) => false, arguments: const MenuScreen());

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? ''),
            backgroundColor: Colors.red));
      }

    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage ?? ''),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Column(children: [

          Center(child: Text('${getTranslated('sign_in_with', context)}', style: poppinsRegular.copyWith(
              color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6),
              fontSize: Dimensions.fontSizeSmall))),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          Row(mainAxisAlignment: MainAxisAlignment.center, children: [

           if(Provider.of<SplashProvider>(context,listen: false).configModel!.socialLoginStatus!.isGoogle!)
             Row(
               children: [
                 InkWell(
                    onTap: () async {
                      try{
                        GoogleSignInAuthentication  auth = await authProvider.googleLogin();
                        GoogleSignInAccount googleAccount = authProvider.googleAccount!;

                        Provider.of<AuthProvider>(Get.context!, listen: false).socialLogin(SocialLoginModel(
                          email: googleAccount.email, token: auth.idToken, uniqueId: googleAccount.id, medium: 'google',
                        ), route);


                      }catch(er){
                        debugPrint('access token error is : $er');
                      }
                    },
                    child: Container(
                      height: ResponsiveHelper.isDesktop(context)
                          ? 50 : 40,
                      width: ResponsiveHelper.isDesktop(context)
                          ? 130 :ResponsiveHelper.isTab(context)
                          ? 110 : 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1),
                        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSizeTen)),
                      ),
                      child:   Image.asset(
                        Images.google,
                        height: ResponsiveHelper.isDesktop(context)
                            ? 30 :ResponsiveHelper.isTab(context)
                            ? 25 : 20,
                        width: ResponsiveHelper.isDesktop(context)
                            ? 30 : ResponsiveHelper.isTab(context)
                            ? 25 : 20,
                      ),
                    ),
                  ),

                 if(Provider.of<SplashProvider>(context,listen: false).configModel!.socialLoginStatus!.isFacebook!)
                   const SizedBox(width: Dimensions.paddingSizeDefault,),
               ],
             ),


            if(Provider.of<SplashProvider>(context,listen: false).configModel!.socialLoginStatus!.isFacebook!)
              InkWell(
              onTap: () async{
                LoginResult result = await FacebookAuth.instance.login();

                if (result.status == LoginStatus.success) {
                 Map userData = await FacebookAuth.instance.getUserData();

                 authProvider.socialLogin(
                   SocialLoginModel(
                     email: userData['email'],
                     token: result.accessToken!.token,
                     uniqueId: result.accessToken!.userId,
                     medium: 'facebook',
                   ), route,
                 );
                }
              },
              child: Container(
                height: ResponsiveHelper.isDesktop(context)?50 :ResponsiveHelper.isTab(context)? 40:40,
                width: ResponsiveHelper.isDesktop(context)? 130 :ResponsiveHelper.isTab(context)? 110: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1),
                  borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusSizeTen)),
                ),
                child:   Image.asset(
                  Images.facebook,
                  height: ResponsiveHelper.isDesktop(context)
                      ? 30 : ResponsiveHelper.isTab(context)
                      ? 25 : 20,
                  width: ResponsiveHelper.isDesktop(context)
                      ? 30 :ResponsiveHelper.isTab(context)
                      ? 25 : 20,
                ),
              ),
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
        ]);
      }
    );
  }
}
