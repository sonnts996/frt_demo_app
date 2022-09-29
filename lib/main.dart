import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frt_demo_app/app_center/app_center.dart';
import 'package:frt_demo_app/feature/home/home.page.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey();
late AppCenterService appCenterService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid || Platform.isIOS) {
    // await initAppCenter();
    appCenterService = AppCenterService(onUpdateNotify: (detail) async {
      if (navKey.currentContext != null) {
        return showDialog(
            context: navKey.currentContext!,
            builder: (context) {
              return AlertDialog(
                title: const Text('Thông báo update'),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, UpdateAction.update);
                      },
                      child: const Text('Update')),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, UpdateAction.postpone);
                      },
                      child: const Text('Postpone')),
                ],
              );
            });
      }
      return UpdateAction.postpone;
    });
    appCenterService.start('de4039ab-2a43-4be2-877c-231cbee8b18b');
    appCenterService.setEnabledForDebuggableBuild(true);
    appCenterService.checkForUpdate();
  }
  runApp(const MyApp());
}

// Future initAppCenter() async {
//   await AppCenter.startAsync(
//     appSecretAndroid: "de4039ab-2a43-4be2-877c-231cbee8b18b",
//     appSecretIOS: '******',
//     enableAnalytics: true,
//     // Defaults to true
//     enableCrashes: true,
//     // Defaults to true
//     enableDistribute: true,
//     // Defaults to false
//     usePrivateDistributeTrack: false,
//     // Defaults to false
//     disableAutomaticCheckForUpdate: false, // Defaults to false
//   );
//   await AppCenter.configureAnalyticsAsync(enabled: true);
//   await AppCenter.configureCrashesAsync(enabled: true);
//   await AppCenter.configureDistributeAsync(enabled: true);
//   await AppCenter.configureDistributeDebugAsync(enabled: true); // Android Only
//   await AppCenter.checkForUpdateAsync(); // Manually check for update
// }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      navigatorKey: navKey,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
