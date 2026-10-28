import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/audio_provider.dart';
import 'providers/library_provider.dart';
// import 'streamer/streamer_app.dart';
// import 'streamer/streamer_provider.dart';

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
      ],
      child: const ReproductorClonApp(), // Assuming this was your original app widget name
    ),
  );
}