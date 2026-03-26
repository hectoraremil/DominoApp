import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../database/database_helper.dart';
import '../models/player.dart';
import 'game_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  List<Player> _players = [];
  List<Player> _selectedPlayers = [];

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    final players = await DatabaseHelper.instance.getAllPlayers();
    setState(() {
      _players = players;
      _selectedPlayers = players.take(4).toList();
    });
  }

  Future<void> _addPlayer() async {
    final nameController = TextEditingController();
    String? photoPath;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Nuevo Jugador'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final XFile? image = await _picker.pickImage(
                    source: ImageSource.gallery,
                    maxWidth: 500,
                    maxHeight: 500,
                  );
                  if (image != null) {
                    setDialogState(() {
                      photoPath = image.path;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      photoPath != null ? FileImage(File(photoPath!)) : null,
                  child: photoPath == null
                      ? const Icon(Icons.add_a_photo, size: 30)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  String savedPath = photoPath ?? '';
                  if (photoPath != null && photoPath!.isNotEmpty) {
                    savedPath = await DatabaseHelper.instance.savePhoto(
                      File(photoPath!),
                      nameController.text,
                    );
                  }
                  final player = Player(
                    name: nameController.text,
                    photoPath: savedPath.isNotEmpty ? savedPath : null,
                  );
                  await DatabaseHelper.instance.insertPlayer(player);
                  _loadPlayers();
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _startGame() {
    if (_selectedPlayers.length >= 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(players: _selectedPlayers),
        ),
      ).then((_) => _loadPlayers());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos 2 jugadores')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Domino Beriguete'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _players.isEmpty
                ? const Center(
                    child: Text('No hay jugadores. Agrega algunos!'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _players.length,
                    itemBuilder: (context, index) {
                      final player = _players[index];
                      final isSelected = _selectedPlayers.contains(player);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: player.photoPath != null
                                ? FileImage(File(player.photoPath!))
                                : null,
                            child: player.photoPath == null
                                ? Text(player.name[0].toUpperCase())
                                : null,
                          ),
                          title: Text(player.name),
                          subtitle: Text('Puntos: ${player.score}'),
                          trailing: Checkbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  if (_selectedPlayers.length < 4) {
                                    _selectedPlayers.add(player);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Máximo 4 jugadores'),
                                      ),
                                    );
                                  }
                                } else {
                                  _selectedPlayers.remove(player);
                                }
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _addPlayer,
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Jugador'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _selectedPlayers.length >= 2 ? _startGame : null,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Iniciar Juego'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
