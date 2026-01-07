import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class DefaultProgressIndicator extends StatelessWidget {
  const DefaultProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const RepaintBoundary(
      child: SizedBox(
        width: 250,
        height: 50,
        child: LoadingIndicator(
          indicatorType: Indicator.ballBeat,

          colors: [Colors.lightBlue, Colors.green, Colors.red],

          //!/ Optional, The color collections

          strokeWidth: 0.2,

          //!/ Optional, The stroke of the line, only applicable to widget which contains line

          //!/ Optional, Background of the widget

          //!/ Optional, the stroke backgroundColor
        ),
      ),
    );
  }
}
