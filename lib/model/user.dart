import 'package:flutter/material.dart';

class CustomAgoraUser {
  int uid;
  bool muted;
  bool videoDisabled;
  String? name;
  Color? backgroundcolor;

  CustomAgoraUser({
    required this.uid,
    this.muted = false,
    this.videoDisabled = false,
    this.name,
    this.backgroundcolor,
  });
}
