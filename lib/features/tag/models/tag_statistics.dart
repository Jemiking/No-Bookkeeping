class TagStatistics {
  final String tagId;
  final String tagName;
  final int usageCount;
  final double totalAmount;
  final Map<String, int> entityTypeDistribution;
  final Map<String, double> monthlyUsage;

  TagStatistics({
    required this.tagId,
    required this.tagName,
    required this.usageCount,
    required this.totalAmount,
    required this.entityTypeDistribution,
    required this.monthlyUsage,
  });

  Map<String, dynamic> toMap() {
    return {
      'tagId': tagId,
      'tagName': tagName,
      'usageCount': usageCount,
      'totalAmount': totalAmount,
      'entityTypeDistribution': entityTypeDistribution,
      'monthlyUsage': monthlyUsage,
    };
  }

  factory TagStatistics.fromMap(Map<String, dynamic> map) {
    return TagStatistics(
      tagId: map['tagId'],
      tagName: map['tagName'],
      usageCount: map['usageCount'],
      totalAmount: map['totalAmount'],
      entityTypeDistribution: Map<String, int>.from(map['entityTypeDistribution']),
      monthlyUsage: Map<String, double>.from(map['monthlyUsage']),
    );
  }
} 