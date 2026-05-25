import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'core/network/dio_client.dart';
import 'core/storage/database_helper.dart';
import 'core/storage/token_storage.dart';
import 'core/theme/app_colors.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/lotes_provider.dart';
import 'data/providers/profile_image_provider.dart';
import 'data/services/auth_service.dart';
import 'data/services/lotes_service.dart';
import 'data/services/sync_service.dart';
import 'data/services/catalogos_service.dart';
import 'data/services/catalogos_sync_service.dart';
import 'data/providers/catalogos_provider.dart';
import 'data/services/operaciones_service.dart';
import 'data/providers/operaciones_provider.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/widgets/offline_banner.dart';
import 'data/services/admin_service.dart';
import 'data/providers/admin_provider.dart';
import 'data/providers/tareas_provider.dart';
import 'data/services/recomendaciones_service.dart';
import 'data/providers/recomendaciones_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar SQLite al arrancar en plataformas nativas.
  // Flutter Web no soporta sqflite/path_provider de forma nativa.
  if (!kIsWeb) {
    await DatabaseHelper.instance.database;
  }

  // Inicializacion de dependencias (poor man's DI)
  final tokenStorage = TokenStorage();
  final dioClient = DioClient(tokenStorage);
  final authService = AuthService(dioClient, tokenStorage);
  final lotesService = LotesService(dioClient);
  final syncService = SyncService(dioClient);
  final catalogosService = CatalogosService(dioClient.dio);
  final catalogosSyncService = CatalogosSyncService(catalogosService);
  final operacionesService = OperacionesService(dioClient.dio);
  final adminService = AdminService(dioClient);
  final recomendacionesService = RecomendacionesService(dioClient);

  // Sincronizar catálogos en segundo plano al arrancar en plataformas nativas.
  if (!kIsWeb) {
    catalogosSyncService.sincronizarCatalogos();
  }

  runApp(SmartFarmingApp(
    tokenStorage: tokenStorage,
    authService: authService,
    lotesService: lotesService,
    syncService: syncService,
    catalogosSyncService: catalogosSyncService,
    operacionesService: operacionesService,
    dioClient: dioClient,
    adminService: adminService,
    recomendacionesService: recomendacionesService,
  ));
}

class SmartFarmingApp extends StatelessWidget {
  final TokenStorage tokenStorage;
  final AuthService authService;
  final LotesService lotesService;
  final SyncService syncService;
  final CatalogosSyncService catalogosSyncService;
  final OperacionesService operacionesService;
  final DioClient dioClient;
  final AdminService adminService;
  final RecomendacionesService recomendacionesService;

  const SmartFarmingApp({
    super.key,
    required this.tokenStorage,
    required this.authService,
    required this.lotesService,
    required this.syncService,
    required this.catalogosSyncService,
    required this.operacionesService,
    required this.dioClient,
    required this.adminService,
    required this.recomendacionesService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Servicios disponibles para todas las pantallas
        Provider<AuthService>.value(value: authService),
        Provider<LotesService>.value(value: lotesService),
        Provider<SyncService>.value(value: syncService),
        Provider<OperacionesService>.value(value: operacionesService),
        // DioClient expuesto para ChangePasswordScreen y otros
        Provider<DioClient>.value(value: dioClient),

        // Provider de autenticacion (state management)
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService, tokenStorage),
        ),

        // Provider de lotes con caché SQLite offline-first
        ChangeNotifierProvider<LotesProvider>(
          create: (_) => LotesProvider(lotesService),
        ),

        // Provider de imagen de perfil
        ChangeNotifierProxyProvider<AuthProvider, ProfileImageProvider>(
          create: (_) => ProfileImageProvider(dioClient),
          update: (_, auth, prev) {
            final provider = prev ?? ProfileImageProvider(dioClient);
            provider.setInitialAvatarUrl(auth.currentUser?.fotoPerfilUrl);
            return provider;
          },
        ),

        // Provider de catálogos (Sprint 2)
        ChangeNotifierProvider<CatalogosProvider>(
          create: (_) =>
              CatalogosProvider(catalogosSyncService)..cargarCatalogos(),
        ),

        // Provider de operaciones (Sprint 3)
        ChangeNotifierProvider<OperacionesProvider>(
          create: (_) => OperacionesProvider(operacionesService),
        ),

        // Provider de administración (Sprint 4)
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => AdminProvider(adminService),
        ),

        // Provider de tareas inteligentes — se carga en segundo plano al autenticarse
        ChangeNotifierProxyProvider<AuthProvider, TareasProvider>(
          create: (_) => TareasProvider(operacionesService),
          update: (_, auth, prev) {
            final provider = prev ?? TareasProvider(operacionesService);
            // Disparar carga en segundo plano si el usuario está autenticado
            // y aún no se han cargado tareas
            if (auth.currentUser != null) {
              Future.microtask(() => provider.cargarSiNoHay());
            }
            return provider;
          },
        ),

        // Provider del Sistema Experto de Recomendaciones (Sprint 4)
        ChangeNotifierProvider<RecomendacionesProvider>(
          create: (_) => RecomendacionesProvider(recomendacionesService),
        ),
      ],
      child: MaterialApp(
        title: 'AgroField',
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
                bottom: 80,
                left: 0,
                right: 0,
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
