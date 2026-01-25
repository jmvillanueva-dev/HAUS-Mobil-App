import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/match_entity.dart';

/// DataSource para operaciones de matching en Supabase
@lazySingleton
class MatchingDataSource {
  final SupabaseClient _client;

  MatchingDataSource(this._client);

  String? get _currentUserId => _client.auth.currentUser?.id;

  /// Obtiene candidatos de matching para el usuario actual
  /// Usa la función RPC de Supabase para cálculo de score
  Future<List<MatchCandidate>> getCandidates({int limit = 20}) async {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'get_match_candidates',
      params: {
        'for_user_id': _currentUserId,
        'limit_count': limit,
      },
    );

    return (response as List)
        .map((json) => MatchCandidate.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Registra una interacción (like/skip) con un usuario
  Future<void> recordInteraction({
    required String targetUserId,
    required InteractionType action,
  }) async {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }

    try {
      await _client.from('user_interactions').insert({
        'user_id': _currentUserId,
        'target_user_id': targetUserId,
        'action': action.toDbString(),
      });
    } on PostgrestException catch (e) {
      // Si ya existe la interacción (código 23505), la ignoramos
      // Esto puede pasar si el cliente tiene datos desactualizados
      if (e.code == '23505') {
        return;
      }
      rethrow;
    }
  }

  /// Obtiene los matches del usuario actual
  Future<List<Match>> getMatches() async {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }

    // Obtener matches donde el usuario es user_a o user_b
    final response = await _client
        .from('matches')
        .select()
        .or('user_a.eq.$_currentUserId,user_b.eq.$_currentUserId')
        .eq('is_active', true)
        .order('matched_at', ascending: false);

    final matches = <Match>[];

    for (final item in response as List) {
      final json = item as Map<String, dynamic>;
      final match = Match.fromJson(json);
      final otherUserId = match.getOtherUserId(_currentUserId!);

      // Obtener datos del otro usuario
      final otherUserData =
          await _getOtherUserData(otherUserId, match.compatibilityScore);

      matches.add(Match.fromJson(json, otherUser: otherUserData));
    }

    return matches;
  }

  /// Obtiene datos básicos de un usuario para mostrar en match
  Future<MatchCandidate?> _getOtherUserData(String userId, double score) async {
    final response = await _client
        .from('profiles')
        .select('id, first_name, last_name, avatar_url, bio')
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return MatchCandidate(
      userId: response['id'] as String,
      firstName: response['first_name'] as String? ?? '',
      lastName: response['last_name'] as String? ?? '',
      avatarUrl: response['avatar_url'] as String?,
      bio: response['bio'] as String?,
      compatibilityScore: score,
    );
  }

  /// Cuenta los likes realizados hoy (para límite diario)
  Future<int> getDailyLikesCount() async {
    if (_currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }

    final response = await _client.rpc(
      'get_daily_likes_count',
      params: {'for_user_id': _currentUserId},
    );

    return response as int? ?? 0;
  }

  /// Verifica si ya existe una interacción con un usuario
  Future<bool> hasInteractionWith(String targetUserId) async {
    if (_currentUserId == null) return false;

    final response = await _client
        .from('user_interactions')
        .select('id')
        .eq('user_id', _currentUserId!)
        .eq('target_user_id', targetUserId)
        .maybeSingle();

    return response != null;
  }

  /// Verifica si hubo match después de dar like
  /// Retorna el Match si existe, null si no
  Future<Match?> checkForMatch(String targetUserId) async {
    if (_currentUserId == null) return null;

    // Ordenar IDs para buscar en matches
    final userA = _currentUserId!.compareTo(targetUserId) < 0
        ? _currentUserId!
        : targetUserId;
    final userB = _currentUserId!.compareTo(targetUserId) < 0
        ? targetUserId
        : _currentUserId!;

    final response = await _client
        .from('matches')
        .select()
        .eq('user_a', userA)
        .eq('user_b', userB)
        .maybeSingle();

    if (response == null) return null;

    final match = Match.fromJson(response);
    final otherUserData =
        await _getOtherUserData(targetUserId, match.compatibilityScore);

    return Match.fromJson(response, otherUser: otherUserData);
  }

  /// Escucha nuevos matches en tiempo real
  Stream<Match> watchNewMatches() {
    if (_currentUserId == null) {
      return const Stream.empty();
    }

    return _client
        .from('matches')
        .stream(primaryKey: ['id'])
        .map((events) {
          if (events.isEmpty) return null;

          // Filtrar y obtener el último match relevante
          final myMatches = events.where((e) {
            final data = e as Map<String, dynamic>;
            return data['user_a'] == _currentUserId ||
                data['user_b'] == _currentUserId;
          }).toList();

          if (myMatches.isEmpty) return null;

          // Ordenar por fecha para obtener el más reciente
          myMatches.sort((a, b) {
            final dateA = DateTime.parse(a['matched_at'] as String);
            final dateB = DateTime.parse(b['matched_at'] as String);
            return dateA.compareTo(dateB);
          });

          return Match.fromJson(myMatches.last as Map<String, dynamic>);
        })
        .where((match) => match != null)
        .cast<Match>();
  }
}
