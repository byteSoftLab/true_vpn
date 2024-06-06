package com.bytesoftlab.true_vpn

import android.content.ContentResolver
import android.provider.Settings

object MyProxyService {
    fun setProxy(host: String, port: String, contentResolver: ContentResolver): Boolean {
        return try {
            Settings.Global.putString(contentResolver, Settings.Global.HTTP_PROXY, "$host:$port")
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }
}
