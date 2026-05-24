import 'package:flutter/material.dart';
import '../models/models.dart';

class CategoryIcon extends StatelessWidget {
  final String icon;
  final TransactionType type;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: type.color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        icon,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}
