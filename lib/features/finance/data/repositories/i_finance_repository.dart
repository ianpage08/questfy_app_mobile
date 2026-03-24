import 'package:questfy_app_mobile/features/finance/data/models/finance_entry.dart';



abstract class IFinanceRepository {
  Future<List<FinanceEntry>> getEntries();
  Future<void> addEntry(FinanceEntry entry);
  Future<void> deleteEntry(String id);
}