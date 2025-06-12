class MockExcelService {
  static MockExcel createExcel() => MockExcel();
}

class MockExcel {
  final Map<String, MockSheet> _sheets = {};
  
  void delete(String sheetName) {
    _sheets.remove(sheetName);
  }
  
  MockSheet operator [](String sheetName) {
    return _sheets.putIfAbsent(sheetName, () => MockSheet());
  }
  
  List<int>? encode() {
    // Mock implementation - returns empty bytes
    return <int>[];
  }
}

class MockSheet {
  final List<List<String>> _data = [];
  
  int get maxRows => _data.length;
  
  MockCell cell(MockCellIndex index) {
    // Ensure the sheet has enough rows and columns
    while (_data.length <= index.rowIndex) {
      _data.add(<String>[]);
    }
    while (_data[index.rowIndex].length <= index.columnIndex) {
      _data[index.rowIndex].add('');
    }
    
    return MockCell(_data, index.rowIndex, index.columnIndex);
  }
  
  void appendRow(List<String> row) {
    _data.add(row);
  }
}

class MockCell {
  final List<List<String>> _data;
  final int _row;
  final int _col;
  
  MockCell(this._data, this._row, this._col);
  
  set value(MockCellValue value) {
    _data[_row][_col] = value.text;
  }
  
  set cellStyle(MockCellStyle style) {
    // Mock implementation - styles are ignored
  }
}

class MockCellIndex {
  final int rowIndex;
  final int columnIndex;
  
  MockCellIndex({required this.rowIndex, required this.columnIndex});
  
  static MockCellIndex indexByColumnRow({required int columnIndex, required int rowIndex}) {
    return MockCellIndex(rowIndex: rowIndex, columnIndex: columnIndex);
  }
}

class MockCellValue {
  final String text;
  MockCellValue(this.text);
}

class MockTextCellValue extends MockCellValue {
  MockTextCellValue(super.text);
}

class MockCellStyle {
  final bool? bold;
  final String? backgroundColorHex;
  final MockHorizontalAlign? horizontalAlign;
  
  MockCellStyle({
    this.bold,
    this.backgroundColorHex,
    this.horizontalAlign,
  });
}

enum MockHorizontalAlign { Center, Left, Right }
