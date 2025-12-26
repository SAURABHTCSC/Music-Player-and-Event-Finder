
import 'package:flutter/material.dart';

class ArtistTile extends StatelessWidget {
  final String name;
  final String imagePath;
  final VoidCallback onTap;

  const ArtistTile({
    super.key,
    required this.name,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 35, backgroundImage: AssetImage(imagePath)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
