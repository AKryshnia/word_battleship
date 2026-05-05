import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/app_theme.dart';

/// Fixed-height bottom zone for move history.
///
/// Layout: ХОДЫ header + up to 2 chip rows in a fixed-height scrollable
/// area. When chips overflow the section, a chevron icon appears in the
/// header. Clicking it scrolls the chip area; on desktop the mouse wheel
/// also scrolls. The chevron direction reflects scroll state:
///   - chevron-down → there are more chips below (click scrolls down one row)
///   - chevron-up   → scrolled to the bottom (click scrolls back to top)
///
/// Board never jumps during play — height is constant.
class MoveLogBar extends StatefulWidget {
  final List<MoveLogEntry> moves;
  /// Mobile-only: caps the bar's height and enables adaptive sizing.
  /// When null the bar uses its fixed desktop height.
  final double? maxHeight;
  const MoveLogBar({super.key, required this.moves, this.maxHeight});

  @override
  State<MoveLogBar> createState() => _MoveLogBarState();
}

class _MoveLogBarState extends State<MoveLogBar> {
  late final ScrollController _scrollController;
  bool _canScrollDown = false;
  bool _canScrollUp = false;

  // 10 top + 24 header + 6 gap + (24 * 2 chips + 5 row gap) + 10 bottom.
  static const double _barH = AppDimensions.moveLogBarH;

  // Chip geometry. Keep in sync with _MoveChip.
  static const double _chipHeight = 23.0;
  static const double _chipGap = 6.0;
  static const double _headerHeight = 24.0;
  static const double _headerToChipsGap = 6.0;

  // One row's worth of scroll (chip + run gap).
  static const double _scrollStep = _chipHeight + _chipGap;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollFlags);
  }

  @override
  void didUpdateWidget(MoveLogBar old) {
    super.didUpdateWidget(old);
    // Moves changed → scroll metrics may have changed; recheck after layout.
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateScrollFlags());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollFlags);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollFlags() {
    if (!mounted) return;
    if (!_scrollController.hasClients) {
      if (_canScrollDown || _canScrollUp) {
        setState(() {
          _canScrollDown = false;
          _canScrollUp = false;
        });
      }
      return;
    }
    final pos = _scrollController.position;
    final hasOverflow = pos.maxScrollExtent > 0;
    final atTop = pos.pixels <= 0.5;
    final atBottom = pos.pixels >= pos.maxScrollExtent - 0.5;
    final canDown = hasOverflow && !atBottom;
    final canUp = hasOverflow && !atTop;
    if (canDown != _canScrollDown || canUp != _canScrollUp) {
      setState(() {
        _canScrollDown = canDown;
        _canScrollUp = canUp;
      });
    }
  }

  void _animateTo(double offset) {
    if (!_scrollController.hasClients) return;
    final target = offset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _onChevronTap() {
    // Down by one row when there's more below; otherwise jump back to top.
    if (_canScrollDown) {
      _animateTo(_scrollController.offset + _scrollStep);
    } else if (_canScrollUp) {
      _animateTo(0);
    }
  }

  // ── Chip max-width cap ──────────────────────────────────────────────────

  /// Chips size to their natural text width; the only upper bound is the row
  /// width itself, so an unusually long phrase still fits (and Wrap pushes the
  /// next chip to a new row).
  double _maxChipWidth(double availW) => availW > 0 ? availW : double.infinity;

  // ── Build ─────────────────────────────────────────────────────────────────

  // top padding + bottom padding + header + header-to-chips gap
  static const double _fixedOverhead =
      10.0 + 10.0 + _headerHeight + _headerToChipsGap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, outer) {
        final isNarrow = outer.maxWidth < 460;
        final hPad = isNarrow ? 14.0 : AppDimensions.shellPadH;
        final maxChipW = _maxChipWidth(outer.maxWidth - hPad * 2);

        IconData? chevron;
        if (_canScrollDown) {
          chevron = Icons.keyboard_arrow_down;
        } else if (_canScrollUp) {
          chevron = Icons.keyboard_arrow_up;
        }

        final decoration = const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderSubtle)),
        );
        final padding = EdgeInsets.fromLTRB(hPad, 10, hPad, 10);

        final header = SizedBox(
          height: _headerHeight,
          child: _MoveLogHeader(
            chevron: chevron,
            onChevronTap: _onChevronTap,
          ),
        );

        final scrollView = Scrollbar(
          controller: _scrollController,
          thumbVisibility: _canScrollDown || _canScrollUp,
          trackVisibility: _canScrollDown || _canScrollUp,
          child: SingleChildScrollView(
            controller: _scrollController,
            primary: false,
            physics: const ClampingScrollPhysics(),
            child: Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                spacing: _chipGap,
                runSpacing: _chipGap,
                children: [
                  for (final move in widget.moves)
                    _MoveChip(move: move, maxWidth: maxChipW),
                ],
              ),
            ),
          ),
        );

        if (widget.maxHeight == null) {
          // Desktop: fixed height, chips area fills remaining via Expanded.
          return Container(
            height: _barH,
            decoration: decoration,
            padding: padding,
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                header,
                const SizedBox(height: _headerToChipsGap),
                Expanded(child: scrollView),
              ],
            ),
          );
        }

        // Mobile: bar shrinks to content, capped at maxHeight.
        // ConstrainedBox lets SingleChildScrollView size to its Wrap content
        // (shrink-wrap) and caps at chipsMaxH — scroll kicks in only then.
        final chipsMaxH = (widget.maxHeight! - _fixedOverhead).clamp(
          _scrollStep,
          double.infinity,
        );
        return Container(
          constraints: BoxConstraints(minHeight: _barH),
          decoration: decoration,
          padding: padding,
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: _headerToChipsGap),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: chipsMaxH),
                child: scrollView,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _MoveLogHeader extends StatelessWidget {
  final IconData? chevron;
  final VoidCallback onChevronTap;

  const _MoveLogHeader({required this.chevron, required this.onChevronTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('ХОДЫ', style: AppTextStyles.moveLogLabel),
        const Spacer(),
        if (chevron != null)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onChevronTap,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(chevron, size: 18, color: AppColors.text2),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Chip ──────────────────────────────────────────────────────────────────────

class _MoveChip extends StatelessWidget {
  final MoveLogEntry move;
  final double? maxWidth;

  const _MoveChip({required this.move, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final isHit = move.isHit;
    final bg = isHit ? const Color(0x14C05C3C) : AppColors.background;
    final border = isHit ? const Color(0x28C05C3C) : AppColors.border;
    final textColor = isHit ? AppColors.cellHitBorder : AppColors.text3;
    final markerStyle = AppTextStyles.chipLabel.copyWith(
      color: textColor,
      fontSize: isHit ? 9.0 : 15.0,
      height: 1,
    );
    final phraseStyle = AppTextStyles.chipLabel.copyWith(
      color: textColor,
      height: 1,
    );

    final chip = SizedBox(
      height: _MoveLogBarState._chipHeight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(isHit ? '●' : '×', style: markerStyle),
            Flexible(
              child: Text(
                ' ${move.phrase}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: phraseStyle,
              ),
            ),
          ],
        ),
      ),
    );

    if (maxWidth == null) return chip;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth!),
      child: chip,
    );
  }
}
