class Player {
  final int? id;
  final String name;
  final String? photoPath;
  int score;

  Player({
    this.id,
    required this.name,
    this.photoPath,
    this.score = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoPath': photoPath,
      'score': score,
    };
  }

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as int?,
      name: map['name'] as String,
      photoPath: map['photoPath'] as String?,
      score: map['score'] as int? ?? 0,
    );
  }

  Player copyWith({
    int? id,
    String? name,
    String? photoPath,
    int? score,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      photoPath: photoPath ?? this.photoPath,
      score: score ?? this.score,
    );
  }
}
