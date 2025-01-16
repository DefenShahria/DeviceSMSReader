package com.example.text_sms

import android.Manifest
import android.provider.Telephony
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private lateinit var methodChannelResult: MethodChannel.Result
    private val list = mutableListOf<String>()

    private val requestPermissionLauncher =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { isGranted ->
            if (isGranted) {
                readSms()
            } else {
                Toast.makeText(this, "Permission not granted", Toast.LENGTH_LONG).show()
            }
        }

    private fun readSms() {
        val cursor = contentResolver.query(
            Telephony.Sms.CONTENT_URI,
            null,
            null,
            null,
            null
        )
        if (cursor != null && cursor.moveToFirst()) {
            do {
                val address =
                    cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS))
                val body = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.BODY))
                list.add("Sender: $address\nMessage: $body")
            } while (cursor.moveToNext())
        }
        cursor?.close()
        methodChannelResult.success(list.toString())
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "smsPlatform"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "readAllSms" -> {
                    readSms(result)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun readSms(result: MethodChannel.Result) {
        val cursor = contentResolver.query(
            Telephony.Sms.CONTENT_URI,
            null,
            null,
            null,
            null
        )
        val list = mutableListOf<String>()
        if (cursor != null && cursor.moveToFirst()) {
            do {
                val address =
                    cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS))
                val body = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.BODY))
                list.add("Sender: $address\nMessage: $body")
            } while (cursor.moveToNext())
        }
        cursor?.close()
        result.success(list.toString())  // Return the list as the result
    }

}
