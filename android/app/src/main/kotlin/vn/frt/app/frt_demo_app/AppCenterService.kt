import android.app.Activity
import android.app.Application
import android.net.Uri
import android.util.Log
import com.microsoft.appcenter.AppCenter
import com.microsoft.appcenter.analytics.Analytics
import com.microsoft.appcenter.crashes.Crashes
import com.microsoft.appcenter.distribute.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel


class CustomDistributeListener(private val methodChannel: MethodChannel) : DistributeListener {

    override fun onReleaseAvailable(activity: Activity?, releaseDetails: ReleaseDetails?): Boolean {
        val versionName = releaseDetails!!.shortVersion
        val versionCode = releaseDetails.version
        val releaseNotes = releaseDetails.releaseNotes
        val releaseNotesUrl: Uri? = releaseDetails.releaseNotesUrl
        val mandatoryUpdate = releaseDetails.isMandatoryUpdate
        val map: Map<String, Any?> = mapOf(
            "versionName" to versionName,
            "versionCode" to versionCode,
            "releaseNotes" to releaseNotes,
            "releaseNotesUrl" to releaseNotesUrl?.path,
            "mandatoryUpdate" to mandatoryUpdate,
        )
        Log.i("AppCenter", "UPDATE_AVAILABLE")
        methodChannel.invokeMethod("update_result", map)
        return true
    }

    override fun onNoReleaseAvailable(activity: Activity?) {
        Log.i("AppCenter", "NO_UPDATE_AVAILABLE")
        methodChannel.invokeMethod("update_result", null)
    }

}

class AppCenterService(private val application: Application, flutterEngine: FlutterEngine) :
    MethodChannel.MethodCallHandler {

    private val channel: String = "AppCenter"
    private val methodChannel: MethodChannel

    init {
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
        methodChannel.setMethodCallHandler(this)
        Distribute.setListener(CustomDistributeListener(methodChannel))
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "start" -> {
                val id: String? = call.argument("id")
                val checkForUpdate: Boolean? = call.argument("checkForUpdate")
                if (id != null) {
                    appCenterService(id, checkForUpdate ?: true)
                } else {
                    throw java.lang.RuntimeException("Required ID for start AppCenter")
                }
            }
            "update_track" -> updateTrack(call.arguments())
            "check_update" -> checkUpdate()
            "update" -> update(call.arguments())
        }
    }

    private fun appCenterService(id: String, checkForUpdate: Boolean) {
        if (!checkForUpdate) {
            Log.i(channel, "UpdateTrack.DISABLE")
            Distribute.disableAutomaticCheckForUpdate()
        }
        if (!AppCenter.isConfigured()) {
            Log.i(channel, "START")
            AppCenter.start(
                application, id,
                Analytics::class.java,
                Crashes::class.java,
                Distribute::class.java
            )
        } else {
            Log.i(channel, "CONFIGURED")
        }
    }

    private fun updateTrack(args: Int) {
        when (args) {
            4 -> {
                Log.i(channel, "UpdateTrack.DEBUG_DISABLE")
                Distribute.setEnabledForDebuggableBuild(false)
            }
            3 -> {
                Log.i(channel, "UpdateTrack.DEBUG_ENABLE")
                Distribute.setEnabledForDebuggableBuild(true)
            }
            2 -> {
                Log.i(channel, "UpdateTrack.PRIVATE")
                Distribute.setUpdateTrack(UpdateTrack.PRIVATE)
            }
            1 -> {
                Log.i(channel, "UpdateTrack.PUBLIC")
                Distribute.setUpdateTrack(UpdateTrack.PUBLIC)
            }
        }
    }


    private fun checkUpdate() {
        Log.i(channel, "UpdateTrack.CHECK")
        Distribute.checkForUpdate()
    }

    private fun update(update: Boolean) {
        if (update) {
            Distribute.notifyUpdateAction(UpdateAction.UPDATE)
        } else {
            Distribute.notifyUpdateAction(UpdateAction.POSTPONE)
        }
    }

}