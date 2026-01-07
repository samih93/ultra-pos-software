import 'package:flutter/material.dart';

Widget defaultSwitch({required bool value, required VoidCallback onChanged}) =>
    Switch(
      value: value,
      onChanged: (val) => onChanged,
      activeThumbColor: Colors.blue,
      inactiveThumbColor: Colors.grey,
    );
