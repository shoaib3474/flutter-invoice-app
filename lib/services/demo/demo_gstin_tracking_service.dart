import 'dart:math';
import '../../models/gstin/gstin_filing_history.dart';
import '../gstin/gstin_tracking_service.dart';

class DemoGstinTrackingService implements GstinTrackingService {
  @override
  String baseUrl = 'https://demo-api.example.com';
  
  @override
  String apiKey = 'demo-api-key';
  
  final Random _random = Random();
  
  @override
  Future<GstinFilingHistory> getFilingHistory(String gstin) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800 + _random.nextInt(1200)));
    
    // Generate demo data
    return _generateDemoFilingHistory(gstin);
  }
  
  GstinFilingHistory _generateDemoFilingHistory(String gstin) {
    final tradeName = 'Demo Company ${gstin.substring(2, 7)}';
    final legalName = 'DEMO ENTERPRISES PVT LTD';
    final status = 'Active';
    
    // Generate filing history for the last 12 months
    final now = DateTime.now();
    final gstr1Filings = _generateFilingsForType('GSTR1', now, 12);
    final gstr3bFilings = _generateFilingsForType('GSTR3B', now, 12);
    final gstr4Filings = _generateFilingsForType('GSTR4', now, 4); // Quarterly
    final gstr9Filings = _generateFilingsForType('GSTR9', now, 2); // Annual
    
    return GstinFilingHistory(
      gstin: gstin,
      tradeName: tradeName,
      legalName: legalName,
      status: status,
      gstr1Filings: gstr1Filings,
      gstr3bFilings: gstr3bFilings,
      gstr4Filings: gstr4Filings,
      gstr9Filings: gstr9Filings,
    );
  }
  
  List<GstrFiling> _generateFilingsForType(String returnType, DateTime now, int count) {
    final filings = <GstrFiling>[];
    
    for (int i = 0; i < count; i++) {
      // For GSTR9, generate annual returns
      if (returnType == 'GSTR9') {
        final year = now.year - i - 1;
        final returnPeriod = '03-$year'; // March is the end of financial year in India
        
        // 80% chance of filing, 20% chance of not filing
        final filed = _random.nextDouble() < 0.8;
        
        if (filed) {
          // Due date is 31st December of the following year
          final dueDate = DateTime(year + 1, 12, 31);
          
          // 70% chance of filing on time, 30% chance of filing late
          final onTime = _random.nextDouble() < 0.7;
          
          final filingDate = onTime
              ? dueDate.subtract(Duration(days: _random.nextInt(30)))
              : dueDate.add(Duration(days: _random.nextInt(60)));
          
          filings.add(GstrFiling(
            returnType: returnType,
            returnPeriod: returnPeriod,
            filingDate: filingDate,
            status: 'Filed',
            mode: _random.nextBool() ? 'Online' : 'Offline',
            arn: 'AA${year}0${_random.nextInt(9)}${_random.nextInt(9)}${_random.nextInt(9)}${_random.nextInt(9)}${_random.nextInt(9)}',
          ));
        } else {
          filings.add(GstrFiling(
            returnType: returnType,
            returnPeriod: returnPeriod,
            filingDate: DateTime.now(), // Current date for not filed
            status: 'Not Filed',
          ));
        }
        continue;
      }
      
      // For GSTR4, generate quarterly returns
      if (returnType == 'GSTR4') {
        final month = now.month - (now.month % 3) - (i * 3);
        final year = now.year - (month <= 0 ? 1 : 0);
        final adjustedMonth = month <= 0 ? month + 12 : month;
        
        final returnPeriod = '${adjustedMonth.toString().padLeft(2, '0')}-$year';
        
        // 85% chance of filing, 15% chance of not filing
        final filed = _random.nextDouble() < 0.85;
        
        if (filed) {
          // Due date is 18th of the month following the quarter
          final dueDate = DateTime(year, adjustedMonth + 1, 18);
          
          // 75% chance of filing on time, 25% chance of filing late
          final onTime = _random.nextDouble() < 0.75;
          
          final filingDate = onTime
              ? dueDate.subtract(Duration(days: _random.nextInt(15)))
              : dueDate.add(Duration(days: _random.nextInt(30)));
          
          filings.add(GstrFiling(
            returnType: returnType,
            returnPeriod: returnPeriod,
            filingDate: filingDate,
            status: 'Filed',
            mode: _random.nextBool() ? 'Online' : 'Offline',
            arn: 'AA${year}${adjustedMonth}${_random.nextInt(9)}${_random.nextInt(9)}${_random.nextInt(9)}${_random.nextInt(9)}',
          ));
        } else {
          filings.add(GstrFiling(
            returnType: returnType,
            returnPeriod: returnPeriod,
            filingDate: DateTime.now(), // Current date for not filed
            status: 'Not Filed',
          ));
        }
        continue;
      }
      
      // For GSTR1 and GSTR3B, generate monthly returns
      final month = now.month - i;
      final year = now.year - (month <= 0 ? 1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;
      
      final returnPeriod = '${adjustedMonth.toString().padLeft(2, '0')}-$year';
      
      // 90% chance of filing, 10% chance of not filing
      final filed = _random.nextDouble() < 0.9;
      
      if (filed) {
        // Due date depends on return type
        final dueDay = returnType == 'GSTR1' ? 11 : 20;
        final dueDate = DateTime(year, adjustedMonth + 1, dueDay);
        
        // 80% chance of filing on time, 20% chance of filing late
        final onTime = _random.nextDouble() < 0.8;
        
        final filingDate = onTime
              ? dueDate.subtract(Duration(days: _random.nextInt(10)))
              : dueDate.add(Duration(days: _random.nextInt(20)));
        
        filings.add(GstrFiling(
          returnType: returnType,
          returnPeriod: returnPeriod,
          filingDate: filingDate,
          status: 'Filed',
          mode: _random.nextBool() ? 'Online' : 'Offline',
          arn: 'AA${year}${adjustedMonth}${_random.nextInt(9)}${_random.nextInt(9)}${_random.nextInt(9)}${_random.nextInt(9)}',
        ));
      } else {
        filings.add(GstrFiling(
          returnType: returnType,
          returnPeriod: returnPeriod,
          filingDate: DateTime.now(), // Current date for not filed
          status: 'Not Filed',
        ));
      }
    }
    
    return filings;
  }
  
  @override
  void dispose() {
    // No resources to dispose in the demo service
  }
  
  @override
  Future<String?> getCompanyName(String gstin) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(500)));
    return 'Demo Company for $gstin';
  }
  
  @override
  Future<bool> isValidGSTIN(String gstin) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(200)));
    return gstin.length == 15 && RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$').hasMatch(gstin);
  }
}
