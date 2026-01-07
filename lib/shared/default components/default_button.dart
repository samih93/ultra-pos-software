// //!NOTE ----------default Button -----------------------------
// import 'package:flutter/material.dart';
// import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';

// class DefaultButton extends StatelessWidget {
//   const DefaultButton(
//       {this.width,
//       this.background,
//       this.textcolor = Colors.white,
//       this.onpress,
//       required this.text,
//       this.gradient,
//       this.radius,
//       this.height,
//       this.isUppercase,
//       this.isDisabled,
//       super.key});

//   final double? width;
//   final Color? background;
//   final Color? textcolor;
//   final VoidCallback? onpress;
//   final String text;
//   final Gradient? gradient;
//   final double? radius;
//   final double? height;
//   final bool? isUppercase;
//   final bool? isDisabled;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: width ?? double.infinity,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(radius ?? 5),
//         gradient: gradient ??
//             (isDisabled == true
//                 ? mydisabledLinearGradient()
//                 : quiverGradient()),
//       ),
//       child: MaterialButton(
//         height: height ?? 40,
//         onPressed: isDisabled == true ? null : onpress,
//         child: FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Text(
//             (isUppercase != null && isUppercase == true)
//                 ? text.toUpperCase()
//                 : text,
//             style: TextStyle(
//               color: textcolor ?? Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
