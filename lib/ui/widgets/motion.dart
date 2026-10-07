import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Durações das animações do app.
abstract final class Motion {
  static const fast = Duration(milliseconds: 220);
  static const base = Duration(milliseconds: 340);
  static const slow = Duration(milliseconds: 750);
  static const curve = Curves.easeOutCubic;

  /// A duração a usar, ou zero quando o sistema pede menos movimento.
  static Duration of(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

/// Faz o conteúdo surgir subindo de leve.
///
/// [order] atrasa a entrada, para que os blocos de uma tela apareçam em
/// sequência, de cima para baixo.
class Reveal extends StatelessWidget {
  const Reveal({super.key, required this.child, this.order = 0});

  final Widget child;
  final int order;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    final delay = 70 * order.clamp(0, 6);
    final total = 420 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Motion.curve),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

/// Um número que conta até o novo valor quando ele muda.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount(
    this.value, {
    super.key,
    required this.format,
    this.style,
  });

  final double value;
  final String Function(double value) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: Motion.of(context, Motion.slow),
      curve: Motion.curve,
      builder: (context, current, _) => Text(format(current), style: style),
    );
  }
}

/// Anima uma fração entre 0 e 1 até o novo valor, para barras e anéis.
class AnimatedFraction extends StatelessWidget {
  const AnimatedFraction({
    super.key,
    required this.value,
    required this.builder,
  });

  final double value;
  final Widget Function(BuildContext context, double value) builder;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: Motion.of(context, Motion.slow),
      curve: Motion.curve,
      builder: (context, current, _) => builder(context, current),
    );
  }
}

/// Mostra uma das abas principais e anima a entrada ao trocar de aba.
///
/// As abas fora de vista continuam montadas, para manter rolagem e estado,
/// mas ficam fora da tela e sem animações rodando.
class BranchSwitcher extends StatefulWidget {
  const BranchSwitcher({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<BranchSwitcher> createState() => _BranchSwitcherState();
}

class _BranchSwitcherState extends State<BranchSwitcher>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: Motion.base,
    value: 1,
  );
  late final _curved = CurvedAnimation(
    parent: _controller,
    curve: Motion.curve,
  );
  late final _offset = Tween(
    begin: const Offset(0, 0.03),
    end: Offset.zero,
  ).animate(_curved);

  @override
  void didUpdateWidget(BranchSwitcher old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !MediaQuery.disableAnimationsOf(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: SlideTransition(
        position: _offset,
        child: Stack(
          fit: StackFit.expand,
          children: [
            for (final (index, child) in widget.children.indexed)
              Offstage(
                offstage: index != widget.index,
                child: TickerMode(enabled: index == widget.index, child: child),
              ),
          ],
        ),
      ),
    );
  }
}

/// Página que entra surgindo e subindo, e sai do mesmo jeito.
CustomTransitionPage<T> risePage<T>(GoRouterState state, Widget child) =>
    CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionDuration: Motion.base,
      reverseTransitionDuration: Motion.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: Motion.curve,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.97, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
    );
