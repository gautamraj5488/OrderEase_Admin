import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/device/device_utility.dart';
import '../../../utils/helpers/helper_fuctions.dart';

class SMAAppBar extends StatelessWidget implements PreferredSizeWidget{
  const SMAAppBar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = true,
  });
  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;



  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SMASizes.md),
      child: AppBar (
        automaticallyImplyLeading: false,
        leading: showBackArrow
            ? IconButton(onPressed: (){Navigator.pop(context);}, icon: Icon (Icons.arrow_back_ios_new,color: dark ? SMAColors.light :SMAColors.dark,))
            : leadingIcon != null? IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon)) : null,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(SMADeviceUtils.getAppBarHeight());
}
