import 'package:flutter/services.dart';
import '../models/models.dart';

class ExportService {
  static const MethodChannel _channel = MethodChannel('com.fina.export');

  String generateCsv(List<Transaction> transactions, List<Category> categories) {
    final buffer = StringBuffer();
    
    // CSV Header
    buffer.writeln('Date,Type,Category,Amount,Wallet ID,Note');
    
    for (final t in transactions) {
      final dateStr = '${t.date.year}-${t.date.month.toString().padLeft(2, '0')}-${t.date.day.toString().padLeft(2, '0')}';
      final typeStr = t.type.name;
      final categoryName = categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => Category(id: t.categoryId, userId: '', name: 'Unknown', icon: '?', type: t.type),
      ).name;
      final amountStr = t.amount.toStringAsFixed(2);
      final walletStr = t.walletId ?? '';
      
      // Escape note just in case it has commas
      final noteStr = t.note != null ? '"${t.note!.replaceAll('"', '""')}"' : '';
      
      buffer.writeln('$dateStr,$typeStr,$categoryName,$amountStr,$walletStr,$noteStr');
    }
    
    return buffer.toString();
  }

  Future<void> shareCsv(String csvContent, String filename) async {
    try {
      await _channel.invokeMethod('shareCsv', {
        'csvContent': csvContent,
        'filename': filename,
      });
    } on PlatformException catch (e) {
      print("Failed to share CSV: '${e.message}'.");
    }
  }
}
