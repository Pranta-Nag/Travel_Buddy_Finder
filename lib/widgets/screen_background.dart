import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:travel_buddy_finder/utils/asset_path.dart';

class ScreenBackground extends StatelessWidget {
  final Widget child;

  const ScreenBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          Positioned.fill(
            child: SvgPicture.asset(
              AssetsPath.backgroundImg,
              fit: BoxFit.cover,
            ),
          ),
          child,
        ],
      ),
    );
  }
}