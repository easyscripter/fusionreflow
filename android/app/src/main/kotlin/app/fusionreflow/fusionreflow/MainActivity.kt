package app.fusionreflow.fusionreflow

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Канал `app.fusionreflow/documents`: системный выбор файла (SAF) и
 * дескриптор выбранного файла для Rust. Без копирования файла в кэш.
 */
class MainActivity : FlutterActivity() {
    private var pendingPick: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(::onCall)
    }

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "pick" -> pick(result)
            "openFd" -> openFd(call.argument<String>("uri"), result)
            else -> result.notImplemented()
        }
    }

    private fun pick(result: MethodChannel.Result) {
        if (pendingPick != null) {
            result.error("busy", "A file picker is already open", null)
            return
        }
        pendingPick = result
        // У FB2 на Android часто нет MIME-типа, поэтому */*.
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT)
            .addCategory(Intent.CATEGORY_OPENABLE)
            .setType("*/*")
        startActivityForResult(intent, REQUEST_PICK)
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQUEST_PICK) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val result = pendingPick ?: return
        pendingPick = null
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            result.success(null)
            return
        }
        try {
            result.success(describe(uri))
        } catch (e: Exception) {
            result.error("pick_failed", e.message, null)
        }
    }

    private fun describe(uri: Uri): Map<String, Any?> {
        var name: String? = null
        var size: Long? = null
        contentResolver.query(uri, null, null, null, null)?.use { cursor ->
            if (cursor.moveToFirst()) {
                val nameIndex = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                val sizeIndex = cursor.getColumnIndex(OpenableColumns.SIZE)
                if (nameIndex >= 0) name = cursor.getString(nameIndex)
                if (sizeIndex >= 0 && !cursor.isNull(sizeIndex)) size = cursor.getLong(sizeIndex)
            }
        }
        return mapOf(
            "uri" to uri.toString(),
            "name" to (name ?: uri.lastPathSegment ?: ""),
            "size" to size,
        )
    }

    /** Новый дескриптор: владение переходит Dart и дальше мосту (он закроет). */
    private fun openFd(uri: String?, result: MethodChannel.Result) {
        if (uri == null) {
            result.error("bad_args", "uri is required", null)
            return
        }
        try {
            val fd = contentResolver.openFileDescriptor(Uri.parse(uri), "r")?.detachFd()
            if (fd == null) {
                result.error("no_file", "Cannot open $uri", null)
            } else {
                result.success(fd)
            }
        } catch (e: Exception) {
            result.error("no_access", e.message, null)
        }
    }

    private companion object {
        const val CHANNEL = "app.fusionreflow/documents"
        const val REQUEST_PICK = 4101
    }
}
