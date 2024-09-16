import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tuneblend/colors.dart';
import 'package:tuneblend/player.dart';
import 'package:tuneblend/textstyle.dart';
import 'package:tuneblend/player_controller.dart';


class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    // Correctly instantiate PlayerController
    var controller = Get.put(PlayerController());

    return Scaffold(
      backgroundColor: bgDarkcolor,
      appBar: AppBar(
        backgroundColor: bgDarkcolor,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: lightcolor)),
        ],
        leading: Icon(Icons.sort_rounded, color: lightcolor),
        title: Text(
          "Tune Blend",
          style: ourStyle(
            family: bold,
            size: 18,
          ),
        ),
      ),
      body: FutureBuilder<List<SongModel>>(
        future: controller.audioQuery.querySongs(
          ignoreCase: true,
          orderType: OrderType.ASC_OR_SMALLER,
          sortType: null,
          uriType: UriType.EXTERNAL,
        ),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "An error occurred: ${snapshot.error}",
                style: ourStyle(),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Song Directory is Empty, No songs found",
                style: ourStyle(),
              ),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.length, // Use dynamic song count
                itemBuilder: (BuildContext context, int index) {
                  SongModel song = snapshot.data![index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: Obx(() => ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: bgColor,
                      title: Text(
                        song.title, // Display song title
                        style: ourStyle(family: regular, size: 12),
                      ),
                      subtitle: Text(
                        song.artist ?? 'Unknown Artist', // Display artist or default text
                        style: ourStyle(family: regular, size: 12),
                      ),
                      leading: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        nullArtworkWidget: const Icon(
                          Icons.library_music_rounded,
                          color: lightcolor,
                          size: 32,
                        ),
                      ),
                      trailing: controller.playIndex.value == index && controller.isPlaying.value
                          ? const Icon(
                          Icons.play_arrow_outlined,
                          color: whitecolor,
                          size: 26 )
                          : null,
                      onTap: () {
                        Get.to(
                                ()=> Player(
                                  data: snapshot.data!,
                                ),
                          transition: Transition.downToUp,
                        );
                        controller.playSong(snapshot.data![index].uri, index); // Play song on tap
                      },
                    ),)
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
