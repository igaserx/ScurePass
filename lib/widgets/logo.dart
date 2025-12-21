import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo(
     
    {
    super.key,
    this.size = 80,
    this.color =  Colors.blueAccent,
  });

  final double size ;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.lock_outline_rounded,
      color: color,
      size: size,
    );
  }
}
