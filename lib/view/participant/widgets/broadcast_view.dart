import 'package:again/controller/participant_controller.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class BroadCastView extends StatelessWidget {
  final String channelName;
  const BroadCastView({
    super.key,
    required this.channelName,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParticipantController>(
      builder: (controller) {
        return Container(
          child: Expanded(
            child: AgoraVideoView(
              controller: VideoViewController(
                rtcEngine: controller.engine,
                canvas: VideoCanvas(uid: 0),
                // connection: RtcConnection(
                //   channelId: channelName,
                // ),
              ),
            ),
          ),
        );
      },
    );
  }
}
