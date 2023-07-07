package com.example.localization

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.Locale


class MainActivity : FlutterActivity() {
    private val TAG = "MainActivity"
    private val CHANNEL = "shokal"
    private lateinit var sharedPreference: SharedPreferences

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        sharedPreference = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, CHANNEL
        ).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            if (call.method == "messageFunction") {
                startActivity(Intent(this@MainActivity, NativeActivity::class.java))
                result.success(null)
            } else if (call.method == "languageFunction") {
                val languageCode = call.argument<String>("languageCode")
                setLanguage(languageCode)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }

    }

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR1)
    private fun setLanguage(languageCode: String?) {
        val locale = languageCode?.let { Locale(it) }
//        var languageCode = sharedPreference.getString(R.string.language_preference.toString(), "en")
        Log.d(TAG, "setLanguage: $languageCode")
        if (locale != null) {
            Locale.setDefault(locale)
        }
        val config = resources.configuration
        config.setLocale(locale)
        createConfigurationContext(config)

    }

}
