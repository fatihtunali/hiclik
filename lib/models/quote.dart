class Quote {
  final String text;

  Quote({
    required this.text,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}