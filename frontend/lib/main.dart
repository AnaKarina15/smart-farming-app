import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_colors.dart';
import 'data/providers/auth_provider.dart';
import 'data/services/auth_service.dart';
import 'data/services/lotes_service.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/widgets/offline_banner.dart';

void main() {
  // Inicializacion de dependencias (poor man's DI)
  final tokenStorage = TokenStorage();
  final dioClient = DioClient(tokenStorage);
  final authService = AuthService(dioClient, tokenStorage);
  final lotesService = LotesService(dioClient);

  runApp(SmartFarmingApp(
    tokenStorage: tokenStorage,
    authService: authService,
    lotesService: lotesService,
  ));
}

class SmartFarmingApp extends StatelessWidget {
  final TokenStorage tokenStorage;
  final AuthService authService;
  final LotesService lotesService;

  const SmartFarmingApp({
    super.key,
    required this.tokenStorage,
    required this.authService,
    required this.lotesService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Servicios disponibles para todas las pantallas
        Provider<AuthService>.value(value: authService),
        Provider<LotesService>.value(value: lotesService),

        // Provider de autenticacion (state management)
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService, tokenStorage),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Farming',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            error: AppColors.error,
            surfaceTint: AppColors.surfaceTint,
            surface: AppColors.background,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          textTheme: GoogleFonts.lexendTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: const WelcomeScreen(),
        builder: (context, child) {
          return Stack(
            children: [
              if (child != null) child,
              const Positioned(
                bottom: 80, // Por encima de la barra de navegación inferior
                left: 0,
                right: 0,
                // Ignorar punteros para que no bloquee los toques detrás del banner
                child: IgnorePointer(
                  child: SafeArea(
                    child: OfflineBanner(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
