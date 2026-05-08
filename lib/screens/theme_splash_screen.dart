import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/word_battle_logo.dart';
import 'game_screen.dart';

class ThemeSplashScreen extends StatefulWidget {
  const ThemeSplashScreen({super.key});

  @override
  State<ThemeSplashScreen> createState() => _ThemeSplashScreenState();
}

class _ThemeSplashScreenState extends State<ThemeSplashScreen>
    with SingleTickerProviderStateMixin {
  // Total controller duration = assembly (1700 ms) + hold (300 ms).
  // Assembly progress is mapped to the first 85% of the controller via
  // [Interval]; the remaining tail is a still hold before the route push.
  static const _totalDuration = Duration(milliseconds: 2000);
  static const _assemblyEnd = 1700 / 2000;

  // Brief delay after the first frame so the splash doesn't pop straight from
  // the native splash into a moving animation.
  static const _startDelay = Duration(milliseconds: 150);

  // Responsive sizing breakpoint between compact (mobile) and roomier
  // (desktop / web) layouts.
  static const _compactBreakpointDp = 600.0;
  static const _markSizeCompact = 96.0;
  static const _markSizeRoomy = 84.0;

  late final AnimationController _ctrl;
  late final Animation<double> _assembly;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _totalDuration);
    _assembly = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, _assemblyEnd),
    );
    _ctrl.addStatusListener(_onAnimationStatus);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Future.delayed(_startDelay, () {
        if (!mounted) return;
        _ctrl.forward();
      });
    });
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const GameScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.wbTokens;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final markSize = width < _compactBreakpointDp
        ? _markSizeCompact
        : _markSizeRoomy;

    Widget mark = AnimatedWordBattleMark(size: markSize, progress: _assembly);
    if (isDark) {
      mark = Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: tokens.borderSubtle),
        ),
        child: mark,
      );
    }

    return Scaffold(
      backgroundColor: tokens.background,
      body: Center(child: mark),
    );
  }
}
