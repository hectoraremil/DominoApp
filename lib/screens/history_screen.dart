import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/game.dart';
import '../models/player.dart';
import '../widgets/player_avatar.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Game> _games = [];
  Map<int, List<Player>> _gamePlayers = {};

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    final games = await DatabaseHelper.instance.getAllGames();
    final Map<int, List<Player>> gamePlayers = {};

    for (var game in games) {
      final players = await DatabaseHelper.instance.getPlayersByIds(game.playerIds);
      gamePlayers[game.id!] = players;
    }

    setState(() {
      _games = games;
      _gamePlayers = gamePlayers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial - Domino Beriguete'),
        centerTitle: true,
      ),
      body: _games.isEmpty
          ? const Center(
              child: Text('No hay partidas jugadas aún'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _games.length,
              itemBuilder: (context, index) {
                final game = _games[index];
                final players = _gamePlayers[game.id] ?? [];
                final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');

                final sortedPlayers = players.toList()
                  ..sort((a, b) {
                    final scoreA = game.playerScores[a.name] ?? 0;
                    final scoreB = game.playerScores[b.name] ?? 0;
                    return scoreB.compareTo(scoreA);
                  });

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              dateFormat.format(game.date),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            PlayerAvatar(
                              name: game.winnerName,
                              photoPath: game.winnerPhotoPath,
                              size: 50,
                              isWinner: true,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    game.winnerName,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    '${game.winningScore} puntos',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.amber[800],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Puntuaciones:',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: game.playerScores.entries.map<Widget>((entry) {
                            final isWinner = entry.key == game.winnerName;
                            return Chip(
                              avatar: CircleAvatar(
                                backgroundColor: isWinner ? Colors.amber : null,
                                child: isWinner
                                    ? const Icon(Icons.emoji_events, color: Colors.white, size: 16)
                                    : null,
                              ),
                              label: Text('${entry.key}: ${entry.value} pts'),
                              backgroundColor: isWinner 
                                  ? Colors.amber.withOpacity(0.2) 
                                  : null,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
