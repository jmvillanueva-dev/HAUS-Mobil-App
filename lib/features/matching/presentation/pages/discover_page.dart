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

  // --- LÓGICA DE DATOS ---
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

  Future<bool> _onSwipe(int previousIndex, int? currentIndex,
      CardSwiperDirection direction) async {
    final candidate = _candidates[previousIndex];
    if (direction == CardSwiperDirection.right ||
        direction == CardSwiperDirection.top) {
      if (!_hasRemainingLikes) {
        _showLimitReachedDialog();
        return false;
      }
      _handleLike(candidate);
    } else if (direction == CardSwiperDirection.left) {
      _repository.recordInteraction(
          targetUserId: candidate.userId, action: InteractionType.skip);
    }
    return true;
  }

  Future<void> _handleLike(MatchCandidate candidate) async {
    setState(() {
      _dailyLikesCount++;
      _hasRemainingLikes = _dailyLikesCount < MatchingRepository.dailyLikeLimit;
    });
    final result = await _repository.recordInteraction(
        targetUserId: candidate.userId, action: InteractionType.like);
    result.fold(
      (failure) => setState(() {
        _dailyLikesCount--;
        _hasRemainingLikes = true;
      }),
      (match) {
        if (match != null) {
          _showMatchDialog(candidate, match);
        }
      },
    );
  }

  // --- UI: DIÁLOGOS ---

  void _showLimitReachedDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => const SizedBox(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: AppTheme.surfaceDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded,
                      color: AppTheme.warningColor, size: 64),
                  const SizedBox(height: 16),
                  Text('¡Vuelve pronto!',
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 12),
                  Text(
                      'Has alcanzado el límite de hoy. Mañana tendrás 10 nuevas oportunidades.',
                      textAlign: TextAlign.center,
                      style:
                          GoogleFonts.inter(color: AppTheme.textSecondaryDark)),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Entendido',
                      style: GoogleFonts.inter(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMatchDialog(MatchCandidate candidate, Match match) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, _, __) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                builder: (context, double val, child) => Transform.scale(
                  scale: val,
                  child: child,
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: AppTheme.primaryColor, size: 80),
              ),
              const SizedBox(height: 20),
              Text('¡ES UN MATCH!',
                  style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 2)),
              const SizedBox(height: 10),
              Text(
                  'A ${candidate.firstName} también le gustaría ser tu roomie.',
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.inter(fontSize: 16, color: Colors.white70)),
              const SizedBox(height: 40),
              SizedBox(
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 60,
                      child: _buildMatchAvatar(candidate.avatarUrl,
                          border: AppTheme.primaryColor),
                    ),
                    const CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 25,
                        child:
                            Icon(Icons.flash_on, color: AppTheme.primaryColor)),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              _buildLargeButton(
                  label: 'ENVIAR MENSAJE',
                  color: AppTheme.primaryColor,
                  onTap: () {
                    Navigator.pop(context);
                    if (match.conversationId != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatPage(
                                    conversationId: match.conversationId!,
                                    otherUserName: candidate.firstName,
                                    listingTitle: 'Match de Roomie',
                                  )));
                    }
                  }),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('SEGUIR BUSCANDO',
                    style: GoogleFonts.inter(
                        color: Colors.white54, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchAvatar(String? url, {required Color border}) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle, border: Border.all(color: border, width: 4)),
      child: CircleAvatar(
        radius: 45,
        backgroundImage: url != null ? NetworkImage(url) : null,
        child: url == null ? const Icon(Icons.person, size: 40) : null,
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
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Center(
        child: _buildAppBarAction(
          Icons.arrow_back_ios_new_rounded,
          Colors.white,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: Text('Discover',
          style: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
      actions: [
        _buildAppBarAction(Icons.tune_rounded, Colors.white),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildAppBarAction(IconData icon, Color color,
      {VoidCallback? onPressed}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 18),
        onPressed: onPressed ?? () {},
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }
    if (_error != null) {
      return _buildErrorState();
    }
    if (_candidates.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              CardSwiper(
                controller: _controller,
                cardsCount: _candidates.length,
                onSwipe: _onSwipe,
                numberOfCardsDisplayed:
                    _candidates.length < 3 ? _candidates.length : 3,
                backCardOffset: const Offset(0, 30),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                cardBuilder: (context, index, x, y) {
                  return Stack(
                    children: [
                      ProfileCard(candidate: _candidates[index]),
                      if (x > 50)
                        _buildSwipeLabel(
                            "LIKE", Colors.green, Alignment.topLeft),
                      if (x < -50)
                        _buildSwipeLabel(
                            "NOPE", Colors.red, Alignment.topRight),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
        _buildActionButtons(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildSwipeLabel(String text, Color color, Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text,
            style: TextStyle(
                color: color, fontSize: 32, fontWeight: FontWeight.w900)),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildActionButton(
          icon: Icons.close,
          color: Colors.black,
          backgroundColor: Colors.white,
          onTap: () => _controller.swipe(CardSwiperDirection.left),
          iconSize: 36,
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.local_fire_department_rounded,
          color: Colors.white,
          backgroundColor: AppTheme.primaryColor,
          isLarge: true,
          onTap: () => _hasRemainingLikes
              ? _controller.swipe(CardSwiperDirection.right)
              : _showLimitReachedDialog(),
        ),
        const SizedBox(width: 16),
        _buildActionButton(
          icon: Icons.star_rounded,
          color: Colors.black,
          backgroundColor: Colors.white,
          onTap: () => _controller.swipe(CardSwiperDirection.top),
          iconSize: 36,
        ),
      ],
    );
  }

  Widget _buildActionButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap,
      Color? backgroundColor,
      bool isLarge = false,
      double? iconSize}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isLarge ? 84 : 64,
        height: isLarge ? 84 : 64,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: backgroundColor == Colors.white
                ? Colors.black.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Icon(icon, color: color, size: iconSize ?? (isLarge ? 44 : 32)),
      ),
    );
  }

  Widget _buildLargeButton(
      {required String label,
      required Color color,
      required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
        ),
        child: Text(label,
            style:
                GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sentiment_dissatisfied_rounded,
              size: 100, color: AppTheme.borderDark),
          const SizedBox(height: 20),
          Text('No hay más roomies por ahora',
              style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('Intenta cambiar tus filtros o vuelve luego.',
              style: TextStyle(color: AppTheme.textSecondaryDark)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text('Algo salió mal',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          TextButton(onPressed: _loadData, child: const Text('REINTENTAR')),
        ],
      ),
    );
  }
}
