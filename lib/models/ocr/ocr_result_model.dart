class OCRResult {
  final String extractedText;
  final double confidence;
  final List<OCRTextBlock> blocks;
  final DateTime processingTime;

  const OCRResult({
    required this.extractedText,
    required this.confidence,
    required this.blocks,
    required this.processingTime,
  });

  factory OCRResult.fromJson(Map<String, dynamic> json) {
    return OCRResult(
      extractedText: json['extractedText'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      blocks: (json['blocks'] as List<dynamic>)
          .map((e) => OCRTextBlock.fromJson(e as Map<String, dynamic>))
          .toList(),
      processingTime: DateTime.parse(json['processingTime'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'extractedText': extractedText,
      'confidence': confidence,
      'blocks': blocks.map((e) => e.toJson()).toList(),
      'processingTime': processingTime.toIso8601String(),
    };
  }
}

class OCRTextBlock {
  final String text;
  final OCRBoundingBox boundingBox;
  final double confidence;

  const OCRTextBlock({
    required this.text,
    required this.boundingBox,
    required this.confidence,
  });

  factory OCRTextBlock.fromJson(Map<String, dynamic> json) {
    return OCRTextBlock(
      text: json['text'] as String,
      boundingBox: OCRBoundingBox.fromJson(json['boundingBox'] as Map<String, dynamic>),
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'boundingBox': boundingBox.toJson(),
      'confidence': confidence,
    };
  }
}

class OCRBoundingBox {
  final double left;
  final double top;
  final double right;
  final double bottom;

  const OCRBoundingBox({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  factory OCRBoundingBox.fromJson(Map<String, dynamic> json) {
    return OCRBoundingBox(
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      right: (json['right'] as num).toDouble(),
      bottom: (json['bottom'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'left': left,
      'top': top,
      'right': right,
      'bottom': bottom,
    };
  }
}
