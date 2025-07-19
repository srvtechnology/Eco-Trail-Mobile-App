import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ProfileHeader extends StatelessWidget {
  final double radius = 100;
  final String name;
  const ProfileHeader(this.name,{super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        CircleAvatar(
          radius: radius,
          backgroundColor: Color(0xFFEDE4FF),
          child: Center(
            child: SvgPicture.asset(
              'assets/profile_icon.svg',
              width: radius, // scale SVG within the circle
              height: radius,
              colorFilter: const ColorFilter.mode(
                Color(0xFF5E3FAA), // Icon color (dark purple)
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$name',
          style: TextStyle(
            fontSize: 30,
            fontFamily: 'extrabold',
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
