class TransactionAttachment {
  final String id;
  final String transactionId;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final DateTime uploadTime;

  TransactionAttachment({
    required this.id,
    required this.transactionId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.uploadTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'transactionId': transactionId,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadTime': uploadTime.toIso8601String(),
    };
  }

  factory TransactionAttachment.fromMap(Map<String, dynamic> map) {
    return TransactionAttachment(
      id: map['id'],
      transactionId: map['transactionId'],
      fileName: map['fileName'],
      filePath: map['filePath'],
      fileType: map['fileType'],
      fileSize: map['fileSize'],
      uploadTime: DateTime.parse(map['uploadTime']),
    );
  }
} 