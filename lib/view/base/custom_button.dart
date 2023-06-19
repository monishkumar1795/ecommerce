import 'package:flutter/material.dart';
import 'package:flutter_grocery/utill/dimensions.dart';
import 'package:flutter_grocery/utill/styles.dart';

class CustomButton extends StatelessWidget {
  final String? buttonText;
  final Function? onPressed;
  final double margin;
  final Color? textColor;
  final Color? backgroundColor;
  final double borderRadius;
  const CustomButton({Key? key, required this.buttonText, required this.onPressed, this.margin = 0, this.textColor, this.borderRadius = 10, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(margin),
      child: TextButton(
        onPressed: onPressed as void Function()?,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor ?? (onPressed == null ? Theme.of(context).hintColor.withOpacity(0.6) : Theme.of(context).primaryColor),
          minimumSize: Size(MediaQuery.of(context).size.width, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        ),
        child: Text(buttonText!, style: poppinsMedium.copyWith(
          color: textColor ?? Theme.of(context).cardColor,
          fontSize: Dimensions.fontSizeLarge,
        )),
      ),
    );
  }
}
