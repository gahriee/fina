package com.example.fina

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.fina.export"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "shareCsv") {
                val csvContent = call.argument<String>("csvContent")
                val filename = call.argument<String>("filename")
                if (csvContent != null && filename != null) {
                    shareCsv(csvContent, filename)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENTS", "Missing arguments", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun shareCsv(content: String, filename: String) {
        val file = File(cacheDir, filename)
        file.writeText(content)

        val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = "text/csv"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }

        startActivity(Intent.createChooser(intent, "Share CSV"))
    }
}
