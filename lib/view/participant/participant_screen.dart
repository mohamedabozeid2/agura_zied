import 'package:again/controller/participant_controller.dart';
import 'package:again/view/participant/widgets/broadcast_view.dart';
import 'package:again/view/participant/widgets/toolbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ParticipantScreen extends StatefulWidget {
  final String channelName;
  final String userName;
  const ParticipantScreen({
    super.key,
    required this.userName,
    required this.channelName,
  });

  @override
  State<ParticipantScreen> createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  ParticipantController myController = Get.put(ParticipantController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GetBuilder<ParticipantController>(
        initState: (state) {
          myController.initAgora(channelName: widget.channelName);
        },
        dispose: (state) {
          myController.users.clear();
          myController.engine.leaveChannel();
          myController.engine.release();
          myController.channel?.leave();
          myController.client?.logout();
          myController.client?.release();
        },
        builder: (controller) {
          return Center(
            child: Column(
              children: [
                BroadCastView(
                  channelName: widget.channelName,
                ),
                const ToolBar(),
              ],
            ),
          );
        },
      ),
    );
  }
}
