class Hair {
  final String color;
  final String type;

  Hair({required this.color, required this.type});

  factory Hair.fromJson(Map<String, dynamic> json) {
    return Hair(color: json['color'] ?? '', type: json['type'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'color': color, 'type': type};
  }
}
