import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final String currencySymbol;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.currencySymbol,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [Theme.of(context).colorScheme.surfaceContainerHighest, Theme.of(context).colorScheme.surface]
              : [Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), Theme.of(context).colorScheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${balance < 0 ? '-' : ''}$currencySymbol${balance.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
