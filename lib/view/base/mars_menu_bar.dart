import 'package:flutter/material.dart';
import 'package:flutter_grocery/provider/cart_provider.dart';
import 'package:provider/provider.dart';

class PlutoMenuBarWidget extends StatefulWidget {
  /// Pass [MenuItems] to List.
  /// create submenus by continuing to pass MenuItem to children as a List.
  ///
  /// ```dart
  /// MenuItem(
  ///   title: 'Menu 1',
  ///   children: [
  ///     MenuItem(
  ///       title: 'Menu 1-1',
  ///       onTap: () => print('Menu 1-1 tap'),
  ///     ),
  ///   ],
  /// ),
  /// ```
  final List<MenuItems> menus;

  /// Text of the back button. (default. 'Go back')
  final String goBackButtonText;

  /// menu height. (default. '45')
  final double height;

  /// BackgroundColor. (default. 'white')
  final Color backgroundColor;

  /// Border color. (default. 'black12')
  final Color borderColor;

  /// menu icon color. (default. 'black54')
  final Color? menuIconColor;

  /// menu icon size. (default. '20')
  final double menuIconSize;

  /// more icon color. (default. 'black54')
  final Color? moreIconColor;

  /// Enable gradient of BackgroundColor. (default. 'true')
  final bool gradient;

  /// [TextStyle] of Menu title.
  final TextStyle textStyle;

   PlutoMenuBarWidget({Key? key,
    required this.menus,
    this.goBackButtonText = 'Go back',
    this.height = 45,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.black12,
    this.menuIconColor = Colors.black54,
    this.menuIconSize = 20,
    this.moreIconColor = Colors.black54,
    this.gradient = true,
    this.textStyle = const TextStyle(),
  })  : assert(menus.isNotEmpty), super(key: key);

  @override
  State<PlutoMenuBarWidget> createState() => _PlutoMenuBarWidgetState();
}

class _PlutoMenuBarWidgetState extends State<PlutoMenuBarWidget> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, size) {
        return Container(
          width: size.minWidth,
          height: widget.height,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.all(10),
          // decoration: BoxDecoration(
          //   color: widget.backgroundColor,// widget.gradient ? null : widget.backgroundColor,
          //   // gradient: widget.gradient
          //   //     ? LinearGradient(
          //   //         begin: Alignment.topCenter,
          //   //         end: Alignment.bottomCenter,
          //   //         colors: [
          //   //           widget.backgroundColor,
          //   //           widget.backgroundColor.withOpacity(0.54),
          //   //         ],
          //   //         stops: [0.90, 1],
          //   //       )
          //   //     : null,
          //   // border: Border(
          //   //   top: BorderSide(color: widget.borderColor),
          //   //   bottom: BorderSide(color: widget.borderColor),
          //   // ),
          //   // boxShadow: [
          //   //   BoxShadow(
          //   //     color: Colors.grey.withOpacity(0.5),
          //   //     spreadRadius: 0,
          //   //     blurRadius: 0,
          //   //     offset: Offset(0, 0.5), // changes position of shadow
          //   //   ),
          //   // ],
          // ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.menus.length,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemBuilder: (_, index) {
              return _MenuWidget(
                widget.menus[index],
                goBackButtonText: widget.goBackButtonText,
                height: widget.height,
                backgroundColor: widget.backgroundColor,
                menuIconColor: widget.menuIconColor,
                menuIconSize: widget.menuIconSize,
                moreIconColor: widget.moreIconColor,
                textStyle: widget.textStyle,
              );
            },
          ),
        );
      },
    );
  }
}

class MenuItems {
  /// Menu title
  final String? title;

  final IconData? icon;

  /// Callback executed when a menu is tapped
  final Function()? onTap;

  /// Passing [MenuItems] to a [List] creates a sub-menu.
  final List<MenuItems>? children;

  MenuItems({
    this.title,
    this.icon,
    this.onTap,
    this.children,
  }) : _key = GlobalKey();

  MenuItems._back({
    this.title,
    this.icon,
    this.onTap,
    this.children,
  })  : _key = GlobalKey(),
        _isBack = true;

  final GlobalKey _key;

  bool _isBack = false;

  Offset get _position {
    RenderBox box = _key.currentContext!.findRenderObject() as RenderBox;

    return box.localToGlobal(Offset.zero);
  }

  bool get _hasChildren => children != null && children!.isNotEmpty;
}

class _MenuWidget extends StatelessWidget {
  final MenuItems menu;

  final String? goBackButtonText;

  final double? height;

  final Color? backgroundColor;

  final Color? menuIconColor;

  final double? menuIconSize;

  final Color? moreIconColor;

  final TextStyle? textStyle;

  _MenuWidget(
      this.menu, {
        this.goBackButtonText,
        this.height,
        this.backgroundColor,
        this.menuIconColor,
        this.menuIconSize,
        this.moreIconColor,
        this.textStyle,
      }) : super(key: menu._key);

  Widget _buildPopupItem(MenuItems menu) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (menu.icon != null) ...[
          Icon(
            menu.icon,
            color: menuIconColor,
            size: menuIconSize,
          ),
          const SizedBox(
            width: 5,
          ),
        ],
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              menu.title!,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
        if (menu._hasChildren && !menu._isBack)
          Icon(
            Icons.arrow_right,
            color: moreIconColor,
          ),
      ],
    );
  }

  Future<MenuItems?> _showPopupMenu(
      BuildContext context,
      List<MenuItems> menuItems,
      ) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset position = menu._position + Offset(0, height! - 11);

    return await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy,
        overlay.size.width,
        overlay.size.height,
      ),
      items: menuItems.map((menu) {
        return PopupMenuItem<MenuItems>(
          value: menu,
          child: _buildPopupItem(menu),
        );
      }).toList(),
      // elevation: 2.0,
      color: backgroundColor,
    );
  }

  Widget _getMenu(
      BuildContext context,
      MenuItems menu,
      ) {
    Future<MenuItems?> getSelectedMenu(
        MenuItems menu, {
          MenuItems? fromPreviousMenu,
          int? stackIdx,
          List<MenuItems>? stack,
        }) async {
      if (!menu._hasChildren) {
        return menu;
      }

      final items = [...menu.children!];

      if (fromPreviousMenu != null) {
        items.add(MenuItems._back(
          title: goBackButtonText,
          children: fromPreviousMenu.children,
          onTap: null,
          icon: null,
        ));
      }

      MenuItems? selectedMenu0 = await _showPopupMenu(
        context,
        items,
      );

      if (selectedMenu0 == null) {
        return null;
      }

      MenuItems? previousMenu = menu;

      if (!selectedMenu0._hasChildren) {
        return selectedMenu0;
      }

      if (selectedMenu0._isBack) {
        stackIdx = stackIdx! - 1;
        if (stackIdx < 0) {
          previousMenu = null;
        } else {
          previousMenu = stack![stackIdx];
        }
      } else {
        if (stackIdx == null) {
          stackIdx = 0;
          stack = [menu];
        } else {
          stackIdx += 1;
          stack!.add(menu);
        }
      }

      return await getSelectedMenu(
        selectedMenu0,
        fromPreviousMenu: previousMenu,
        stackIdx: stackIdx,
        stack: stack,
      );
    }

    return InkWell(
      onTap: () async {
        if (menu._hasChildren) {
          MenuItems? selectedMenu = await getSelectedMenu(menu);

          if (selectedMenu?.onTap != null) {
            selectedMenu!.onTap!();
          }
        } else if (menu.onTap != null) {
          menu.onTap!();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (menu.icon != null) ...[
              Stack(
                clipBehavior: Clip.none, children: [
                Icon(menu.icon, size: menuIconSize,color: menuIconColor,),
                menu.title!.isEmpty? Positioned(
                  top: -7, right: -7,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                    child: Center(
                      child: Text(
                        Provider.of<CartProvider>(context).cartList.length.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 8) //poppinsMedium.copyWith(color: ColorResources.COLOR_WHITE, fontSize: 8),
                      ),
                    ),
                  ),
                ):const SizedBox()
              ],
              ),
              // menu.icon,
              // color: menuIconColor,
              // size: menuIconSize,

              const SizedBox(
                width: 5,
              ),
            ],
            Text(
              menu.title!,
              style: textStyle,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _getMenu(context, menu);
  }
}
