import 'package:again/core/utils/agora_settings.dart';
import 'package:again/model/user.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/hive/hive.dart';
import '../core/hive/hive_keys.dart';
import '../core/utils/constants.dart';

class ParticipantController extends GetxController {
  List<CustomAgoraUser> users = [];
  late RtcEngine engine;
  AgoraRtmClient? client;
  AgoraRtmChannel? channel;
  bool muted = false;
  bool videoDisabled = false;

  Future<void> initAgora({
    required String channelName,
  }) async {
    print("BEGIN");
    engine = createAgoraRtcEngine();
    print("Begin engine init");
    await engine.initialize(
      RtcEngineContext(
        appId: AgoraSettings.appID,
      ),
    );

    client = await AgoraRtmClient.createInstance(
      AgoraSettings.appID,
    );

    print("End engine init");
    await engine.enableAudio();
    await engine.enableVideo();
    await engine
        .setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    print("DONE ENGINE");
    // join the RTM and RTC channels
    await client?.login(null, Constants.uid.toString());
    channel = await client?.createChannel(channelName);
    await channel?.join();
    print("Befor:: join channel");
    print("UID: ${Constants.uid}");
    await engine.joinChannel(
        token: AgoraSettings.token,
        channelId: channelName,
        uid: Constants.uid!,
        options: const ChannelMediaOptions());
    print("JOIN:: CHANNEL");
    //Callbacks for RTC Engine

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          print("!@# ON JOiN Success");
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          // users.add(CustomAgoraUser(uid: remoteUid));
          print("!@# Participant user joined $remoteUid");
          update();
        },
        onLeaveChannel: (connection, stats) {
          users.clear();
        },
      ),
    );

    // Callbacks for RTM Client

    client?.onMessageReceived = (message, peerId) {
      print("!@# Message recieved $peerId : ${message.text}");
    };
    client?.onConnectionStateChanged2 = (state, reason) {
      print(
        '!@# Connection state changed: ${state.toString()} , Reason ${reason.toString()}',
      );
      if (state == RtmConnectionState.disconnected ||
          state == RtmConnectionState.aborted) {
        channel?.leave();
        client?.logout();
        client?.release();
        print("!@# LOGOUT");
      }
    };

    // Callbacks for RTM Channel
    channel?.onMemberJoined = (member) {
      print(
          "!#@ Member Joined: ${member.userId} , Channel : ${channel?.channelId}");
    };
    channel?.onMemberLeft = (member) {
      print(
          "!#@ Member Left: ${member.userId} , Channel : ${channel?.channelId}");
    };
    channel?.onMessageReceived = (message, fromMember) {
      print(
          "!@# Public message from ${fromMember.userId} , Message : ${message.text}");
    };

    print("AGORA:: SUCCESS");
  }

  Future<void> getUserId() async {
    HiveHelper.getBoxData(box: HiveHelper.uid, key: HiveKeys.uid);
    if (Constants.uid == null || Constants.uid == 0) {
      int time = DateTime.now().millisecondsSinceEpoch;
      Constants.uid =
          int.parse(time.toString().substring(1, time.toString().length - 3));
      HiveHelper.putInBox(
          box: HiveHelper.uid, key: HiveKeys.uid, data: Constants.uid);
      print("Settings UID ${Constants.uid}");
    } else {
      Constants.uid = Constants.uid!;
      print("LAST UID ${Constants.uid}");
    }
  }

  void onToggleMute() {
    muted = !muted;
    engine.muteLocalAudioStream(muted);
    update();
  }

  void onToggleVideoDisabled() {
    videoDisabled = !videoDisabled;
    engine.muteLocalVideoStream(videoDisabled);
    update();
  }

  void onSwitchCamera() {
    engine.switchCamera();
    update();
  }

  onCallEnd(BuildContext context) {
    print("TEST");
    Navigator.pop(context);
    Get.back();
  }
}
