import 'dart:convert';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_rtm/agora_rtm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/api/agora_dio_helper.dart';
import '../core/utils/agora_settings.dart';
import '../core/utils/constants.dart';
import '../core/utils/vimeo_settings.dart';
import '../model/stream.dart';
import '../model/user.dart';
import 'package:http/http.dart' as http;

class DirectorController extends GetxController {
  RtcEngine? engine;
  AgoraRtmClient? client;
  AgoraRtmChannel? channel;
  Set<CustomAgoraUser> activeUsers = {};
  Set<CustomAgoraUser> lobbyUsers = {};
  CustomAgoraUser? localUser;
  bool isLive = false;
  List<StreamDestination> destinations = [];
  bool loading = true;

  Future<void> initAgora({required String channelName}) async {
    engine = createAgoraRtcEngine();
    await engine?.initialize(
      RtcEngineContext(
        appId: AgoraSettings.appID,
      ),
    );

    client = await AgoraRtmClient.createInstance(
      AgoraSettings.appID,
    );
    getToken(channelName: channelName);
    // getStreamKey();
  }

  Future<void> joinCall({
    required String channelName,
  }) async {
    await initAgora(channelName: channelName);
    await engine?.enableAudio();
    await engine?.enableVideo();
    await engine?.startPreview();
    await engine
        ?.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await engine?.setClientRole(role: ClientRoleType.clientRoleBroadcaster);

    await client?.login(AgoraSettings.token, Constants.uid.toString());
    channel = await client?.createChannel(channelName);
    await channel?.join();
    await engine?.joinChannel(
        token: AgoraSettings.token,
        channelId: channelName,
        uid: Constants.uid!,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ));

    //Callbacks for RTC Engine

    engine?.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          print("### ON JOiN Success");
          addUserToLobby(uid: Constants.uid!);
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          // users.add(CustomAgoraUser(uid: remoteUid));
          print("### Participant user joined $remoteUid");
          update();
        },
        onLeaveChannel: (connection, stats) {
          // users.clear();
        },
        onUserOffline: (connection, remoteUid, reason) {
          removeUser(uid: remoteUid);
        },
        onError: (err, msg) {
          print("### Error $err , message $msg");
        },
      ),
    );

    // Callbacks for RTM Client

    client?.onMessageReceived = (message, peerId) {
      print("### Message recieved $peerId : ${message.text}");
    };
    client?.onConnectionStateChanged2 = (state, reason) {
      print(
        '### Connection state changed: ${state.toString()} , Reason ${reason.toString()}',
      );
      if (state == RtmConnectionState.disconnected ||
          state == RtmConnectionState.aborted) {
        channel?.leave();
        client?.logout();
        client?.release();
        print("### LOGOUT");
      }
    };

    // Callbacks for RTM Channel
    channel?.onMemberJoined = (member) {
      print(
          "### Member Joined: ${member.userId} , Channel : ${channel?.channelId}");
    };
    channel?.onMemberLeft = (member) {
      print(
          "### Member Left: ${member.userId} , Channel : ${channel?.channelId}");
    };
    channel?.onMessageReceived = (message, fromMember) {
      print(
          "### Public message from ${fromMember.userId} , Message : ${message.text}");
    };

    print("AGORA:: SUCCESS");
    loading = false;
    update();
  }

  Future<void> leaveCall() async {
    await engine?.leaveChannel();
    await engine?.release();
    await channel?.leave();
    await client?.logout();
    await client?.release();
    update();
  }

  Future<void> addUserToLobby({
    required int uid,
  }) async {
    lobbyUsers = {
      ...lobbyUsers,
      CustomAgoraUser(
        uid: uid,
        muted: true,
        videoDisabled: true,
        name: 'test',
        backgroundcolor: Colors.blue,
      )
    };
    update();
  }

  Future<void> promoteToActiveUser({required int uid}) async {
    Set<CustomAgoraUser> tempLobby = lobbyUsers;
    Color? tempColor;
    String? tempName;
    for (int i = 0; i < tempLobby.length; i++) {
      if (tempLobby.elementAt(i).uid == uid) {
        tempColor = tempLobby.elementAt(i).backgroundcolor;
        tempName = tempLobby.elementAt(i).name;
        tempLobby.remove(tempLobby.elementAt(i));
      }
    }
    activeUsers = {
      ...activeUsers,
      CustomAgoraUser(
        uid: uid,
        backgroundcolor: tempColor,
        name: tempName,
      )
    };
    lobbyUsers = tempLobby;
    if (isLive) {
      updateStream();
    }
    update();
  }

  Future<void> demoteToLobbyUser({required int uid}) async {
    Set<CustomAgoraUser> tempActive = activeUsers;
    Color? tempColor;
    String? tempName;
    for (int i = 0; i < tempActive.length; i++) {
      if (tempActive.elementAt(i).uid == uid) {
        tempColor = tempActive.elementAt(i).backgroundcolor;
        tempName = tempActive.elementAt(i).name;
        tempActive.remove(tempActive.elementAt(i));
      }
    }
    lobbyUsers = {
      ...lobbyUsers,
      CustomAgoraUser(
        uid: uid,
        backgroundcolor: tempColor,
        name: tempName,
      )
    };
    activeUsers = tempActive;
    if (isLive) {
      updateStream();
    }
    update();
  }

  Future<void> removeUser({
    required int uid,
  }) async {
    Set<CustomAgoraUser> tempActive = activeUsers;
    Set<CustomAgoraUser> tempLobby = lobbyUsers;
    for (int i = 0; i < tempActive.length; i++) {
      if (tempActive.elementAt(i).uid == uid) {
        tempActive.remove(tempActive.elementAt(i));
      }
    }
    for (int i = 0; i < tempLobby.length; i++) {
      if (tempLobby.elementAt(i).uid == uid) {
        tempLobby.remove(tempLobby.elementAt(i));
      }
    }

    activeUsers = tempActive;
    lobbyUsers = lobbyUsers;
    if (isLive) {
      updateStream();
    }
    update();
  }

  Future<void> toggleUserAudio(
      {required int index, required bool muted}) async {
    if (muted) {
    } else {}
  }

  Future<void> toggleUserVideo() async {}

  Future<void> startStream({required String url}) async {
    // List<TranscodingUser> transcodingUsers = [];
    // if (activeUsers.isEmpty) {
    // } else if (activeUsers.length == 1) {

    // }
    engine?.startRtmpStreamWithoutTranscoding(url);
  }

  Future<void> updateStream() async {}

  Future<void> endStream() async {
    destinations.clear();
    isLive = false;
    leaveCall();
  }

  Future<void> addPublishDestination({
    required StreamPlatform platform,
    required String url,
  }) async {
    if (isLive) {
      /// addPublishStreamUrl();
    }
    destinations = [
      ...destinations,
      StreamDestination(
        platform: platform,
        url: url,
      )
    ];
  }

  Future<void> removePublishDestination() async {}

  Future<void> getToken({required String channelName}) async {
    try {
      final url = Uri.parse(
          'http://10.147.17.76:8080/rtc/test/publisher/userAccount/690188597');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      print('token:::success $data');
    } catch (error) {
      print("ERROR:::token $error");
    }
    // await AgoraDiohelper.getData(
    //   url: '/rtc/$channelName/publisher/userAccount/${Constants.uid}',
    // ).then((value) {
    //   print("TEST:::");
    //   AgoraSettings.token = value.data['rtcToken'];
    //   print('token::: ${value.data['rtcToken']}');
    // }).catchError(
    //   (error) {
    //     print("error:::token $error");
    //   },
    // ).onError((error, stackTrace) {
    //   print("ERROR::token $error");
    // });
  }

  Future<void> getStreamKey() async {
    print("GET STREAM KEY:::");
    try {
      final response = await http.post(
        Uri.parse('https://api.vimeo.com/me/live_events'),
        body: jsonEncode({
          "title": "test",
          "stream_title": "12",
          "stream_privacy": {"view": "anybody"}
        }),
        headers: {
          'Authorization': 'Bearer ${VimeoSettings.accessToken}',
          'Content-Type': 'application/json',
          'Accept': 'application/vnd.vimeo.*+json;version=3.4',
        },
      );

      final data = jsonDecode(response.body);
      print('data:: $data');
    } catch (failure) {
      print("ERRor:: $failure");
    }
  }
}
