import 'package:flutter/material.dart';

class CustomFloatingActionButtonOption {
  final String title;
  final IconData icon;
  final Function()? onTap;

  const CustomFloatingActionButtonOption({
    required this.title,
    required this.icon,
    this.onTap,
  });
}
