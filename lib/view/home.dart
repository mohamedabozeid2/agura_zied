import 'dart:convert';

import 'package:again/controller/participant_controller.dart';
import 'package:again/core/utils/constants.dart';
import 'package:again/view/director/director_screen.dart';
import 'package:again/view/participant/participant_screen.dart';
import 'package:again/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

import '../core/api/agora_dio_helper.dart';
import '../core/utils/agora_settings.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController channelNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final ParticipantController myController = Get.put(ParticipantController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: GetBuilder<ParticipantController>(
        init: ParticipantController(),
        initState: (state) {
          myController.getUserId();
        },
        builder: (controller) {
          print("FROM HOME ${Constants.uid}");
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextField(
                  context: context,
                  controller: userNameController,
                  type: TextInputType.text,
                  label: 'User Name',
                ),
                CustomTextField(
                  context: context,
                  controller: channelNameController,
                  type: TextInputType.text,
                  label: 'channel Name',
                ),
                MaterialButton(
                  color: Colors.blue,
                  onPressed: () async {
                    if (channelNameController.text.isEmpty) {
                      Get.snackbar(
                        'error',
                        'validation',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    } else {
                      await [Permission.camera, Permission.microphone]
                          .request();

                      Get.to(
                        DirectorScreen(
                          channelName: channelNameController.text,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Director',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                MaterialButton(
                  color: Colors.blue,
                  onPressed: () async {
                    if (userNameController.text.isEmpty ||
                        channelNameController.text.isEmpty) {
                      Get.snackbar(
                        'error',
                        'validation',
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    } else {
                      await [Permission.camera, Permission.microphone]
                          .request();

                      Get.to(
                        ParticipantScreen(
                          channelName: channelNameController.text,
                          userName: userNameController.text,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Participant',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                MaterialButton(
                  color: Colors.blue,
                  onPressed: () async {
                    print("START");
                    try {
                      final url = Uri.parse(
                          'http://10.147.17.76:8080/rtc/test/publisher/userAccount/690188597');
                      final response = await http.get(url);
                      final data = jsonDecode(response.body);
                      print('token:::success');
                    } catch (error) {
                      print("ERROR:::token $error");
                    }

                    // await AgoraDiohelper.getData(
                    //   url: '/rtc/test/publisher/userAccount/690188597',
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
                  },
                  child: const Text(
                    'print',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
