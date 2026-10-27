import 'package:flutter/material.dart';

import '../models/album.dart';
import '../models/artist.dart';
import '../models/playlist.dart';
import '../screens/album_detail_screen.dart';
import '../screens/artist_detail_screen.dart';
import '../screens/playlist_detail_screen.dart';
import '../theme/app_theme.dart';
import 'streamer_shell.dart';

/// Igual que tu ReproductorClonApp (mismo tema y rutas) pero con StreamerShell.
class StreamerApp extends StatelessWidget {
  const StreamerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReproductorClon + Streamer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const StreamerShell(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/album':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => AlbumDetailScreen(album: settings.arguments as Album),
            );
          case '/playlist':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) =>
                  PlaylistDetailScreen(playlist: settings.arguments as Playlist),
            );
          case '/artist':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => ArtistDetailScreen(artist: settings.arguments as Artist),
            );
        }
        return null;
      },
    );
  }
}
