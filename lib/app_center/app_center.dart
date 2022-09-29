/*
 Created by Thanh Son on 29/09/2022.
 Copyright (c) 2022 . All rights reserved.
*/
import 'package:flutter/services.dart';

enum DistributeAction { $public, $private, $debugEnable, $debugDisable }

extension DistributeX on DistributeAction {
  int get value {
    switch (this) {
      case DistributeAction.$public:
        return 1;
      case DistributeAction.$private:
        return 2;
      case DistributeAction.$debugEnable:
        return 3;
      case DistributeAction.$debugDisable:
        return 4;
    }
  }
}

enum UpdateAction { update, postpone }

class ReleaseDetail {
  const ReleaseDetail({
    this.mandatoryUpdate = false,
    this.releaseNotes,
    this.releaseNotesUrl,
    required this.versionCode,
    required this.versionName,
  });

  final String versionName;
  final int versionCode;
  final String? releaseNotes;
  final String? releaseNotesUrl;
  final bool mandatoryUpdate;
}

class AppCenterService {
  final String channel = 'AppCenter';
  late final MethodChannel methodChannel;
  final Future<UpdateAction?> Function(ReleaseDetail? detail)? onUpdateNotify;

  AppCenterService({this.onUpdateNotify}) {
    methodChannel = MethodChannel(channel);
    methodChannel.setMethodCallHandler(onMethodCall);
  }

  Future<dynamic> onMethodCall(MethodCall call) async {
    switch (call.method) {
      case "update_result":
        onUpdateResult(call.arguments as Map<String, dynamic>?);
    }
  }

  void onUpdateResult(Map<String, dynamic>? map) async {
    if (onUpdateNotify != null && map != null) {
      final versionName = map['versionName'] as String;
      final versionCode = map['versionCode'] as int;
      final releaseNotes = map['releaseNotes'] as String?;
      final releaseNotesUrl = map['releaseNotesUrl'] as String?;
      final mandatoryUpdate = map['mandatoryUpdate'] as bool;

      final releaseDetail = ReleaseDetail(
        versionCode: versionCode,
        versionName: versionName,
        mandatoryUpdate: mandatoryUpdate,
        releaseNotes: releaseNotes,
        releaseNotesUrl: releaseNotesUrl,
      );

      var result = await onUpdateNotify!.call(releaseDetail);
      if (result == UpdateAction.update) {
        methodChannel.invokeMethod('update', true);
      } else {
        methodChannel.invokeMethod('update', false);
      }
    } else if (onUpdateNotify != null) {
      await onUpdateNotify!.call(null);
    }
  }

  void start(String id) {
    methodChannel.invokeMethod('start', {
      "id": id,
      "checkForUpdate": true,
    });
  }

  void setUpdateTrack(bool isPrivate) {
    if (isPrivate) {
      methodChannel.invokeMethod('update_track', DistributeAction.$private.value);
    } else {
      methodChannel.invokeMethod('update_track', DistributeAction.$public.value);
    }
  }

  void setEnabledForDebuggableBuild(bool enable) {
    if (enable) {
      methodChannel.invokeMethod('update_track', DistributeAction.$debugEnable.value);
    } else {
      methodChannel.invokeMethod(
          'update_track', DistributeAction.$debugDisable.value);
    }
  }

  void checkForUpdate() {
    methodChannel.invokeMethod('check_update');
  }
}
