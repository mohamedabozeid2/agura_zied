import 'package:again/controller/director_controller.dart';
import 'package:again/view/director/widgets/lobby_user.dart';
import 'package:again/view/director/widgets/stage_user.dart';
import 'package:again/widgets/custom_text_field.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DirectorScreen extends StatelessWidget {
  final String channelName;
  final TextEditingController streamUrl = TextEditingController();
  DirectorScreen({
    super.key,
    required this.channelName,
  });

  @override
  Widget build(BuildContext context) {
    DirectorController myController = Get.put(DirectorController());

    return Scaffold(
      appBar: AppBar(),
      body: GetBuilder<DirectorController>(
        init: DirectorController(),
        initState: (state) {
          myController.joinCall(channelName: channelName);
        },
        dispose: (state) {
          myController.loading = true;
          myController.leaveCall();
        },
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: CircularMenu(
              alignment: Alignment.bottomRight,
              toggleButtonColor: Colors.black87,
              toggleButtonBoxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                )
              ],
              items: [
                CircularMenuItem(
                  onTap: () {
                    controller.leaveCall();
                    Get.back();
                  },
                  icon: Icons.call_end,
                  color: Colors.red,
                ),
                controller.isLive
                    ? CircularMenuItem(
                        onTap: () {
                          controller.endStream();
                        },
                        icon: Icons.cancel,
                        color: Colors.yellow,
                      )
                    : CircularMenuItem(
                        onTap: () {
                          if (controller.destinations.isNotEmpty) {
                            controller.startStream(url: streamUrl.text.trim());
                          } else {
                            Get.snackbar('Error', 'No Destination',
                                backgroundColor: Colors.red,
                                colorText: Colors.white);
                          }
                        },
                        icon: Icons.videocam,
                        color: Colors.green,
                      )
              ],
              backgroundWidget: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const SafeArea(
                          child: Text("Director"),
                        ),
                      ],
                    ),
                  ),
                  controller.activeUsers.isEmpty
                      ? SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    10.0,
                                  ),
                                  child: const Text(
                                    'Empty Stage',
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : SliverGrid(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            return Row(
                              children: [
                                Expanded(
                                    child: StageUser(
                                  index: index,
                                  channelName: channelName,
                                ))
                              ],
                            );
                          }, childCount: controller.activeUsers.length),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                MediaQuery.of(context).size.width / 2,
                            crossAxisSpacing: 20.0,
                            mainAxisSpacing: 20.0,
                          ),
                        ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Divider(),
                      ],
                    ),
                  ),
                  controller.lobbyUsers.isEmpty
                      ? SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    10.0,
                                  ),
                                  child: const Text(
                                    'Empty Stage',
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : SliverGrid(
                          delegate:
                              SliverChildBuilderDelegate((context, index) {
                            return Row(
                              children: [
                                Expanded(
                                  child: LobbyUser(
                                    index: index,
                                  ),
                                )
                              ],
                            );
                          }, childCount: controller.lobbyUsers.length),
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent:
                                MediaQuery.of(context).size.width / 2,
                            crossAxisSpacing: 20.0,
                            mainAxisSpacing: 20.0,
                          ),
                        ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        SizedBox(
                          height: 20.0,
                        ),
                        CustomTextField(
                          context: context,
                          controller: streamUrl,
                          type: TextInputType.text,
                          label: 'Stream Url',
                          borderColor: Colors.black,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
