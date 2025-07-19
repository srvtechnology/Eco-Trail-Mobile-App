import 'package:flutter/material.dart';

class EcoTrailHeader extends StatelessWidget {
  const EcoTrailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        // Logo
        Image.asset(
          'assets/ecotraillogo.png',
          height: 120,
        ),

        const SizedBox(height: 12),

        // Titles
        Text(
          'Nyo Heritage',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'extrabold',
            color: Colors.white,
            shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
          ),
        ),
        Text(
          'Ngang Lhakhang to Ura - Sumthrang',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'bold',
            color: Colors.white,
            shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
          ),
        ),
        Text(
          'ECO Cultural Trail',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontFamily: 'bold',
            color: Colors.white,
            shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
          ),
        ),
      ],
    );
  }
}
