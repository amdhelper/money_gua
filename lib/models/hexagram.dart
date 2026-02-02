class Hexagram {
  final int id;
  final String binary; // '1' for Yang, '0' for Yin, bottom to top
  final String name;
  final String title;
  final String upperTrigram;
  final String lowerTrigram;
  final String description;
  final String summary;

  const Hexagram({
    required this.id,
    required this.binary,
    required this.name,
    required this.title,
    required this.upperTrigram,
    required this.lowerTrigram,
    required this.description,
    required this.summary,
  });

  factory Hexagram.fromJson(Map<String, dynamic> json) {
    return Hexagram(
      id: json['id'],
      binary: json['binary'],
      name: json['name'],
      title: json['title'],
      upperTrigram: json['upperTrigram'],
      lowerTrigram: json['lowerTrigram'],
      description: json['description'],
      summary: json['summary'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'binary': binary,
      'name': name,
      'title': title,
      'upperTrigram': upperTrigram,
      'lowerTrigram': lowerTrigram,
      'description': description,
      'summary': summary,
    };
  }
}
