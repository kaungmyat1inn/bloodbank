import 'package:flutter/material.dart';

/// Breakpoint at/above which we treat the screen as a "desktop" layout
/// (sidebar navigation, wider content, multi-column grids).
const double kDesktopBreakpoint = 900;

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= kDesktopBreakpoint;

/// Picks between a desktop and mobile widget based on the current width.
/// Handy for whole-screen layout swaps.
class Responsive extends StatelessWidget {
  const Responsive({super.key, required this.mobile, required this.desktop});

  final Widget mobile;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= kDesktopBreakpoint) {
          return desktop;
        }
        return mobile;
      },
    );
  }
}

/// Centers content and caps its width on very wide (desktop) screens so text
/// and forms don't stretch edge-to-edge.
class MaxWidthBox extends StatelessWidget {
  const MaxWidthBox({super.key, required this.child, this.maxWidth = 1000});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
