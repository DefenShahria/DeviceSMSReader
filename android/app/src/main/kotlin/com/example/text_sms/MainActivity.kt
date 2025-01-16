package com.example.text_sms

import android.Manifest
import android.content.pm.PackageManager
import android.provider.Telephony
import android.widget.Toast
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private lateinit var methodChannelResult: MethodChannel.Result
    private val smsList = mutableListOf<String>()
    private val REQUEST_READ_SMS_PERMISSION = 1

    private fun checkAndRequestPermission() {
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_SMS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            ActivityCompat.requestPermissions(
                this,
                arrayOf(Manifest.permission.READ_SMS),
                REQUEST_READ_SMS_PERMISSION
            )
        } else {
            readSms()
        }
    }

    private fun readSms() {
        if (ContextCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_SMS
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            val cursor = contentResolver.query(
                Telephony.Sms.CONTENT_URI,
                null,
                null,
                null,
                null
            )

            smsList.clear()
            if (cursor != null && cursor.moveToFirst()) {
                do {
                    val address = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS))
                    val body = cursor.getString(cursor.getColumnIndexOrThrow(Telephony.Sms.BODY))
                    smsList.add("Sender: $address\nMessage: $body")
                } while (cursor.moveToNext())
            }
            cursor?.close()

            methodChannelResult.success(smsList)
        } else {
            methodChannelResult.error("PERMISSION_DENIED", "SMS permission not granted", null)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_READ_SMS_PERMISSION) {
            if ((grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED)) {
                readSms()
            } else {
                methodChannelResult.error("PERMISSION_DENIED", "Permission denied by user", null)
                Toast.makeText(this, "Permission not granted", Toast.LENGTH_LONG).show()
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "smsPlatform"
        ).setMethodCallHandler { call, result ->
            methodChannelResult = result
            when (call.method) {
                "readAllSms" -> checkAndRequestPermission()
                else -> result.notImplemented()
            }
        }
    }
}
