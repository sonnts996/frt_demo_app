package vn.frt.app.frt_demo_app

import AppCenterService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {

    private lateinit var appCenterService: AppCenterService

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        appCenterService = AppCenterService(application, flutterEngine)
    }


}
