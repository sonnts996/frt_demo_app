import 'package:flutter/material.dart';
import 'package:flutter_appcenter_bundle/flutter_appcenter_bundle.dart';
import 'package:frt_demo_app/feature/home/home.page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await initAppCenter();
  runApp(const MyApp());
}
//
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
