package app.fusionreflow.fusionreflow

/**
 * Контракт канала выбора файла. Те же значения лежат в Dart
 * (`lib/data/services/document_channel.dart`); `document_channel_test` следит,
 * чтобы копии совпадали.
 */
object DocumentChannel {
    const val CHANNEL = "app.fusionreflow/documents"

    const val METHOD_PICK = "pick"
    const val METHOD_OPEN_FD = "openFd"

    const val ARG_URI = "uri"
    const val KEY_URI = "uri"
    const val KEY_NAME = "name"
    const val KEY_SIZE = "size"

    const val ERROR_BUSY = "busy"
    const val ERROR_PICK_FAILED = "pick_failed"
    const val ERROR_NO_FILE = "no_file"
    const val ERROR_NO_ACCESS = "no_access"
    const val ERROR_BAD_ARGS = "bad_args"
}
