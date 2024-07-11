import 'package:flutter/material.dart';
import 'package:orderease_admin/utils/theme/custom_theme/text_theme.dart';

import '../../../common/styles/spacing_style.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/helpers/helper_fuctions.dart';

class AverageOrderValueContainer extends StatelessWidget {
  final Stream<List<double>> ordersDataStream;

  AverageOrderValueContainer({required this.ordersDataStream});

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
            'Average Order Value per Day',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30.0),
          Expanded(
            child: StreamBuilder<List<double>>(
              stream: ordersDataStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                }

                List<double> averageOrderValues = snapshot.data!;
                return BarGraph(averageOrderValues: averageOrderValues);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BarGraph extends StatelessWidget {
  final List<double> averageOrderValues;
  final double maxBarHeight = 300.0;
  final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  BarGraph({required this.averageOrderValues});

  @override
  Widget build(BuildContext context) {
    bool dark = SMAHelperFunctions.isDarkMode(context);
    return CustomPaint(
      size: Size(double.infinity, maxBarHeight + 40),
      painter: BarGraphPainter(averageOrderValues, maxBarHeight, dark),
    );
  }
}

class BarGraphPainter extends CustomPainter {
  final List<double> averageOrderValues;
  final double maxBarHeight;
  final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final bool dark;

  BarGraphPainter(this.averageOrderValues, this.maxBarHeight, this.dark);

  @override
  void paint(Canvas canvas, Size size) {
    final double barWidth = size.width / 7;
    final Paint barPaint = Paint()..color = Colors.blue;

    for (int i = 0; i < daysOfWeek.length; i++) {
      double orderValue = averageOrderValues[i];
      double barHeight = orderValue / (averageOrderValues.reduce((a, b) => a > b ? a : b)) * maxBarHeight;

      if (orderValue > 0) {
        Rect rect = Rect.fromLTWH(i * barWidth, maxBarHeight - barHeight, barWidth-10, barHeight);
        RRect roundedRect = RRect.fromRectAndRadius(rect, Radius.circular(8.0));
        canvas.drawRRect(roundedRect, barPaint);

        TextPainter valuePainter = TextPainter(
          text: TextSpan(
            text: "\u{20B9}${orderValue.toStringAsFixed(1)}", // Display with one decimal place
            style: TextStyle(fontSize: 14.0, color: dark?SMAColors.white:SMAColors.black),
          ),
          textDirection: TextDirection.ltr,
        );
        valuePainter.layout();
        valuePainter.paint(canvas, Offset(i * barWidth + (barWidth - valuePainter.width) / 2, maxBarHeight - barHeight - 20));
      }

      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: daysOfWeek[i],
          style: dark ? SMATextTheme.darkTextTheme.labelMedium : SMATextTheme.lightTextTheme.labelMedium,
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(i * barWidth + (barWidth - textPainter.width) / 2, maxBarHeight + 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
