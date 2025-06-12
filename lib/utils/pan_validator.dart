class PanValidator {
  static bool isValid(String pan) {
    // PAN format: AAAPL1234C
    // First 5 characters are letters
    // Next 4 characters are numbers
    // Last character is a letter
    
    if (pan.length != 10) {
      return false;
    }
    
    final RegExp panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    return panRegex.hasMatch(pan);
  }
}
