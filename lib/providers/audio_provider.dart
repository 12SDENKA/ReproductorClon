import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/song.dart';

enum RepeatMode { off, one, all }

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.off;

  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Song? get currentSong => (_currentIndex >= 0 && _currentIndex < _queue.length)
      ? _queue[_currentIndex]
      : null;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Duration get position => _player.position;
  Duration? get duration => _player.duration;
  bool get isPlaying => _player.playing;

  Future<void> init() async {
    try {
      await _player.setAudioSource(_createEmptySource());
    } catch (e) {
      debugPrint('Audio init error: $e');
    }
  }

  AudioSource _createEmptySource() {
    return AudioSource.uri(
      Uri.parse('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'),
      tag: 'init',
    );
  }

  Future<void> setQueue(List<Song> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;
    _queue = List.from(songs);
    _currentIndex = startIndex.clamp(0, songs.length - 1);
    await _playCurrent();
    notifyListeners();
  }

  Future<void> playSong(Song song, {List<Song>? contextList}) async {
    if (contextList != null && contextList.isNotEmpty) {
      final idx = contextList.indexWhere((s) => s.id == song.id);
      await setQueue(contextList, startIndex: idx >= 0 ? idx : 0);
    } else {
      _queue = [song];
      _currentIndex = 0;
      await _playCurrent();
      notifyListeners();
    }
  }

  Future<void> _playCurrent() async {
    final song = currentSong;
    if (song == null) return;
    try {
      if (song.audioUrl != null && song.audioUrl!.isNotEmpty) {
        await _player.setUrl(song.audioUrl!);
        await _player.play();
      }
    } catch (e) {
      debugPrint('Play error for ${song.title}: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
    notifyListeners();
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    notifyListeners();
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;
    if (_repeatMode == RepeatMode.one) {
      await _playCurrent();
      return;
    }
    if (_isShuffle) {
      if (_queue.length == 1) return;
      int nextIdx;
      do {
        nextIdx = DateTime.now().millisecondsSinceEpoch % _queue.length;
      } while (nextIdx == _currentIndex);
      _currentIndex = nextIdx;
    } else {
      _currentIndex = (_currentIndex + 1) % _queue.length;
    }
    await _playCurrent();
    notifyListeners();
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;
    if (_player.position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      notifyListeners();
      return;
    }
    if (_isShuffle) {
      if (_queue.length == 1) return;
      int prevIdx;
      do {
        prevIdx = DateTime.now().millisecondsSinceEpoch % _queue.length;
      } while (prevIdx == _currentIndex);
      _currentIndex = prevIdx;
    } else {
      _currentIndex = (_currentIndex - 1 + _queue.length) % _queue.length;
    }
    await _playCurrent();
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void cycleRepeat() {
    _repeatMode = RepeatMode.values[
        (_repeatMode.index + 1) % RepeatMode.values.length];
    _player.setLoopMode(_repeatMode == RepeatMode.one
        ? LoopMode.one
        : (_repeatMode == RepeatMode.all ? LoopMode.all : LoopMode.off));
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}