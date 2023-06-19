import 'package:flutter/material.dart';
import 'package:flutter_grocery/utill/dimensions.dart';

class ArrayButton extends StatelessWidget {
  final bool isLeft;
  final bool isLarge;
  final Function onTop;
  final bool isVisible;
  const ArrayButton({Key? key, required this.isLeft, required this.isLarge, required this.onTop, required this.isVisible}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.transparent,
      onTap: isVisible ?  onTop as void Function()? : null,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        decoration: BoxDecoration(color: isVisible ? Theme.of(context).primaryColor.withOpacity(0.7) : Theme.of(context).hintColor.withOpacity(0.6), shape: BoxShape.circle,
          boxShadow: const [
            /*BoxShadow(
                color: Colors.grey[Provider.of<ThemeProvider>(context).darkTheme? 900 : 200],
                spreadRadius: 0,
                blurRadius: 25,
                offset: Offset(0, 4))*/
          ],),
        child: Padding(
          padding: isLarge ?  const EdgeInsets.all(8.0) : const EdgeInsets.all(4.0),
          child: isLeft ? Icon(Icons.chevron_left_rounded, color: isVisible ? Theme.of(context).cardColor
              : Theme.of(context).textTheme.bodyLarge?.color, size: isLarge ?  30
              : Dimensions.paddingSizeLarge) : Icon(Icons.chevron_right_rounded, color: isVisible 
              ? Theme.of(context).cardColor  :  Theme.of(context).textTheme.bodyLarge?.color, size: isLarge ?  30
              : Dimensions.paddingSizeLarge),
        ),
      ),
    );
  }
}
