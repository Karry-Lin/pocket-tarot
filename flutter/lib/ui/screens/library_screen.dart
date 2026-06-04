part of '../../main.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  RouteInformationProvider? _routeInformationProvider;
  String? _lastPath;
  TarotCategory _category = TarotCategory.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          _routeInformationProvider = GoRouter.of(context).routeInformationProvider;
          _lastPath = _routeInformationProvider?.value.uri.path;
          _routeInformationProvider?.addListener(_onRouteChanged);
        } catch (_) {
          // 忽略無 GoRouter 的 context
        }
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _routeInformationProvider?.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (!mounted) return;
    final currentPath = _routeInformationProvider?.value.uri.path;
    if (currentPath == '/library' && _lastPath != '/library') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_searchFocusNode.hasFocus) {
          _searchFocusNode.unfocus();
        }
      });
    }
    _lastPath = currentPath;
  }

  Future<void> _handleRefresh() async {
    _searchController.clear();
    setState(() {
      _category = TarotCategory.all;
      _query = '';
    });
    await Future<void>.delayed(const Duration(milliseconds: 360));
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(tarotCardsProvider);
    final repository = ref.watch(tarotCatalogRepositoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final usesChineseVisual = _usesChineseCardText(l10n);
    final isLoading = cardsAsync.isLoading;

    return ScreenFrame(
      title: l10n.libraryTitle,
      eyebrow: 'Arcana library',
      trailing: null,
      scrollable: !isLoading,
      onRefresh: _handleRefresh,
      child: cardsAsync.when(
        loading: () => _AppLoadingIndicator(
          message: usesChineseVisual ? '正在翻閱奧秘卡庫...' : 'Consulting the arcana library...',
        ),
        error: (error, stackTrace) =>
            InfoPanel(title: l10n.libraryLoadFailed, child: Text('$error')),
        data: (cards) {
          final categoryOptions = TarotCategory.values;
          final categorized = repository.filterByCategory(cards, _category);
          final filtered = repository.search(categorized, _query);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (usesChineseVisual) ...[
                Text(l10n.searchCardsLabel),
                const SizedBox(height: 8),
              ],
              SearchBar(
                focusNode: _searchFocusNode,
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                hintText: usesChineseVisual ? '月亮、關係、修復' : l10n.searchCardsLabel,
                leading: const Icon(Icons.search, color: _ArcanaColors.muted),
                trailing: _query.isEmpty
                    ? null
                    : [
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(
                  _ArcanaColors.ink.withValues(alpha: 0.68),
                ),
                side: WidgetStateProperty.all(
                  BorderSide(
                    color: _ArcanaColors.muted.withValues(alpha: 0.24),
                  ),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                textStyle: WidgetStateProperty.all(
                  _bodyTextStyle(color: _ArcanaColors.ivory),
                ),
                hintStyle: WidgetStateProperty.all(
                  _bodyTextStyle(color: _ArcanaColors.subtle),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in categoryOptions)
                    ChoiceChip(
                      label: Text(_categoryLabel(category, l10n)),
                      selected: _category == category,
                      onSelected: (_) => setState(() => _category = category),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              TarotCategoryDescription(category: _category),
              SizedBox(height: usesChineseVisual ? 16 : 16),
              Text(
                l10n.cardsCount(filtered.length),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: usesChineseVisual ? 0.56 : 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final card = filtered[index];
                  return KnowledgeCard(
                    card: card,
                    imagePath: _imageForCard(card),
                    onTap: () => showModalBottomSheet<void>(
                      context: context,
                      showDragHandle: true,
                      isScrollControlled: true,
                      builder: (context) => CardDetailSheet(
                        card: card,
                        imagePath: _imageForCard(card),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class TarotCategoryDescription extends StatelessWidget {
  const TarotCategoryDescription({super.key, required this.category});

  final TarotCategory category;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Text(
      _categoryDescription(category, l10n),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}
