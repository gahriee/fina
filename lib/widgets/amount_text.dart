import 'package:flutter/material.dart';
import '../models/models.dart';
import '../app/theme.dart';

class AmountText extends StatelessWidget {
  final double amount;
  final TransactionType type;
  final String currencySymbol;
  final TextStyle? style;

  const AmountText({
    super.key,
    required this.amount,
    required this.type,
    required this.currencySymbol,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color  = type == TransactionType.income
        ? (isDark ? AppColors.incomeDark  : AppColors.income)
        : (isDark ? AppColors.expenseDark : AppColors.expense);
    return Text(
      '${type.sign}$currencySymbol${amount.toStringAsFixed(2)}',
      style: (style ?? Theme.of(context).textTheme.bodyMedium)
               ?.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}
