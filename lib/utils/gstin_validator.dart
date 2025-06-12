class GstinValidator {
  static bool isValid(String gstin) {
    if (gstin.length != 15) return false;
    
    // Basic GSTIN format validation
    final gstinRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$');
    return gstinRegex.hasMatch(gstin);
  }
  
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'GSTIN is required';
    }
    
    if (!isValid(value)) {
      return 'Please enter a valid GSTIN';
    }
    
    return null;
  }
}
