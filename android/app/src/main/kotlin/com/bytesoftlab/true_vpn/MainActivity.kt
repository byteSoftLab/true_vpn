package com.bytesoftlab.true_vpn

import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.bytesoftlab.true_vpn/proxy"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setProxy") {
                val host = call.argument<String>("host")
                val port = call.argument<String>("port")
                
                if (host != null && port != null) {
                    val success = MyProxyService.setProxy(host, port, contentResolver)
                    result.success(success)
                } else {
                    result.error("INVALID_ARGUMENT", "Host or port is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
