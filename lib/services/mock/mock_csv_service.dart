class MockCsvService {
  static List<List<dynamic>> convertCsvToList(String csvContent) {
    final lines = csvContent.split('\n');
    final result = <List<dynamic>>[];
    
    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        final row = line.split(',').map((cell) => cell.trim()).toList();
        result.add(row);
      }
    }
    
    return result;
  }
  
  static String convertListToCsv(List<List<dynamic>> data) {
    return data.map((row) => row.join(',')).join('\n');
  }
}
