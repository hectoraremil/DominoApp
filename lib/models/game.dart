class Game {
  final int? id;
  final DateTime date;
  final List<int> playerIds;
  final String winnerName;
  final int winningScore;
  final String? winnerPhotoPath;
  final Map<String, int> playerScores;

  Game({
    this.id,
    required this.date,
    required this.playerIds,
    required this.winnerName,
    required this.winningScore,
    this.winnerPhotoPath,
    this.playerScores = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'playerIds': playerIds.join(','),
      'winnerName': winnerName,
      'winningScore': winningScore,
      'winnerPhotoPath': winnerPhotoPath,
      'playerScores': playerScores.entries.map((e) => '${e.key}:${e.value}').join(','),
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    final playerIdsStr = map['playerIds'] as String;
    final playerScoresStr = map['playerScores'] as String? ?? '';
    final Map<String, int> playerScores = {};
    
    if (playerScoresStr.isNotEmpty) {
      for (var entry in playerScoresStr.split(',')) {
        final parts = entry.split(':');
        if (parts.length == 2) {
          playerScores[parts[0]] = int.tryParse(parts[1]) ?? 0;
        }
      }
    }
    
    return Game(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      playerIds: playerIdsStr.isEmpty 
          ? [] 
          : playerIdsStr.split(',').map((e) => int.parse(e)).toList(),
      winnerName: map['winnerName'] as String,
      winningScore: map['winningScore'] as int,
      winnerPhotoPath: map['winnerPhotoPath'] as String?,
      playerScores: playerScores,
    );
  }
}
