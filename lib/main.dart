import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/landing_page.dart';
import 'injection_container.dart';

import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/auth/presentation/pages/onboarding_page.dart';
import 'features/home/presentation/pages/main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cargar variables de entorno
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // Silently fail or handle error
  }

  // Configurar inyección de dependencias (incluye inicialización de Supabase)
  await configureDependencies();

  runApp(const HausApp());
}

class HausApp extends StatelessWidget {
  const HausApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              getIt<AuthBloc>()..add(const AuthCheckRequested()),
        ),
      ],
      child: MaterialApp(
        title: 'HAUS',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: BlocBuilder<AuthBloc, AuthState>(
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
