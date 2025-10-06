class RoundData {
  final int roundNumber;
  final List<int> bids;
  final List<int> extras;
  final List<double> points;

  RoundData({required this.roundNumber, required this.bids, required this.extras, required this.points});

  Map<String, dynamic> toJson() => {'roundNumber': roundNumber, 'bids': bids, 'extras': extras, 'points': points};

  factory RoundData.fromJson(Map<String, dynamic> json) => RoundData(roundNumber: json['roundNumber'], bids: List<int>.from(json['bids']), extras: List<int>.from(json['extras']), points: List<double>.from(json['points']));
}
