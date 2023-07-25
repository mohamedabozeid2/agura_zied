import 'package:again/controller/director_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LobbyUser extends StatelessWidget {
  final DirectorController myController = Get.put(DirectorController());

  final int index;
  LobbyUser({
    super.key,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DirectorController>(
      init: DirectorController(),
      builder: (controller) {
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(15.0)),
          child: Stack(
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: /* directorData.lobbyUsers
                          .elementAt(index)
                          .videoDisabled
                      ? Stack(
                          children: [
                            Container(
                              color: Colors.black,
                            ),
                            const Align(
                              alignment: Alignment.center,
                              child: Text(
                                "Video Off",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          ],
                        )
                      :  */
                      Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0)),
                            color: controller.lobbyUsers
                                .elementAt(index)
                                .backgroundcolor!
                                .withOpacity(1.0),
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            controller.lobbyUsers.elementAt(index).name ??
                                "No Name",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Colors.black54,
                        ),
                        child: Column(
                          children: [
                            IconButton(
                              onPressed: () {
                                print("TEST");
                                myController.promoteToActiveUser(
                                    uid: controller.lobbyUsers
                                        .elementAt(index)
                                        .uid);
                              },
                              icon: const Icon(Icons.arrow_upward),
                            ),
                          ],
                        ),
                      )
                    ],
                  ))
            ],
          ),
        );
      },
    );
  }
}
