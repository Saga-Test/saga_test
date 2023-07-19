import 'package:flutter/material.dart';

class SaPageCard extends StatelessWidget {
  const SaPageCard({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.color,
  }) : super(key: key);

  final Widget child;
  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      height: height ?? MediaQuery.of(context).size.height * 0.85,
      child: Card(
        color: color ?? Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.zero,
        child: child,
      ),
    );
  }
}
