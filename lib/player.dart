import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:tuneblend/colors.dart';
import 'package:tuneblend/textstyle.dart';
import 'package:tuneblend/player_controller.dart';

class Player extends StatelessWidget {
  final List<SongModel> data;
  const Player({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var controller = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: slidercolor,
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Obx(() => Expanded(
                child: Container(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Container_red,
                  ),
                  alignment: Alignment.center,
                  child: QueryArtworkWidget(
                    id: data[controller.playIndex.value].id,
                    type: ArtworkType.AUDIO,
                    artworkHeight: double.infinity,
                    artworkWidth: double.infinity,
                    nullArtworkWidget: const Icon(
                      Icons.music_note_outlined,
                      size: 50,
                      color: whitecolor,
                    ),
                  ),
                )
            ),
            ),
            const SizedBox(height: 15),
            Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: whitecolor,
                    borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                  child: Obx(
                          () => Column(
                            children: [
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                data[controller.playIndex.value].displayNameWOExt,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: ourStyle(
                                  color: bgDarkcolor,
                                  family: bold,
                                  size: 24,
                                ),
                              ),
                              Text(
                                data[controller.playIndex.value].artist ?? 'Unknown Artist',
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: ourStyle(
                                  color: bgDarkcolor,
                                  family: regular,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              const SizedBox(height: 12),
                              Obx(() => Row(
                                children: [
                                  Text(controller.position.value, style: ourStyle(color: bgDarkcolor)),
                                  Expanded(
                                    child: Slider(
                                      thumbColor: slidercolor,
                                      inactiveColor: bgColor,
                                      activeColor: slidercolor,
                                      min: 0.0,
                                      max: controller.max.value,
                                      value: controller.value.value,
                                      onChanged: (newValue) {
                                        controller.changeDurationToSeconds(newValue.toInt());
                                      },
                                    ),
                                  ),
                                  Text(
                                    controller.duration.value,
                                    style: ourStyle(color: bgDarkcolor),
                                  ),
                                ],
                              )),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      controller.playSong(data[controller.playIndex.value-1].uri, controller.playIndex.value-1);
                                    },
                                    icon: const Icon(
                                      Icons.skip_previous_outlined,
                                      size: 50,
                                      color: prev_next,
                                    ),
                                  ),
                                  Obx(() => CircleAvatar(
                                    radius: 27,
                                    backgroundColor: bgDarkcolor,
                                    child: Transform.scale(
                                      scale: 1.9,
                                      child: IconButton(
                                        onPressed: () {
                                          if (controller.isPlaying.value) {
                                            controller.audioPlayer.pause();
                                            controller.isPlaying(false);
                                          } else {
                                            controller.audioPlayer.play();
                                            controller.isPlaying(true);
                                          }
                                        },
                                        icon: controller.isPlaying.value
                                            ? const Icon(Icons.pause, color: play_pause)
                                            : const Icon(Icons.play_arrow_rounded, color: play_pause),
                                      ),
                                    ),
                                  )
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Ensure to handle index bounds
                                      if (controller.playIndex.value < data.length - 1) {
                                        controller.playSong(data[controller.playIndex.value + 1].uri, controller.playIndex.value + 1);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.skip_next_outlined,
                                      size: 50,
                                      color: prev_next,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),),
                )
            ),
          ],
        ),
      ),
    );
  }
}
