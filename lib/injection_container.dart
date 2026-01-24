import 'dart:developer' as developer;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'core/constants/app_constants.dart';
import 'injection_container.config.dart';
import 'features/locations/domain/usecases/get_my_locations_usecase.dart';
import 'features/locations/domain/usecases/update_location_usecase.dart';
import 'features/locations/presentation/bloc/locations_bloc.dart';

// Chat Feature imports
import 'features/chat/data/datasources/chat_remote_datasource.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/domain/repositories/chat_repository.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';

final getIt = GetIt.instance;
final sl = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  // Handle deep links for OAuth callback
  final appLinks = AppLinks();

  // Handle initial link (app opened from deep link)
  final initialUri = await appLinks.getInitialLink();
  if (initialUri != null) {
    developer.log('Initial deep link: $initialUri', name: 'OAuth');
    await _handleDeepLink(initialUri);
  }

  // Handle links when app is already running
  appLinks.uriLinkStream.listen((uri) {
    developer.log('Stream deep link: $uri', name: 'OAuth');
    _handleDeepLink(uri);
  });

  // Register external dependencies
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // Locations Feature - Manual registrations for Use Cases (registered before init)
  // Use Cases
  getIt.registerLazySingleton(() => GetMyLocationsUseCase(getIt()));
  getIt.registerLazySingleton(() => UpdateLocationUseCase(getIt()));

  // ====== Chat Feature ======
  // Data Sources
  getIt.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(getIt<SupabaseClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(getIt<ChatRemoteDataSource>()),
  );

  // Bloc - Factory to create new instance each time
  getIt.registerFactory<ChatBloc>(
    () => ChatBloc(chatRepository: getIt<ChatRepository>()),
  );

  // Initialize injectable (this will register annotated classes)
  getIt.init();

  // ====== Post-init registrations ======
  // LocationsBloc depends on LocationRepository which is registered via injectable
  getIt.registerFactory(() => LocationsBloc(
        getMyLocations: getIt<GetMyLocationsUseCase>(),
        repository: getIt(),
      ));
}

Future<void> _handleDeepLink(Uri uri) async {
  developer.log('=== OAuth Deep Link Handler ===', name: 'OAuth');
  developer.log('Full URI: $uri', name: 'OAuth');
  developer.log('Scheme: ${uri.scheme}', name: 'OAuth');
  developer.log('Host: ${uri.host}', name: 'OAuth');
  developer.log('Path: ${uri.path}', name: 'OAuth');
  developer.log('Fragment: ${uri.fragment}', name: 'OAuth');
  developer.log('Query params: ${uri.queryParameters}', name: 'OAuth');

  // Check if this is an OAuth callback (hausapp scheme)
  if (uri.scheme == 'hausapp') {
    try {
      // The OAuth response from Supabase comes in different formats:
      // 1. Fragment: hausapp://callback#access_token=...&refresh_token=...
      // 2. Query params: hausapp://callback?code=...

      if (uri.fragment.isNotEmpty) {
        // Handle fragment-based response (access_token in URL fragment)
        developer.log('Attempting to recover session from fragment...',
            name: 'OAuth');
        final response =
            await Supabase.instance.client.auth.getSessionFromUrl(uri);
        developer.log(
            'Session recovered! User: ${response.session?.user.email}',
            name: 'OAuth');
      } else if (uri.queryParameters.containsKey('code')) {
        // Handle PKCE code exchange
        developer.log('Attempting PKCE code exchange...', name: 'OAuth');
        final code = uri.queryParameters['code']!;
        final response =
            await Supabase.instance.client.auth.exchangeCodeForSession(code);
        developer.log(
            'PKCE session created! User: ${response.session?.user.email}',
            name: 'OAuth');
      } else {
        developer.log('No tokens found in URL, checking current session...',
            name: 'OAuth');
        // Fallback: try to get current session
        final session = Supabase.instance.client.auth.currentSession;
        if (session != null) {
          developer.log('Existing session found: ${session.user.email}',
              name: 'OAuth');
        } else {
          developer.log('No session available', name: 'OAuth');
        }
      }
    } catch (e, stackTrace) {
      developer.log('Error recovering session: $e', name: 'OAuth');
      developer.log('Stack trace: $stackTrace', name: 'OAuth');
    }
  }
}
