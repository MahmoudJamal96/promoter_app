import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

int soundId = 0;

class Audio {
  static final Audio _audio = Audio._();

  static Audio getInstance() => _audio;
  // final player = AudioPlayer();
  static Soundpool pool = Soundpool.fromOptions(
      options: const SoundpoolOptions(
          streamType: StreamType.music,
          androidOptions: SoundpoolOptionsAndroid()));

  Audio._();

  Future<void> play(String audioName) async {
    final asset = await rootBundle.load('assets/$audioName');
    final sound = await pool.load(asset);
    soundId = sound;
    pool.play(sound);
  }

  Future<void> playOnline(String audioName) async {
    final sound = await pool.loadUri(audioName);
    pool.play(sound);
  }

  void stop() {
    pool.pause(soundId);
  }
}
