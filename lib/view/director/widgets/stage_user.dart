import 'package:again/controller/director_controller.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/constants.dart';

class StageUser extends StatelessWidget {
  final int index;
  final String channelName;

  const StageUser({
    Key? key,
    required this.index,
    required this.channelName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DirectorController>(
      init: DirectorController(),
      builder: (controller) {
        return Container(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: controller.activeUsers.elementAt(index).videoDisabled
                    ? Stack(
                        children: [
                          Container(
                            color: Colors.black,
                          ),
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Video Off",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      )
                    : Stack(
                        children: [
                          AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: controller.engine!,
                              canvas: VideoCanvas(uid: 0),
                              // connection: RtcConnection(
                              //   channelId: channelName,
                              // ),
                            ),
                          ),
                          // RtcLocalView.SurfaceView(),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(10)),
                                  color: controller.activeUsers
                                      .elementAt(index)
                                      .backgroundcolor!
                                      .withOpacity(1)),
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                controller.activeUsers.elementAt(index).name ??
                                    "name error",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black54),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        print("MIC button test");
                        if (controller.activeUsers.elementAt(index).muted) {
                          // controller.toggleUserAudio(index: index, muted: true);
                        } else {
                          // controller.toggleUserAudio(
                          //     index: index, muted: false);
                        }
                      },
                      icon: const Icon(Icons.mic_off),
                      color: controller.activeUsers.elementAt(index).muted
                          ? Colors.red
                          : Colors.white,
                    ),
                    IconButton(
                      onPressed: () {
                        print("TEST");
                        if (controller.activeUsers
                            .elementAt(index)
                            .videoDisabled) {
                          // controller.toggleUserVideo(
                          //     index: index, enable: false);
                        } else {
                          // controller.toggleUserVideo(
                          //     index: index, enable: true);
                        }
                      },
                      icon: const Icon(Icons.videocam_off),
                      color:
                          controller.activeUsers.elementAt(index).videoDisabled
                              ? Colors.red
                              : Colors.white,
                    ),
                    IconButton(
                      onPressed: () {
                        controller.demoteToLobbyUser(
                            uid: controller.activeUsers.elementAt(index).uid);
                      },
                      icon: const Icon(Icons.arrow_downward),
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
