# 🚀 ReproductorClon - Setup Guide

## Requisitos
- Flutter SDK 3.47.2 (instalado en `C:\flutter`)
- Dart SDK 3.13.2
- Para Android: Android SDK en `C:\Android\Sdk`
- Para iOS: Xcode (solo macOS)

## Estructura del Proyecto

```
ReproductorClon/
├── lib/
│   ├── main.dart                    # Punto de entrada
│   ├── app.dart                     # MaterialApp + rutas
│   ├── theme/                       # Tema Apple Music
│   ├── models/                      # Song, Album, Artist, Playlist
│   ├── data/                        # Datos de muestra
│   ├── providers/                   # AudioProvider, LibraryProvider
│   ├── screens/                     # Pantallas
│   │   ├── home_shell.dart          # Bottom navigation + mini player
│   │   ├── home_screen.dart         # Inicio
│   │   ├── search_screen.dart       # Búsqueda + géneros
│   │   ├── library_screen.dart      # Biblioteca con tabs
│   │   ├── now_playing_screen.dart  # Reproductor a pantalla completa
│   │   ├── album_detail_screen.dart
│   │   ├── playlist_detail_screen.dart
│   │   └── artist_detail_screen.dart
│   └── widgets/                     # MiniPlayer, SongTile, AlbumCard, etc.
├── android/                         # Configuración Android
├── ios/                             # Configuración iOS
├── web/                             # Build web generado
└── test/                            # Tests
```

## Comandos rápidos

### Ver el código en el navegador (Chrome)
```
flutter run -d chrome
```

### Compilar para web (producción)
```
flutter build web --release
```
Luego abrir `build/web/index.html` en el navegador.

### Compilar APK Android
```
flutter build apk --release
```
APK queda en `build/app/outputs/flutter-apk/app-release.apk`

### Analizar código
```
flutter analyze
```

### Ejecutar tests
```
flutter test
```

## Características implementadas

- 🎵 **Reproductor de audio** funcional con just_audio
- 🎨 **Tema oscuro** estilo Apple Music
- 📱 **Bottom navigation** (Inicio, Buscar, Biblioteca)
- 🎼 **Mini player** persistente en la parte inferior
- 🎤 **Pantalla Now Playing** completa con:
  - Carátula grande
  - Barra de progreso con seek
  - Controles: play/pause, next, previous
  - Modos: shuffle, repeat (off/all/one)
  - Like / download
- 🔍 **Búsqueda** en tiempo real (canciones, álbumes, artistas)
- 🎨 **Exploración por géneros** con grid de colores
- 📚 **Biblioteca** con tabs (Playlists, Álbumes, Artistas, Canciones)
- ❤️ **Sistema de favoritos** (Me gusta)
- 📲 **Pantallas de detalle** para álbum, playlist y artista
- 🎬 **Reproducción real** desde SoundHelix URLs

## Audio de muestra

Las canciones usan audio gratuito de SoundHelix:
`https://www.soundhelix.com/examples/mp3/SoundHelix-Song-N.mp3`

Las portadas se generan desde picsum.photos con seeds deterministas.

## Notas técnicas

- Provider para state management
- just_audio para reproducción
- Google Fonts (Inter) para tipografía
- Imágenes con errorBuilder para mostrar placeholders
- Navegación con Navigator.pushNamed para detalles
- Material 3 con ColorScheme personalizado
