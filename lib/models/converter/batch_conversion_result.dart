class BatchConversionResult {
  final int totalJobs;
  int successfulJobs;
  int failedJobs;
  final List<ConversionResult> convertedFiles;
  final List<FailedConversion> failedFiles;

  BatchConversionResult({
    required this.totalJobs,
    required this.successfulJobs,
    required this.failedJobs,
    required this.convertedFiles,
    required this.failedFiles,
  });
}

class ConversionResult {
  final String originalFilePath;
  final String convertedFilePath;
  final String originalFileName;
  final String convertedFileName;

  ConversionResult({
    required this.originalFilePath,
    required this.convertedFilePath,
    required this.originalFileName,
    required this.convertedFileName,
  });
}

class FailedConversion {
  final String filePath;
  final String fileName;
  final String error;

  FailedConversion({
    required this.filePath,
    required this.fileName,
    required this.error,
  });
}
