import 'dart:async';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

/// DataSource remoto para Chat usando Supabase
/// Maneja operaciones CRUD y suscripciones Realtime
abstract class ChatRemoteDataSource {
  /// Obtiene las conversaciones del usuario actual con datos enriquecidos
  Future<List<ConversationModel>> getConversations();

  /// Obtiene una conversación específica
  Future<ConversationModel?> getConversation(String conversationId);

  /// Obtiene los mensajes de una conversación
  Future<List<MessageModel>> getMessages(String conversationId);

  /// Stream de mensajes en tiempo real usando Supabase Realtime
  Stream<List<MessageModel>> watchMessages(String conversationId);

  /// Envía un nuevo mensaje
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  });

  /// Obtiene una conversación existente o crea una nueva
  Future<ConversationModel> getOrCreateConversation({
    required String listingId,
    required String hostId,
  });

  /// Marca mensajes de una conversación como leídos
  Future<void> markMessagesAsRead(String conversationId);

  /// Obtiene el ID del usuario actual
  String? get currentUserId;
}

/// Implementación de ChatRemoteDataSource usando Supabase
class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SupabaseClient _supabase;

  ChatRemoteDataSourceImpl(this._supabase);

  @override
  String? get currentUserId => _supabase.auth.currentUser?.id;

  @override
  Future<List<ConversationModel>> getConversations() async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    developer.log('Fetching conversations for user: $userId', name: 'Chat');

    // Query con JOINs para obtener datos enriquecidos
    // Nota: Supabase no permite JOINs directos, usamos select anidado
    final response = await _supabase
        .from('conversations')
        .select('''
          *,
          listings!inner(id, title, image_urls),
          user_profile:profiles!conversations_user_id_fkey(first_name, last_name, avatar_url),
          host_profile:profiles!conversations_host_id_fkey(first_name, last_name, avatar_url)
        ''')
        .or('user_id.eq.$userId,host_id.eq.$userId')
        .order('last_message_at', ascending: false);

    developer.log('Got ${response.length} conversations', name: 'Chat');

    return (response as List<dynamic>)
        .map((json) => ConversationModel.fromJson(
              json as Map<String, dynamic>,
              currentUserId: userId,
            ))
        .toList();
  }

  @override
  Future<ConversationModel?> getConversation(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    final response = await _supabase.from('conversations').select('''
          *,
          listings!inner(id, title, image_urls),
          user_profile:profiles!conversations_user_id_fkey(first_name, last_name, avatar_url),
          host_profile:profiles!conversations_host_id_fkey(first_name, last_name, avatar_url)
        ''').eq('id', conversationId).maybeSingle();

    if (response == null) return null;

    return ConversationModel.fromJson(
      response as Map<String, dynamic>,
      currentUserId: userId,
    );
  }

  @override
  Future<List<MessageModel>> getMessages(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    developer.log('Fetching messages for conversation: $conversationId',
        name: 'Chat');

    final response = await _supabase
        .from('messages')
        .select('''
          *,
          sender_profile:profiles!messages_sender_id_fkey(first_name, last_name, avatar_url)
        ''')
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    developer.log('Got ${response.length} messages', name: 'Chat');

    return (response as List<dynamic>)
        .map((json) => MessageModel.fromJson(
              json as Map<String, dynamic>,
              currentUserId: userId,
            ))
        .toList();
  }

  @override
  Stream<List<MessageModel>> watchMessages(String conversationId) {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.error(Exception('Usuario no autenticado'));
    }

    developer.log(
        'Starting realtime subscription for conversation: $conversationId',
        name: 'Chat');

    // Usamos stream() de Supabase para Realtime
    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((data) {
          developer.log('Realtime update: ${data.length} messages',
              name: 'Chat');
          return data
              .map((json) => MessageModel.fromJson(
                    json,
                    currentUserId: userId,
                  ))
              .toList();
        });
  }

  @override
  Future<MessageModel> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    developer.log('Sending message to conversation: $conversationId',
        name: 'Chat');

    final messageData = {
      'conversation_id': conversationId,
      'sender_id': userId,
      'content': content,
    };

    final response =
        await _supabase.from('messages').insert(messageData).select().single();

    developer.log('Message sent: ${response['id']}', name: 'Chat');

    return MessageModel.fromJson(
      response as Map<String, dynamic>,
      currentUserId: userId,
    );
  }

  @override
  Future<ConversationModel> getOrCreateConversation({
    required String listingId,
    required String hostId,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    developer.log('Getting or creating conversation for listing: $listingId',
        name: 'Chat');

    // Primero intentar obtener conversación existente
    final existingResponse = await _supabase.from('conversations').select('''
          *,
          listings!inner(id, title, image_urls),
          user_profile:profiles!conversations_user_id_fkey(first_name, last_name, avatar_url),
          host_profile:profiles!conversations_host_id_fkey(first_name, last_name, avatar_url)
        ''').eq('listing_id', listingId).eq('user_id', userId).maybeSingle();

    if (existingResponse != null) {
      developer.log('Found existing conversation: ${existingResponse['id']}',
          name: 'Chat');
      return ConversationModel.fromJson(
        existingResponse as Map<String, dynamic>,
        currentUserId: userId,
      );
    }

    // Crear nueva conversación
    developer.log('Creating new conversation', name: 'Chat');

    final newConversation = {
      'listing_id': listingId,
      'user_id': userId,
      'host_id': hostId,
    };

    final insertResponse =
        await _supabase.from('conversations').insert(newConversation).select('''
          *,
          listings!inner(id, title, image_urls),
          user_profile:profiles!conversations_user_id_fkey(first_name, last_name, avatar_url),
          host_profile:profiles!conversations_host_id_fkey(first_name, last_name, avatar_url)
        ''').single();

    developer.log('Created conversation: ${insertResponse['id']}',
        name: 'Chat');

    return ConversationModel.fromJson(
      insertResponse as Map<String, dynamic>,
      currentUserId: userId,
    );
  }

  @override
  Future<void> markMessagesAsRead(String conversationId) async {
    final userId = currentUserId;
    if (userId == null) throw Exception('Usuario no autenticado');

    developer.log('Marking messages as read for conversation: $conversationId',
        name: 'Chat');

    // Marcar como leídos todos los mensajes que NO fueron enviados por mí
    await _supabase
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', userId)
        .eq('is_read', false);
  }
}
