import 'package:again/controller/participant_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToolBar extends StatelessWidget {
  const ToolBar({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParticipantController>(
      builder: (controller) {
        return Container(
          alignment: Alignment.bottomCenter,
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              /* activeUser
                  ?  */
              RawMaterialButton(
                onPressed: controller.onToggleMute,
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: controller.muted ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  controller.muted ? Icons.mic_off : Icons.mic,
                  color: controller.muted ? Colors.white : Colors.blueAccent,
                  size: 20.0,
                ),
              ) /* : const SizedBox() */,
              RawMaterialButton(
                onPressed: () => controller.onCallEnd(context),
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(15.0),
                child: const Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 35.0,
                ),
              ),
              /* activeUser
                  ?  */
              RawMaterialButton(
                onPressed: controller.onToggleVideoDisabled,
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor:
                    controller.videoDisabled ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(12.0),
                child: Icon(
                  controller.videoDisabled
                      ? Icons.videocam_off
                      : Icons.videocam,
                  color: controller.videoDisabled
                      ? Colors.white
                      : Colors.blueAccent,
                  size: 20.0,
                ),
              ) /*  : const SizedBox() */,
              /* activeUser
                  ?  */
              RawMaterialButton(
                onPressed: controller.onSwitchCamera,
                shape: const CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(12.0),
                child: const Icon(
                  Icons.switch_camera,
                  color: Colors.blueAccent,
                  size: 20.0,
                ),
              ) /*  : const SizedBox() */,
            ],
          ),
        );
      },
    );
  }
}
