import 'package:flutter/cupertino.dart';

import '../../utils/constants/sizes.dart';

class SMASpacingStyle{
  static const EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
      top: SMASizes.appBarHeight,
      left: SMASizes.defaultSpace,
      bottom: SMASizes.defaultSpace,
      right: SMASizes.defaultSpace
  );
  static const EdgeInsetsGeometry allSidePadding = EdgeInsets.only(
      top: SMASizes.defaultSpace,
      left: SMASizes.defaultSpace,
      bottom: SMASizes.defaultSpace,
      right: SMASizes.defaultSpace
  );
}