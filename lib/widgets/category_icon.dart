import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/models.dart';

class CategoryIcon extends StatelessWidget {
  final String icon;
  final TransactionType type;
  final String? colorHex;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.type,
    this.colorHex,
  });

  static const Map<String, IconData> availableIcons = {
    'food': CupertinoIcons.flame_fill,
    'transport': CupertinoIcons.bus,
    'home': CupertinoIcons.house_fill,
    'entertainment': CupertinoIcons.game_controller_solid,
    'shopping': CupertinoIcons.bag_fill,
    'salary': CupertinoIcons.briefcase_fill,
    'money': CupertinoIcons.money_dollar,
    'gift': CupertinoIcons.gift_fill,
    'box': CupertinoIcons.cube_box_fill,
    'airplane': CupertinoIcons.airplane,
    'book': CupertinoIcons.book_fill,
    'heart': CupertinoIcons.heart_solid,
    'health': CupertinoIcons.bandage_fill,
    'tools': CupertinoIcons.wrench_fill,
    'phone': CupertinoIcons.device_phone_portrait,
    'education': CupertinoIcons.book_circle_fill,
    'car': CupertinoIcons.car_detailed,
    'cart': CupertinoIcons.cart_fill,
    'tv': CupertinoIcons.tv_fill,
    'ticket': CupertinoIcons.ticket_fill,
    'person': CupertinoIcons.person_fill,
  };

  @override
  Widget build(BuildContext context) {
    Color baseColor = colorHex != null 
        ? Color(int.parse(colorHex!.replaceFirst('#', '0xFF'))) 
        : type.color;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: availableIcons.containsKey(icon)
          ? Icon(availableIcons[icon], color: Colors.white, size: 24)
          : Text(icon, style: const TextStyle(fontSize: 22, color: Colors.white)),
    );
  }
}
