import 'package:flutter/material.dart';

class YinYangSwitch extends StatefulWidget {
  final bool isYang;
  final VoidCallback? onToggle;
  final double width;
  final double height;
  final Color activeColor;
  final Color inactiveColor;

  const YinYangSwitch({
    super.key,
    required this.isYang,
    this.onToggle,
    this.width = 200,
    this.height = 40,
    this.activeColor = const Color(0xFFFFD700), // Gold
    this.inactiveColor = const Color(0xFF424242), // Dark Grey
  });

  @override
  State<YinYangSwitch> createState() => _YinYangSwitchState();
}

class _YinYangSwitchState extends State<YinYangSwitch>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToggle,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.transparent, // Hit test area
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background container (optional context)

            // The Bar(s)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: widget.isYang ? _buildYangBar() : _buildYinBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYangBar() {
    return Container(
      key: const ValueKey('yang'),
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.activeColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: widget.activeColor.withValues(alpha: 0.4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildYinBar() {
    double gap = widget.width * 0.15; // Gap in the middle
    double segmentWidth = (widget.width - gap) / 2;

    return Row(
      key: const ValueKey('yin'),
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: segmentWidth,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Container(
          width: segmentWidth,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.inactiveColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
