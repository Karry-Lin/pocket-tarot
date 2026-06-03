part of '../../main.dart';

class ScreenFrame extends StatelessWidget {
  const ScreenFrame({
    super.key,
    required this.title,
    required this.child,
    this.eyebrow,
    this.trailing,
    this.scrollable = true,
  });

  final String title;
  final String? eyebrow;
  final Widget? trailing;
  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return _RootBackExitGuard(
      child: AppBackdrop(
        child: SafeArea(
          child: scrollable
              ? CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(26, 63, 26, 8),
                      sliver: SliverToBoxAdapter(child: _header(context)),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(26, 12, 26, 18),
                      sliver: SliverToBoxAdapter(child: child),
                    ),
                  ],
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(26, 63, 26, 8),
                      child: _header(context),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(26, 12, 26, 10),
                        child: child,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null) ...[
                EyebrowText(eyebrow!),
                const SizedBox(height: 6),
              ],
              Text(title, style: Theme.of(context).textTheme.displaySmall),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class AppBackdrop extends StatelessWidget {
  const AppBackdrop({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ArcanaColors.ink,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _kAppFrameMaxWidth),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF20102F),
                  Color(0xFF160C25),
                  Color(0xFF07030D),
                ],
                stops: [0, 0.42, 1],
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CustomPaint(painter: _CelestialBackdropPainter()),
                ClipRRect(
                  borderRadius: BorderRadius.circular(34),
                  child: child,
                ),
                Positioned(
                  top: 13,
                  right: 12,
                  bottom: 13,
                  left: 12,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      key: const ValueKey('app-chrome-frame'),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(34),
                        border: Border.all(
                          color: _ArcanaColors.gold.withValues(alpha: 0.13),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CelestialBackdropPainter extends CustomPainter {
  const _CelestialBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = _ArcanaColors.gold.withValues(alpha: 0.015)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 38) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final starPaint = Paint()
      ..color = _ArcanaColors.ivory.withValues(alpha: 0.22);
    const offsets = [
      Offset(0.12, 0.15),
      Offset(0.24, 0.31),
      Offset(0.42, 0.12),
      Offset(0.62, 0.22),
      Offset(0.78, 0.36),
      Offset(0.88, 0.16),
      Offset(0.18, 0.58),
      Offset(0.36, 0.72),
      Offset(0.58, 0.64),
      Offset(0.76, 0.82),
      Offset(0.91, 0.67),
    ];
    for (final offset in offsets) {
      canvas.drawCircle(
        Offset(size.width * offset.dx, size.height * offset.dy),
        0.8,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class EyebrowText extends StatelessWidget {
  const EyebrowText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: _bodyTextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        color: _ArcanaColors.gold2,
        height: 1,
      ).copyWith(fontFamilyFallback: const ['JetBrains Mono', 'monospace']),
    );
  }
}

class ArcanaLoadingView extends StatelessWidget {
  const ArcanaLoadingView({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('arcana-loading-view'),
      width: double.infinity,
      height: 560,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 36,
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _ArcanaColors.gold2.withValues(alpha: 0.1),
                    _ArcanaColors.wine.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.38, 1],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ArcanaLoadingPagePainter()),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const _ArcanaLoadingSpread(),
              const SizedBox(height: 22),
              const EyebrowText('Reading in progress'),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 18),
              const _ArcanaLoadingPulse(),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArcanaLoadingSpread extends StatefulWidget {
  const _ArcanaLoadingSpread();

  @override
  State<_ArcanaLoadingSpread> createState() => _ArcanaLoadingSpreadState();
}

class _ArcanaLoadingSpreadState extends State<_ArcanaLoadingSpread>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final pulse = 0.5 + 0.5 * math.sin(progress * math.pi * 2);

        return SizedBox(
          key: const ValueKey('arcana-loading-orbit'),
          width: 220,
          height: 164,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ArcanaLoadingOrbitPainter(
                    progress: progress,
                    pulse: pulse,
                  ),
                ),
              ),
              Positioned(
                left: 46,
                bottom: 20,
                child: _LoadingTarotBack(
                  key: const ValueKey('arcana-loading-card-0'),
                  angle: -0.28 + 0.03 * math.sin(progress * math.pi * 2),
                  lift: 3 * math.sin((progress + 0.08) * math.pi * 2),
                  opacity: 0.76,
                ),
              ),
              Positioned(
                right: 46,
                bottom: 20,
                child: _LoadingTarotBack(
                  key: const ValueKey('arcana-loading-card-2'),
                  angle: 0.28 + 0.03 * math.sin((progress + 0.5) * math.pi * 2),
                  lift: 3 * math.sin((progress + 0.42) * math.pi * 2),
                  opacity: 0.76,
                ),
              ),
              Positioned(
                top: 22 + 6 * math.sin((progress + 0.18) * math.pi * 2),
                child: _LoadingTarotBack(
                  key: const ValueKey('arcana-loading-card-1'),
                  angle: 0.04 * math.sin((progress + 0.25) * math.pi * 2),
                  lift: 0,
                  opacity: 1,
                  emphasized: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingTarotBack extends StatelessWidget {
  const _LoadingTarotBack({
    super.key,
    required this.angle,
    required this.lift,
    required this.opacity,
    this.emphasized = false,
  });

  final double angle;
  final double lift;
  final double opacity;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, lift),
      child: Transform.rotate(
        angle: angle,
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: emphasized ? 64 : 60,
            height: emphasized ? 96 : 90,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _ArcanaColors.gold2.withValues(
                  alpha: emphasized ? 0.92 : 0.58,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: _ArcanaColors.gold.withValues(
                    alpha: emphasized ? 0.28 : 0.14,
                  ),
                  blurRadius: emphasized ? 24 : 16,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.58),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/card-back.png',
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.medium,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Colors.transparent,
                          _ArcanaColors.ink.withValues(alpha: 0.38),
                        ],
                        stops: const [0.36, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcanaLoadingPagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.43);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _ArcanaColors.gold.withValues(alpha: 0.1);
    final softPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _ArcanaColors.muted.withValues(alpha: 0.08);

    canvas.drawCircle(center, 150, paint);
    canvas.drawCircle(center, 104, softPaint);
    canvas.drawLine(
      Offset(center.dx - 124, center.dy),
      Offset(center.dx + 124, center.dy),
      softPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 124),
      Offset(center.dx, center.dy + 124),
      softPaint,
    );

    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _ArcanaColors.gold2.withValues(alpha: 0.38);
    for (var index = 0; index < 10; index += 1) {
      final angle = index * math.pi / 5;
      final radius = index.isEven ? 146.0 : 102.0;
      canvas.drawCircle(
        Offset(
          center.dx + math.cos(angle) * radius,
          center.dy + math.sin(angle) * radius,
        ),
        1.1,
        starPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ArcanaLoadingPulse extends StatefulWidget {
  const _ArcanaLoadingPulse();

  @override
  State<_ArcanaLoadingPulse> createState() => _ArcanaLoadingPulseState();
}

class _ArcanaLoadingPulseState extends State<_ArcanaLoadingPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final wave =
                0.5 +
                0.5 *
                    math.sin((_controller.value + index * 0.18) * math.pi * 2);
            return Container(
              width: 24,
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: _ArcanaColors.gold2.withValues(
                  alpha: 0.22 + 0.58 * wave,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ArcanaLoadingOrbitPainter extends CustomPainter {
  const _ArcanaLoadingOrbitPainter({
    required this.progress,
    required this.pulse,
  });

  final double progress;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.55);
    final primaryOrbit = Rect.fromCenter(
      center: center,
      width: 194,
      height: 116,
    );
    final secondaryOrbit = Rect.fromCenter(
      center: center,
      width: 146,
      height: 86,
    );

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _ArcanaColors.gold.withValues(alpha: 0.25 + 0.06 * pulse);
    final dimOrbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = _ArcanaColors.muted.withValues(alpha: 0.18);
    final pathPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = _ArcanaColors.gold2.withValues(alpha: 0.48 + 0.22 * pulse);

    canvas.drawOval(primaryOrbit, orbitPaint);
    canvas.drawOval(secondaryOrbit, dimOrbitPaint);

    final arcStart = progress * math.pi * 2;
    canvas.drawArc(primaryOrbit, arcStart, math.pi * 0.34, false, pathPaint);

    final starPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = _ArcanaColors.gold2.withValues(alpha: 0.72);
    for (var index = 0; index < 8; index += 1) {
      final angle = progress * math.pi * 2 + index * math.pi / 4;
      final x = center.dx + math.cos(angle) * 97;
      final y = center.dy + math.sin(angle) * 58;
      final radius = index.isEven ? 1.4 : 0.9;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArcanaLoadingOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulse != pulse;
  }
}

enum ArcanaPrimaryButtonTone { gold, danger }

class ArcanaPrimaryButton extends StatelessWidget {
  const ArcanaPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.tone = ArcanaPrimaryButtonTone.gold,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ArcanaPrimaryButtonTone tone;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final gradient = switch (tone) {
      ArcanaPrimaryButtonTone.gold => const LinearGradient(
        colors: [Color(0xFFF5DA95), Color(0xFFB8832F)],
      ),
      ArcanaPrimaryButtonTone.danger => const LinearGradient(
        colors: [Color(0xFFFF8F82), Color(0xFFC4363E)],
      ),
    };
    final shadowColor = switch (tone) {
      ArcanaPrimaryButtonTone.gold => const Color(0xFFB8832F),
      ArcanaPrimaryButtonTone.danger => const Color(0xFFC4363E),
    };
    final foregroundColor = switch (tone) {
      ArcanaPrimaryButtonTone.gold => _ArcanaColors.ink2,
      ArcanaPrimaryButtonTone.danger => _ArcanaColors.ivory,
    };
    final disabledBackgroundColor = switch (tone) {
      ArcanaPrimaryButtonTone.gold => _ArcanaColors.gold.withValues(
        alpha: 0.14,
      ),
      ArcanaPrimaryButtonTone.danger => const Color(
        0xFFC4363E,
      ).withValues(alpha: 0.16),
    };
    final disabledBorderColor = switch (tone) {
      ArcanaPrimaryButtonTone.gold => _ArcanaColors.gold2.withValues(
        alpha: 0.36,
      ),
      ArcanaPrimaryButtonTone.danger => const Color(
        0xFFFF8F82,
      ).withValues(alpha: 0.38),
    };
    final resolvedForegroundColor = enabled
        ? foregroundColor
        : switch (tone) {
            ArcanaPrimaryButtonTone.gold => _ArcanaColors.gold2,
            ArcanaPrimaryButtonTone.danger => const Color(0xFFFFC3BC),
          };

    return Material(
      color: Colors.transparent,
      shape: const StadiumBorder(),
      child: Ink(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: enabled ? gradient : null,
          color: enabled ? null : disabledBackgroundColor,
          border: enabled ? null : Border.all(color: disabledBorderColor),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: onPressed,
          customBorder: const StadiumBorder(),
          child: Center(
            child: DefaultTextStyle.merge(
              style: _bodyTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: resolvedForegroundColor,
                height: 1,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 76, this.radius = 24});

  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _ArcanaColors.gold2.withValues(alpha: 0.46)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 36,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Image.asset(
        'assets/images/pocket-tarot-logo.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.ornate = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool ornate;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _ArcanaColors.gold.withValues(alpha: 0.25)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF241135).withValues(alpha: 0.94),
            const Color(0xFF0C0615).withValues(alpha: 0.94),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 46,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0),
                      ],
                      stops: const [0, 0.28],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.035),
                    ),
                  ),
                ),
              ),
            ),
            if (ornate)
              Positioned.fill(
                child: IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius - 6),
                        border: Border.all(
                          color: _ArcanaColors.gold2.withValues(alpha: 0.16),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

class TagPill extends StatelessWidget {
  const TagPill({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 24),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _ArcanaColors.gold.withValues(alpha: 0.27)),
        color: _ArcanaColors.ink.withValues(alpha: 0.28),
      ),
      child: Text(
        text,
        style: _bodyTextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: _ArcanaColors.gold2,
          height: 1,
        ),
      ),
    );
  }
}
