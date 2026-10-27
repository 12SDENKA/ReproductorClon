import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/audio_provider.dart';
import 'providers/library_provider.dart';
import 'streamer/streamer_app.dart';
import 'streamer/streamer_provider.dart';

// Punto de entrada NUEVO. Tu main.dart sigue igual.
// Ejecutar con:  flutter run -t lib/main_streamer.dart -d chrome
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioProvider()..init()),
        ChangeNotifierProvider(create: (_) => LibraryProvider()..init()),
        ChangeNotifierProvider(create: (_) => StreamerProvider()), // nuevo
      ],
      child: const StreamerApp(),
    ),
  );
}
