import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:flutter/material.dart';

coreGradient() => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Pallete.blueColor, // Original color
          Pallete.primaryColor, // First darker shade
          Color(0xFF42A5F5) // Second darker shade
        ]);

myLinearGradient(BuildContext context) => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Pallete.blueColor, // Original color
          Pallete.primaryColor, // First darker shade
          Color(0xFF42A5F5) // Second darker shade
        ]);
mygreenLinearGradient() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.green,
          Colors.green.withValues(alpha: 0.8),
          Colors.green.withValues(alpha: 0.6),
        ]);

myblueLinearGradient() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blue,
          Colors.blue.withValues(alpha: 0.8),
          Colors.blue.withValues(alpha: 0.6),
        ]);

myredLinearGradient() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.red,
          Colors.red.withValues(alpha: 0.8),
          Colors.red.withValues(alpha: 0.6),
        ]);

mydisabledLinearGradient() => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.grey.shade800,
          Colors.grey.shade800.withValues(alpha: 0.8),
          Colors.grey.shade800.withValues(alpha: 0.6),
        ]);
