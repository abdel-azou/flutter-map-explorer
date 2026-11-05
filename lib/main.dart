import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';

import 'models/mural.dart';
import 'views/home_screen.dart';
import 'views/mural_screen.dart';

// Variable globale pour stocker la position
Position? _userPosition;

Future<void> _locateUser() async {
  var permission = await Geolocator.checkPermission();

  // permission is not granted, request it
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  // permission is still not granted, or denied forever, we can't get location
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return;
  }

  _userPosition = await Geolocator.getCurrentPosition();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _locateUser();
  runApp(const MuralMapApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'mural',
          builder: (context, state) {
            final mural = state.extra;
            if (mural is! Mural) {
              return Scaffold(
                appBar: AppBar(title: const Text('Détail de la fresque')),
                body: const Center(child: Text('Aucune fresque sélectionnée.')),
              );
            }
            return MuralScreen(mural: mural, userPosition: _userPosition);
          },
        ),
      ],
    ),
  ],
);

class MuralMapApp extends StatelessWidget {
  const MuralMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Fresques murales BD de Bruxelles',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}