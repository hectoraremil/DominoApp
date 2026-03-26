import 'dart:io';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../database/database_helper.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../widgets/player_avatar.dart';
import '../widgets/score_card.dart';

class _WinnerPhoto extends StatefulWidget {
  final String? photoPath;
  final String name;

  const _WinnerPhoto({this.photoPath, required this.name});

  @override
  State<_WinnerPhoto> createState() => _WinnerPhotoState();
}

class _WinnerPhotoState extends State<_WinnerPhoto>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.amber, Colors.orange],
              ),
              border: Border.all(color: Colors.white, width: 5),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.8),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.amber.withOpacity(0.4 * _pulseAnimation.value),
                  blurRadius: 50 * _pulseAnimation.value,
                  spreadRadius: 10 * _pulseAnimation.value,
                ),
              ],
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: widget.photoPath != null && widget.photoPath!.isNotEmpty
                    ? Image.file(
                        File(widget.photoPath!),
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                      )
                    : Container(
                        color: Colors.deepPurple,
                        child: Center(
                          child: Text(
                            widget.name[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 80,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class GameScreen extends StatefulWidget {
  final List<Player> players;

  const GameScreen({super.key, required this.players});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<Player> _players;
  final TextEditingController _scoreController = TextEditingController();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _players = widget.players.map((p) => Player(
          id: p.id,
          name: p.name,
          photoPath: p.photoPath,
          score: 0,
        )).toList();
  }

  void _addScore(int playerIndex) {
    final score = int.tryParse(_scoreController.text);
    if (score != null && score > 0) {
      setState(() {
        _players[playerIndex].score += score;
      });
      _scoreController.clear();
    }
  }

  void _finishGame() {
    final leader = _players.reduce((a, b) => a.score >= b.score ? a : b);
    _showWinnerDialog(leader);
  }

  void _showWinnerDialog(Player winner) {
    _confettiController.play();
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.deepPurple.shade900,
                Colors.purple.shade900,
                Colors.black,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.amber, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.3),
                blurRadius: 50,
                spreadRadius: 10,
              ),
              BoxShadow(
                color: Colors.purple.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 100,
                      shadows: [
                        Shadow(color: Colors.amber, blurRadius: 30),
                        Shadow(color: Colors.orange, blurRadius: 50),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Colors.amber, Colors.orange, Colors.amber],
                        ).createShader(bounds),
                        child: const Text(
                          '🏆 CAMPEONES 🏆',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(
                      opacity: value,
                      child: _WinnerPhoto(
                        photoPath: winner.photoPath,
                        name: winner.name,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800, milliseconds: 800),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.6),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          '${winner.score} PUNTOS',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600, milliseconds: 1200),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 400, milliseconds: index * 100),
                          curve: Curves.elasticOut,
                          builder: (context, scale, _) {
                            return Transform.scale(
                              scale: scale,
                              child: const Text('⭐', style: TextStyle(fontSize: 32)),
                            );
                          },
                        );
                      }),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600, milliseconds: 1500),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.scale(
                      scale: value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _resetGame();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Nueva Partida'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final playerScores = <String, int>{};
                              for (var player in _players) {
                                playerScores[player.name] = player.score;
                              }
                              final game = Game(
                                date: DateTime.now(),
                                playerIds: _players.map((p) => p.id!).toList(),
                                winnerName: winner.name,
                                winningScore: winner.score,
                                winnerPhotoPath: winner.photoPath,
                                playerScores: playerScores,
                              );
                              await DatabaseHelper.instance.insertGame(game);
                              if (context.mounted) Navigator.pop(context);
                              if (context.mounted) Navigator.pop(context);
                            },
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetGame() {
    setState(() {
      for (var player in _players) {
        player.score = 0;
      }
    });
  }

  void _showAddScoreDialog(int playerIndex) {
    _scoreController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Agregar puntos a ${_players[playerIndex].name}'),
        content: TextField(
          controller: _scoreController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Puntos',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _addScore(playerIndex);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Domino Beriguete'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Reiniciar Partida'),
                content: const Text('¿Estás seguro de reiniciar los puntos?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _resetGame();
                    },
                    child: const Text('Reiniciar'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.flag, color: Colors.green),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _finishGame,
                      icon: const Icon(Icons.emoji_events),
                      label: const Text('Terminar Partida'),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _players.length,
                  itemBuilder: (context, index) {
                    final player = _players[index];
                    final leader = _players.reduce((a, b) => a.score >= b.score ? a : b);
                    final isLeader = player.id == leader.id && player.score > 0;

                    return Card(
                      elevation: isLeader ? 8 : 2,
                      child: InkWell(
                        onTap: () => _showAddScoreDialog(index),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PlayerAvatar(
                                name: player.name,
                                photoPath: player.photoPath,
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              ScoreCard(
                                score: player.score,
                                isLeading: isLeader,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Toca la tarjeta de un jugador para agregar puntos',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              particleDrag: 0.05,
              emissionFrequency: 0.02,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.amber,
                Colors.orange,
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.purple,
                Colors.yellow,
                Colors.pink,
              ],
              strokeWidth: 2,
              strokeColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
