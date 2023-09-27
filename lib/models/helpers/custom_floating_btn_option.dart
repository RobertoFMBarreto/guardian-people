import 'package:flutter/material.dart';

/// This class represents a floating action button option data
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
