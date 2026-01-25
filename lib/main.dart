import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';

import 'core/theme/app_theme.dart';
import 'core/services/global_message_listener.dart';
import 'core/services/navigation_service.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/landing_page.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/notifications/presentation/bloc/notification_event.dart';
import 'injection_container.dart';

import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/home/presentation/pages/main_page.dart';

// Imports para navegación
import 'features/chat/presentation/pages/chat_page.dart';
import 'features/listings/presentation/pages/listing_detail_page.dart';
import 'features/listings/domain/entities/listing_entity.dart'; // Necesario para ListingDetail

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Silently fail or handle error
  }

  // Configurar inyección de dependencias
  await configureDependencies();

  runApp(const HausApp());
}

class HausApp extends StatefulWidget {
  const HausApp({super.key});

  @override
  State<HausApp> createState() => _HausAppState();
}

class _HausAppState extends State<HausApp> {
  @override
  void initState() {
    super.initState();
    // Escuchar eventos de navegación global
    GetIt.I<NavigationService>().addNavigationListener(_handleNavigation);
  }

  @override
  void dispose() {
    GetIt.I<NavigationService>().removeNavigationListener(_handleNavigation);
    super.dispose();
  }

  void _handleNavigation() {
    final pending = GetIt.I<NavigationService>().consumePendingNavigation();
    if (pending == null) return;

    final context = GetIt.I<NavigationService>().context;
    if (context == null) return;

    if (pending.type == NavigationType.chat) {
      final conversationId = pending.data['conversationId'] as String;
      final listingTitle = pending.data['listingTitle'] as String?;
      final otherUserName = pending.data['otherUserName'] as String?;
      final listingId = pending.data['listingId'] as String?;
      final listingImageUrl = pending.data['listingImageUrl'] as String?;
      final listingPrice = pending.data['listingPrice'] as double?;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: conversationId,
            listingTitle: listingTitle ?? 'Chat',
            otherUserName: otherUserName,
            listingId: listingId,
            listingImageUrl: listingImageUrl,
            listingPrice: listingPrice,
          ),
        ),
      );
    } else if (pending.type == NavigationType.listing) {
      final listingId = pending.data['listingId'] as String;
      // Nota: Para ListingDetailPage necesitamos el objeto ListingEntity completo usualmente,
      // pero si solo tenemos el ID, podríamos necesitar una página que cargue el listing por ID
      // o modificar ListingDetailPage para aceptar ID.
      // Por ahora, asumiremos que ListingDetailPage requiere un entity, y navegaremos a un wrapper o placeholder.
      // TODO: Refactorizar ListingDetailPage para cargar por ID.
      // Por simplicidad, voy a navegar usando Main Page al tab de home por ahora, o implementar carga por ID.

      // SOLUCIÓN TEMPORAL: Navegar a Main Page.
      // Lo ideal es tener un 'ListingDetailsByIdPage' o similar.
      debugPrint(
          'Navigation to listing $listingId requested. Implementation pending (requires fetch by ID).');
    } else if (pending.type == NavigationType.connections) {
      // Navegar a MainPage y seleccionar tab de conexiones (index 3)
      // Si ya estamos en MainPage, podríamos usar un StreamController o similar para cambiar el tab
      // Por ahora, hacemos push a MainPage que es lo más seguro
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<AuthBloc>(),
            child: MainPage(
              user: (context.read<AuthBloc>().state as AuthAuthenticated).user,
              initialIndex: 3, // Necesitamos agregar este parámetro a MainPage
            ),
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
        BlocProvider<NotificationBloc>(
          create: (context) => GetIt.I<NotificationBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'HAUS',
        navigatorKey: GetIt.I<NavigationService>().navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: BlocConsumer<AuthBloc, AuthState>(
          // ... resto del código igual
          listener: (context, state) {
            // Iniciar/detener servicios según el estado de auth
            if (state is AuthAuthenticated) {
              GlobalMessageListener().startListening();
              // Iniciar suscripción a notificaciones
              context
                  .read<NotificationBloc>()
                  .add(const SubscribeToNotifications());
            } else if (state is AuthUnauthenticated) {
              GlobalMessageListener().stopListening();
              context
                  .read<NotificationBloc>()
                  .add(const UnsubscribeFromNotifications());
            }
          },
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return MainPage(user: state.user);
            } else if (state is OnboardingRequired) {
              return OnboardingPage(user: state.user);
            } else if (state is AuthUnauthenticated || state is AuthError) {
              return const LandingPage();
            }
            // Mientras carga o estado inicial, mostrar splash o landing
            return const LandingPage();
          },
        ),
      ),
    );
  }
}
