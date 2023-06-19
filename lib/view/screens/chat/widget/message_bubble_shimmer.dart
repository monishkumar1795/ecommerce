import 'package:flutter/material.dart';
import 'package:flutter_grocery/provider/chat_provider.dart';
import 'package:flutter_grocery/utill/color_resources.dart';
import 'package:provider/provider.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class MessageBubbleShimmer extends StatelessWidget {
final bool isMe;
const MessageBubbleShimmer({Key? key, required this.isMe}) : super(key: key);

@override
Widget build(BuildContext context) {
  return Padding(
    padding: isMe ?  const EdgeInsets.fromLTRB(50, 5, 10, 5) : const EdgeInsets.fromLTRB(10, 5, 50, 5),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: Provider.of<ChatProvider>(context).isLoading,
            child: Container(
              height: 30, width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(10),
                  bottomLeft: isMe ? const Radius.circular(10) : const Radius.circular(0),
                  bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(10),
                  topRight: const Radius.circular(10),
                ),
                color: isMe ? Theme.of(context).hintColor.withOpacity(0.6) : ColorResources.getSearchBg(context),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
}
