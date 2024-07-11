import 'package:flutter/material.dart';
import 'package:orderease_admin/utils/theme/custom_theme/text_theme.dart';

import '../../../common/styles/spacing_style.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_fuctions.dart';

class OrdersPerDayContainer extends StatelessWidget {
  final List<double> ordersData;

  OrdersPerDayContainer({required this.ordersData});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return Container(
      height: 400,
      //width: width * 0.3,
      padding: SMASpacingStyle.allSidePadding,
      margin: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: dark ? SMAColors.dark : SMAColors.light,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Orders per Day',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30.0),
          Expanded(
            child: BarGraph(ordersData: ordersData),
          ),
        ],
      ),
    );
  }
}



class BarGraph extends StatelessWidget {
  final List<double> ordersData;
  final double maxBarHeight = 300.0;
  final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  BarGraph({required this.ordersData});

  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return CustomPaint(
      size: Size(double.infinity, maxBarHeight + 40),
      painter: BarGraphPainter(ordersData, maxBarHeight,dark),
    );
  }
}

class BarGraphPainter extends CustomPainter {
  final List<double> ordersData;
  final double maxBarHeight;
  final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final bool dark;

  BarGraphPainter(this.ordersData, this.maxBarHeight, this.dark);

  @override
  void paint(Canvas canvas, Size size) {

    final double barWidth = size.width / 7;
    final Paint barPaint = Paint()..color = Colors.blue;
    for (int i = 0; i < daysOfWeek.length; i++) {
      double ordersCount = ordersData[i];
      double barHeight = ordersCount / ordersData.reduce((a, b) => a > b ? a : b) * maxBarHeight;
      Rect rect = Rect.fromLTWH(i * barWidth, maxBarHeight - barHeight, barWidth-8, barHeight);
      RRect roundedRect = RRect.fromRectAndRadius(rect, Radius.circular(8.0));
      canvas.drawRRect(roundedRect, barPaint);

      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: daysOfWeek[i],
          style: dark? SMATextTheme.darkTextTheme.labelMedium : SMATextTheme.lightTextTheme.labelMedium,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(i * barWidth + (barWidth - textPainter.width) / 2, maxBarHeight + 8));

      TextPainter valuePainter = TextPainter(
        text: TextSpan(
          text: ordersCount.toStringAsFixed(1), // Display with one decimal place
          style: TextStyle(fontSize: 14.0,  color: dark?SMAColors.white:SMAColors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      valuePainter.paint(canvas, Offset(i * barWidth + (barWidth - valuePainter.width) / 2, maxBarHeight - barHeight - 20));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

