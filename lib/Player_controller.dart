import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart'; // Make sure you have added this package

class PlayerController extends GetxController {
  final OnAudioQuery audioQuery = OnAudioQuery();
  final AudioPlayer audioPlayer = AudioPlayer(); // Initialized the audio player
  var songs = <SongModel>[].obs; // Store queried songs in an observable list

  var playIndex = 0.obs;
  var isPlaying = false.obs;

  var duration = "".obs;
  var position = "".obs;

  var max = 0.0.obs;
  var value = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermission();
  }

  // constantly updates the audio slider
  updatePosition() {
    audioPlayer.durationStream.listen((d) {
      // Ensure the duration (d) is not null before accessing it
      if (d != null) {
        duration.value = _formatDuration(d);    // Convert duration to readable format
        max.value = d.inSeconds.toDouble();     // Set the max value for the slider
      }
    });

    audioPlayer.positionStream.listen((p) {
      // Ensure the position (p) is not null before accessing it
      if (p != null) {
        position.value = _formatDuration(p);    // Convert position to readable format
        value.value = p.inSeconds.toDouble();   // Update the slider's current value
      }
    });
  }


  // helper funtion to check the audio length
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }


  // changes duration of song in seconds
  void changeDurationToSeconds(int seconds) {
    var newDuration = Duration(seconds: seconds);
    audioPlayer.seek(newDuration);  // Seek to the new position
  }


  // Play song from URI
  void playSong(String? uri, index) {
    playIndex.value = index;
    try {
      if (uri != null) {
        audioPlayer.setAudioSource(
            AudioSource.uri(Uri.parse(uri))
        );
        audioPlayer.play();
        isPlaying(true);
        updatePosition();
      } else {
        print("Invalid URI");
      }
    } on Exception catch (e) {
      print("Error playing song: $e");
    }
  }


  // Check and request permissions for accessing storage
  Future<void> checkPermission() async {
    var permission = await Permission.storage.request();
    if (permission.isGranted) {
      // Permission granted, fetch the songs
      fetchSongs();
    } else {
      // Permission denied, inform user or handle it
      print("Storage permission denied.");
    }
  }


  // Fetch songs and store them in the songs list
  Future<void> fetchSongs() async {
    try {
      var fetchedSongs = await audioQuery.querySongs(
        ignoreCase: true,
        orderType: OrderType.ASC_OR_SMALLER,
        sortType: null,
        uriType: UriType.EXTERNAL,
      );
      songs.value = fetchedSongs; // Update the observable list
    } catch (e) {
      print("Error fetching songs: $e");
    }
  }


  // Dispose the audio player when the controller is destroyed
  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
