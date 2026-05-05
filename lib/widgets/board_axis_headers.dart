import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/board_style.dart';

// Column header row — each noun is rotated 90° CCW so it reads bottom-to-top.
class BoardColumnHeaderRow extends StatelessWidget {
  final List<NounEntry> nouns;
  final double cellSize;
  final double gap;
  final double axisFs;
  final int? activeIndex;
  final double headerHeight;
  final BoardStyleConfig style;

  const BoardColumnHeaderRow({
    super.key,
    required this.nouns,
    required this.cellSize,
    required this.gap,
    required this.axisFs,
    required this.activeIndex,
    required this.headerHeight,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < nouns.length; i++) ...[
          SizedBox(
            width: cellSize,
            height: headerHeight,
            child: BoardNounLabel(
              word: nouns[i].word,
              isActive: i == activeIndex,
              axisFs: axisFs,
              style: style,
            ),
          ),
          if (i < nouns.length - 1) SizedBox(width: gap),
        ],
      ],
    );
  }
}

class BoardNounLabel extends StatelessWidget {
  final String word;
  final bool isActive;
  final double axisFs;
  final BoardStyleConfig style;

  const BoardNounLabel({
    super.key,
    required this.word,
    required this.isActive,
    required this.axisFs,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final base = isActive ? style.axisLabelActive : style.axisLabel;
    final textStyle = base.copyWith(
      fontSize: axisFs,
      letterSpacing: (style.axisUppercase ? 0.08 : 0.025) * axisFs,
    );
    final display = style.axisUppercase ? word.toUpperCase() : word;

    return Center(
      child: RotatedBox(
        // quarterTurns: 3 → 90° CCW → text reads bottom-to-top (tilt head left)
        quarterTurns: 3,
        child: AnimatedDefaultTextStyle(
          style: textStyle,
          duration: const Duration(milliseconds: 100),
          child: Text(
            display,
            overflow: TextOverflow.visible,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}

// Row header column — adjectives laid out horizontally, right-aligned.
class BoardRowHeaderColumn extends StatelessWidget {
  final List<AdjectiveEntry> adjectives;
  final double cellSize;
  final double gap;
  final double axisFs;
  final int? activeIndex;
  final BoardStyleConfig style;

  const BoardRowHeaderColumn({
    super.key,
    required this.adjectives,
    required this.cellSize,
    required this.gap,
    required this.axisFs,
    required this.activeIndex,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < adjectives.length; i++) ...[
          SizedBox(
            height: cellSize,
            child: BoardAdjectiveLabel(
              word: adjectives[i].base,
              isActive: i == activeIndex,
              axisFs: axisFs,
              style: style,
            ),
          ),
          if (i < adjectives.length - 1) SizedBox(height: gap),
        ],
      ],
    );
  }
}

class BoardAdjectiveLabel extends StatelessWidget {
  final String word;
  final bool isActive;
  final double axisFs;
  final BoardStyleConfig style;

  const BoardAdjectiveLabel({
    super.key,
    required this.word,
    required this.isActive,
    required this.axisFs,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final base = isActive ? style.axisLabelActive : style.axisLabel;
    final textStyle = base.copyWith(
      fontSize: axisFs,
      letterSpacing: (style.axisUppercase ? 0.08 : 0.025) * axisFs,
    );
    final display = style.axisUppercase ? word.toUpperCase() : word;

    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: AnimatedDefaultTextStyle(
          style: textStyle,
          duration: const Duration(milliseconds: 100),
          child: Text(
            display,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}
