import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/matching_repository.dart';
import '../widgets/profile_card.dart';
import '../../../chat/presentation/pages/chat_page.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final CardSwiperController _controller = CardSwiperController();
  final MatchingRepository _repository = getIt<MatchingRepository>();

  List<MatchCandidate> _candidates = [];
  bool _isLoading = true;
  String? _error;
  int _dailyLikesCount = 0;
  bool _hasRemainingLikes = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final candidatesResult = await _repository.getCandidates(limit: 20);
      final likesResult = await _repository.getDailyLikesCount();

      candidatesResult.fold(
        (failure) => setState(() => _error = failure.message),
        (candidates) => setState(() => _candidates = candidates),
      );

      likesResult.fold(
        (failure) {},
        (count) => setState(() {
          _dailyLikesCount = count;
          _hasRemainingLikes = count < MatchingRepository.dailyLikeLimit;
        }),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) async {
    final candidate = _candidates[previousIndex];

    if (direction == CardSwiperDirection.right) {
      if (!_hasRemainingLikes) {
        _showLimitReachedDialog();
        return false;
      }
      _handleLike(candidate);
    } else if (direction == CardSwiperDirection.left) {
      _repository.recordInteraction(
        targetUserId: candidate.userId,
        action: InteractionType.skip,
      );
    } else if (direction == CardSwiperDirection.top) {
      if (!_hasRemainingLikes) {
        _showLimitReachedDialog();
        return false;
      }
      _handleLike(candidate);
    }

    return true;
  }

  Future<void> _handleLike(MatchCandidate candidate) async {
    setState(() {
      _dailyLikesCount++;
      _hasRemainingLikes = _dailyLikesCount < MatchingRepository.dailyLikeLimit;
    });

    final result = await _repository.recordInteraction(
      targetUserId: candidate.userId,
      action: InteractionType.like,
    );

    result.fold(
      (failure) {
        setState(() {
          _dailyLikesCount--;
          _hasRemainingLikes = true;
        });
      },
      (match) {
        if (match != null) {
          _showMatchDialog(candidate, match);
        }
      },
    );
  }

  void _showLimitReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.timer_outlined, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Límite diario',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Has alcanzado tus 10 likes diarios. Vuelve mañana para seguir descubriendo roomies.',
          style: GoogleFonts.inter(color: AppTheme.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Entendido',
                style: GoogleFonts.inter(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showMatchDialog(MatchCandidate candidate, Match match) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: AppTheme.primaryColor, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                '¡Es un Match!',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'A ${candidate.firstName} también le interesas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: AppTheme.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: candidate.avatarUrl != null
                        ? NetworkImage(candidate.avatarUrl!)
                        : null,
                    backgroundColor: AppTheme.surfaceDarkElevated,
                    child: candidate.avatarUrl == null
                        ? const Icon(Icons.person,
                            color: AppTheme.textSecondaryDark)
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (match.conversationId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            conversationId: match.conversationId!,
                            otherUserName: candidate.firstName,
                            listingTitle: 'Match de Roomie',
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.backgroundDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Enviar Mensaje',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Seguir buscando',
                  style: GoogleFonts.inter(color: AppTheme.textSecondaryDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.backgroundDark,
      elevation: 0,
      centerTitle: true,
      leadingWidth: 140,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Quito',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.textSecondaryDark, size: 18),
              ],
            ),
          ),
        ),
      ),
      title: const Text(
        'Ideal match',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: [
        _buildAppBarAction(Icons.bolt_rounded, AppTheme.warningColor),
        _buildAppBarAction(Icons.tune_rounded, Colors.white),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildAppBarAction(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: () {},
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              'Error al cargar perfiles',
              style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: GoogleFonts.inter(
                  color: AppTheme.textSecondaryDark, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.surfaceDark,
                foregroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_candidates.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderDark),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 48,
                color: AppTheme.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay más perfiles',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vuelve más tarde para ver nuevos candidatos',
              style: GoogleFonts.inter(color: AppTheme.textSecondaryDark),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadData();
              },
              child: const Text('Actualizar'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: CardSwiper(
            controller: _controller,
            cardsCount: _candidates.length,
            onSwipe: _onSwipe,
            numberOfCardsDisplayed:
                _candidates.length < 3 ? _candidates.length : 3,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            cardBuilder:
                (context, index, percentThresholdX, percentThresholdY) {
              return ProfileCard(candidate: _candidates[index]);
            },
          ),
        ),

        // Botones de acción (Cuadrados según diseño)
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton(
                icon: Icons.close_rounded,
                color: AppTheme.backgroundDark,
                backgroundColor: AppTheme.textPrimaryDark,
                onTap: () => _controller.swipe(CardSwiperDirection.left),
              ),
              const SizedBox(width: 20),
              _buildActionButton(
                icon: Icons.local_fire_department_rounded,
                color: Colors.white,
                backgroundColor: AppTheme.primaryColor,
                isLarge: true,
                onTap: () {
                  if (!_hasRemainingLikes) {
                    _showLimitReachedDialog();
                  } else {
                    _controller.swipe(CardSwiperDirection.right);
                  }
                },
              ),
              const SizedBox(width: 20),
              _buildActionButton(
                icon: Icons.star_rounded,
                color: AppTheme.secondaryColor,
                backgroundColor: AppTheme.textPrimaryDark,
                onTap: () => _controller.swipe(CardSwiperDirection.top),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Color? backgroundColor,
    bool isLarge = false,
  }) {
    final size = isLarge ? 72.0 : 56.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: backgroundColor == null
              ? Border.all(color: AppTheme.borderDark, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color:
                  (backgroundColor ?? AppTheme.primaryColor).withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: isLarge ? 32 : 28,
        ),
      ),
    );
  }
}
