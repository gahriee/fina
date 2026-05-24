import 'package:flutter/material.dart';
import '../models/models.dart';
import 'amount_text.dart';
import 'category_icon.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final Category category;
  final String currencySymbol;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.category,
    required this.currencySymbol,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CategoryIcon(icon: category.icon, type: category.type, colorHex: category.colorHex),
      title: Text(
        transaction.note?.isNotEmpty == true ? transaction.note! : category.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(_formatDate(transaction.date)),
      trailing: AmountText(
        amount: transaction.amount,
        type: transaction.type,
        currencySymbol: currencySymbol,
      ),
    );
  }
}
