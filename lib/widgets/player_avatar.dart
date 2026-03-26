import 'dart:io';
import 'package:flutter/material.dart';

class PlayerAvatar extends StatelessWidget {
  final String name;
  final String? photoPath;
  final double size;
  final VoidCallback? onTap;
  final bool isWinner;

  const PlayerAvatar({
    super.key,
    required this.name,
    this.photoPath,
    this.size = 80,
    this.onTap,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isWinner
                  ? Colors.amber.withOpacity(0.3)
                  : Theme.of(context).colorScheme.primaryContainer,
              border: Border.all(
                color: isWinner ? Colors.amber : Theme.of(context).colorScheme.primary,
                width: isWinner ? 5 : 3,
              ),
              boxShadow: isWinner
                  ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                ClipOval(
                  child: photoPath != null && photoPath!.isNotEmpty
                      ? Image.file(
                          File(photoPath!),
                          fit: BoxFit.cover,
                          width: size,
                          height: size,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildInitial(name),
                        )
                      : _buildInitial(name),
                ),
                if (isWinner)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isWinner ? Colors.amber[800] : null,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInitial(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
