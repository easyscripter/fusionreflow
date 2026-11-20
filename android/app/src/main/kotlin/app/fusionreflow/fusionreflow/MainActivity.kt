package app.fusionreflow.fusionreflow

import android.net.Uri
import android.provider.OpenableColumns
import androidx.activity.result.contract.ActivityResultContracts
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Канал [DocumentChannel.CHANNEL]: системный выбор файла (SAF) и дескриптор
 * выбранного файла для Rust. Без копирования файла в кэш.
 *
 * Базовый класс — [FlutterFragmentActivity] (это `ComponentActivity`), чтобы
 * пользоваться Activity Result API вместо устаревших
 * `startActivityForResult` / `onActivityResult`.
 */
class MainActivity : FlutterFragmentActivity() {
    private var pendingPick: MethodChannel.Result? = null

    // У FB2 на Android часто нет MIME-типа, поэтому выбор открыт для любых файлов.
    private val openDocument =
        registerForActivityResult(ActivityResultContracts.OpenDocument()) { uri ->
            val result = pendingPick ?: return@registerForActivityResult
            pendingPick = null
            if (uri == null) {
                result.success(null) // человек закрыл выбор
                return@registerForActivityResult
            }
            try {
                result.success(describe(uri))
            } catch (e: Exception) {
                result.error(DocumentChannel.ERROR_PICK_FAILED, e.message, null)
            }
        }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DocumentChannel.CHANNEL)
            .setMethodCallHandler(::onCall)
    }

    private fun onCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            DocumentChannel.METHOD_PICK -> pick(result)
            DocumentChannel.METHOD_OPEN_FD -> openFd(call.argument<String>(DocumentChannel.ARG_URI), result)
            else -> result.notImplemented()
        }
    }

    private fun pick(result: MethodChannel.Result) {
        if (pendingPick != null) {
            result.error(DocumentChannel.ERROR_BUSY, "A file picker is already open", null)
            return
        }
        pendingPick = result
        try {
            openDocument.launch(arrayOf("*/*"))
        } catch (e: Exception) {
            // Нет приложения для выбора файла: иначе все следующие pick отвечали бы busy.
            pendingPick = null
            result.error(DocumentChannel.ERROR_PICK_FAILED, e.message, null)
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
            DocumentChannel.KEY_URI to uri.toString(),
            DocumentChannel.KEY_NAME to (name ?: uri.lastPathSegment ?: ""),
            DocumentChannel.KEY_SIZE to size,
        )
    }

    /** Новый дескриптор: владение переходит Dart и дальше мосту (он закроет). */
    private fun openFd(uri: String?, result: MethodChannel.Result) {
        if (uri == null) {
            result.error(DocumentChannel.ERROR_BAD_ARGS, "uri is required", null)
            return
        }
        try {
            val fd = contentResolver.openFileDescriptor(Uri.parse(uri), "r")?.detachFd()
            if (fd == null) {
                result.error(DocumentChannel.ERROR_NO_FILE, "Cannot open $uri", null)
            } else {
                result.success(fd)
            }
        } catch (e: Exception) {
            result.error(DocumentChannel.ERROR_NO_ACCESS, e.message, null)
        }
    }
}
