part of '../../main.dart';

class TarotImageCard extends StatelessWidget {
  const TarotImageCard({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.radius = 18,
    this.fit = BoxFit.cover,
  });

  final String imagePath;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _ArcanaColors.gold2.withValues(alpha: 0.38)),
        color: _ArcanaColors.ink2,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.34),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Image.asset(imagePath, fit: fit),
    );
  }
}

class CardPreview extends StatelessWidget {
  const CardPreview({super.key, required this.imagePath, required this.title});

  final String imagePath;
  final String title;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      child: Padding(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            TarotImageCard(imagePath: imagePath, height: 260),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class KnowledgeCard extends StatelessWidget {
  const KnowledgeCard({
    super.key,
    required this.card,
    required this.imagePath,
    required this.onTap,
  });

  final TarotCard card;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final usesChineseVisual = _usesChineseCardText(l10n);

    return GlassPanel(
      padding: const EdgeInsets.all(10),
      radius: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TarotImageCard(
                  imagePath: imagePath,
                  width: double.infinity,
                  radius: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _primaryCardName(card, l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(width: 6),
                  TagPill(text: _cardTagLabel(card, l10n)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                usesChineseVisual
                    ? _referenceCardSummary(card)
                    : _uprightCardMeaning(card, l10n),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: usesChineseVisual
                    ? Theme.of(context).textTheme.bodyMedium
                    : Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SummaryStrip extends StatelessWidget {
  const SummaryStrip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _ArcanaColors.peacock.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _ArcanaColors.gold.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Text(
          text,
          style: _bodyTextStyle(
            fontWeight: FontWeight.w800,
            color: _ArcanaColors.ivory,
          ),
        ),
      ),
    );
  }
}

class PromptChip extends StatelessWidget {
  const PromptChip({super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(text),
      onPressed: onPressed,
      side: BorderSide(color: _ArcanaColors.muted.withValues(alpha: 0.22)),
      backgroundColor: Colors.white.withValues(alpha: 0.035),
      labelStyle: _bodyTextStyle(fontSize: 12, color: _ArcanaColors.muted),
    );
  }
}

class SelectableCardBack extends StatelessWidget {
  const SelectableCardBack({
    super.key,
    required this.selected,
    required this.order,
    required this.onTap,
  });

  final bool selected;
  final int order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/card-back.png',
              fit: BoxFit.cover,
            ),
          ),
          if (selected)
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _ArcanaColors.gold2, width: 3),
                color: Colors.black.withValues(alpha: 0.18),
              ),
              child: Center(
                child: CircleAvatar(
                  backgroundColor: _ArcanaColors.gold2,
                  child: Text(
                    '$order',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class DeepResultPanel extends ConsumerWidget {
  const DeepResultPanel({
    super.key,
    required this.reading,
    required this.isSavedForHistory,
    required this.onHistoryVisibilityChanged,
  });

  final DeepReading reading;
  final bool isSavedForHistory;
  final ValueChanged<bool> onHistoryVisibilityChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cards = ref.watch(tarotCardsProvider).asData?.value ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InfoPanel(
          title: l10n.deepResultTitle,
          child: SafeMarkdownBody(data: reading.markdownResult),
        ),
        const SizedBox(height: 10),
        SummaryStrip(text: reading.summary),
        const SizedBox(height: 10),
        SwitchListTile(
          value: isSavedForHistory,
          onChanged: onHistoryVisibilityChanged,
          title: Text(l10n.saveToHistory),
          secondary: const Icon(Icons.bookmark_add),
        ),
        const SizedBox(height: 10),
        InfoPanel(
          title: l10n.selectedCardsTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final card in reading.selectedCards)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_selectedCardLine(card, cards, l10n)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class CardDetailSheet extends StatelessWidget {
  const CardDetailSheet({
    super.key,
    required this.card,
    required this.imagePath,
  });

  final TarotCard card;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: TarotImageCard(imagePath: imagePath, height: 190)),
            const SizedBox(height: 16),
            const EyebrowText('Card meaning'),
            const SizedBox(height: 8),
            Text(
              _primaryCardName(card, l10n),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (_usesChineseCardText(l10n))
              Text(
                _secondaryCardName(card, l10n),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 8),
            GlassPanel(
              padding: const EdgeInsets.all(14),
              radius: 18,
              child: Text(
                l10n.cardMeaningText(
                  _uprightCardMeaning(card, l10n),
                  _reversedCardMeaning(card, l10n),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _imageForCard(TarotCard card) {
  return _imageForCardId(card.id);
}

String _imageForCardId(String cardId) {
  return 'assets/images/cards/$cardId.jpg';
}

String _dailyCardDisplayName(
  CardDraw draw,
  AppLocalizations l10n,
  TarotCard? card,
) {
  final cardName = card == null
      ? _cardNameFallback(draw.cardId, l10n)
      : _primaryCardName(card, l10n);
  final orientation = _orientationLabel(draw.orientation, l10n);
  if (_usesChineseCardText(l10n)) {
    return '$cardName$orientation';
  }

  return '$cardName ($orientation)';
}

TarotCard? _findCardById(List<TarotCard> cards, String cardId) {
  for (final card in cards) {
    if (card.id == cardId) {
      return card;
    }
  }
  return null;
}

String _selectedCardLine(
  SelectedReadingCard selectedCard,
  List<TarotCard> cards,
  AppLocalizations l10n,
) {
  final card = _findCardById(cards, selectedCard.cardId);
  final cardName = card == null
      ? _cardNameFallback(selectedCard.cardId, l10n)
      : _primaryCardName(card, l10n);
  final positionLabel = _selectedPositionLabel(selectedCard, l10n);
  return '$positionLabel · $cardName · ${_orientationLabel(selectedCard.orientation, l10n)}';
}

String _selectedPositionLabel(
  SelectedReadingCard selectedCard,
  AppLocalizations l10n,
) {
  if (_usesChineseCardText(l10n)) {
    return selectedCard.positionLabel;
  }

  return switch (selectedCard.position) {
    'core' => 'Core question',
    'hiddenInfluence' => 'Hidden influence',
    'advice' => 'Action advice',
    _ => selectedCard.positionLabel,
  };
}

String _cardNameFallback(String cardId, AppLocalizations l10n) {
  final usesChinese = _usesChineseCardText(l10n);
  final parts = cardId.split('-');
  if (parts.length < 3) {
    return usesChinese ? '未知牌面' : 'Unknown card';
  }

  if (parts.first == 'major') {
    final majorIndex = int.tryParse(parts[1]);
    if (majorIndex != null &&
        majorIndex >= 0 &&
        majorIndex < _majorFallbackNames.length) {
      final names = _majorFallbackNames[majorIndex];
      return usesChinese ? names.$1 : names.$2;
    }
  }

  final suit = _minorSuitFallbackNames[parts.first];
  final rank = _minorRankFallbackNames[parts[1]];
  if (suit == null || rank == null) {
    return usesChinese ? '未知牌面' : 'Unknown card';
  }

  if (usesChinese) {
    return '${suit.$1}${rank.$1}';
  }
  return '${rank.$2} of ${suit.$2}';
}

const _majorFallbackNames = <(String, String)>[
  ('愚者', 'The Fool'),
  ('魔術師', 'The Magician'),
  ('女祭司', 'The High Priestess'),
  ('皇后', 'The Empress'),
  ('皇帝', 'The Emperor'),
  ('教皇', 'The Hierophant'),
  ('戀人', 'The Lovers'),
  ('戰車', 'The Chariot'),
  ('力量', 'Strength'),
  ('隱者', 'The Hermit'),
  ('命運之輪', 'Wheel of Fortune'),
  ('正義', 'Justice'),
  ('吊人', 'The Hanged Man'),
  ('死神', 'Death'),
  ('節制', 'Temperance'),
  ('惡魔', 'The Devil'),
  ('高塔', 'The Tower'),
  ('星星', 'The Star'),
  ('月亮', 'The Moon'),
  ('太陽', 'The Sun'),
  ('審判', 'Judgement'),
  ('世界', 'The World'),
];

const _minorSuitFallbackNames = <String, (String, String)>{
  'wands': ('權杖', 'Wands'),
  'cups': ('聖杯', 'Cups'),
  'swords': ('寶劍', 'Swords'),
  'pentacles': ('錢幣', 'Pentacles'),
};

const _minorRankFallbackNames = <String, (String, String)>{
  '01': ('一', 'Ace'),
  '02': ('二', 'Two'),
  '03': ('三', 'Three'),
  '04': ('四', 'Four'),
  '05': ('五', 'Five'),
  '06': ('六', 'Six'),
  '07': ('七', 'Seven'),
  '08': ('八', 'Eight'),
  '09': ('九', 'Nine'),
  '10': ('十', 'Ten'),
  '11': ('侍者', 'Page'),
  '12': ('騎士', 'Knight'),
  '13': ('皇后', 'Queen'),
  '14': ('國王', 'King'),
};

String _primaryCardName(TarotCard card, AppLocalizations l10n) {
  return _usesChineseCardText(l10n) ? card.zhName : card.enName;
}

String _secondaryCardName(TarotCard card, AppLocalizations l10n) {
  return _usesChineseCardText(l10n) ? card.enName : card.zhName;
}

String _uprightCardMeaning(TarotCard card, AppLocalizations l10n) {
  return _usesChineseCardText(l10n)
      ? card.uprightMeaning
      : card.enUprightMeaning;
}

String _reversedCardMeaning(TarotCard card, AppLocalizations l10n) {
  return _usesChineseCardText(l10n)
      ? card.reversedMeaning
      : card.enReversedMeaning;
}

bool _usesChineseCardText(AppLocalizations l10n) {
  return l10n.localeName.toLowerCase().startsWith('zh');
}

String _categoryLabel(TarotCategory category, AppLocalizations l10n) {
  return switch (category) {
    TarotCategory.all => l10n.categoryAll,
    TarotCategory.major => l10n.categoryMajor,
    TarotCategory.wands => l10n.categoryWands,
    TarotCategory.cups => l10n.categoryCups,
    TarotCategory.swords => l10n.categorySwords,
    TarotCategory.pentacles => l10n.categoryPentacles,
  };
}

String _categoryDescription(TarotCategory category, AppLocalizations l10n) {
  final usesChinese = _usesChineseCardText(l10n);
  if (usesChinese) {
    return switch (category) {
      TarotCategory.all =>
        '塔羅牌用 22 張大阿爾克那與 56 張小阿爾克那分類，小阿爾克那再分成權杖、聖杯、寶劍、錢幣，方便從人生主題、行動、情感、思考與現實資源理解牌義。',
      TarotCategory.major => '大阿爾克那代表人生主題與關鍵轉折，像是開始、選擇、失衡、轉化與完成。',
      TarotCategory.wands => '權杖屬於小阿爾克那，常看行動力、熱情、創造與事業推進。',
      TarotCategory.cups => '聖杯屬於小阿爾克那，常看情感、關係、直覺與內在感受。',
      TarotCategory.swords => '寶劍屬於小阿爾克那，常看思考、溝通、衝突、判斷與壓力。',
      TarotCategory.pentacles => '錢幣屬於小阿爾克那，常看工作、金錢、身體、資源與現實穩定。',
    };
  }

  return switch (category) {
    TarotCategory.all =>
      'Major Arcana are the deck-wide life themes; Minor Arcana are split into Wands, Cups, Swords, and Pentacles to read action, emotion, thought, and practical resources.',
    TarotCategory.major =>
      'Major Arcana show larger life themes and turning points: beginnings, choices, imbalance, transformation, and completion.',
    TarotCategory.wands =>
      'Wands are Minor Arcana cards for action, drive, creative energy, and momentum.',
    TarotCategory.cups =>
      'Cups are Minor Arcana cards for emotion, relationships, intuition, and inner response.',
    TarotCategory.swords =>
      'Swords are Minor Arcana cards for thought, communication, conflict, judgment, and pressure.',
    TarotCategory.pentacles =>
      'Pentacles are Minor Arcana cards for work, money, body, resources, and practical stability.',
  };
}

String _categoryShortLabel(TarotCategory category, AppLocalizations l10n) {
  final usesChinese = _usesChineseCardText(l10n);
  return switch (category) {
    TarotCategory.all => l10n.categoryAll,
    TarotCategory.major => usesChinese ? '大牌' : 'Major',
    TarotCategory.wands => usesChinese ? '權杖' : 'Wands',
    TarotCategory.cups => usesChinese ? '聖杯' : 'Cups',
    TarotCategory.swords => usesChinese ? '寶劍' : 'Swords',
    TarotCategory.pentacles => usesChinese ? '錢幣' : 'Pent.',
  };
}

String _cardTagLabel(TarotCard card, AppLocalizations l10n) {
  if (_usesChineseCardText(l10n)) {
    return switch (card.id) {
      'major-18-moon' => 'XVIII',
      'major-17-star' => 'XVII',
      'major-14-temperance' => 'XIV',
      'major-16-tower' => 'XVI',
      _ => _categoryShortLabel(card.category, l10n),
    };
  }

  return _categoryShortLabel(card.category, l10n);
}

String _referenceCardSummary(TarotCard card) {
  return switch (card.id) {
    'major-18-moon' => '直覺、恐懼、尚未照亮的真相。',
    'major-17-star' => '修復、遠方的信念、再次相信。',
    'major-14-temperance' => '調和、比例、慢慢把兩端放回一起。',
    'cups-02-two' => '互相看見、關係承諾、平等交換。',
    'swords-06-six' => '離開舊水域、過渡、帶著經驗前往下一站。',
    'major-16-tower' => '突變、真相、舊結構被迫鬆動。',
    _ => card.uprightMeaning,
  };
}

final _visualPreviewHistory = [
  DeepReadingHistoryItem(
    id: 'preview-1',
    question: '關係中的沉默',
    summary: '月亮、節制、星星，已保存完整解讀',
    resultLocale: 'zh-TW',
    createdAt: DateTime.utc(2026, 5, 21),
  ),
  DeepReadingHistoryItem(
    id: 'preview-2',
    question: '新的職務邀請',
    summary: '權杖二、正義、隱者，風險與下一步',
    resultLocale: 'zh-TW',
    createdAt: DateTime.utc(2026, 5, 20),
  ),
  DeepReadingHistoryItem(
    id: 'preview-3',
    question: '低潮的出口',
    summary: '高塔、聖杯四、太陽，自我照顧提醒',
    resultLocale: 'zh-TW',
    createdAt: DateTime.utc(2026, 4, 28),
  ),
];

String _orientationLabel(String orientation, AppLocalizations l10n) {
  return switch (orientation) {
    'upright' => l10n.upright,
    'reversed' => l10n.reversed,
    _ => orientation,
  };
}

Future<void> _showNameDialog(
  BuildContext context,
  Future<void> Function(String displayName) onSave, {
  String initialName = '',
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) =>
        _VisualNameEditSheet(initialName: initialName, onSave: onSave),
  );
}
