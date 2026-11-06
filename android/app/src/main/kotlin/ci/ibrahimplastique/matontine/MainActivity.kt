// Ported from IP Caisse (MainActivity.kt), translated to English.
package ci.ibrahimplastique.matontine

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Saves a backup through Android's file picker.
 *
 * Android may kill the app while the picker is open, mostly on a small phone.
 * The content therefore waits in a file and its paths in the preferences: the
 * recreated activity receives the result and finishes the copy on its own, and
 * the marker is written only once the copy was read back and checked.
 */
class MainActivity : FlutterActivity() {
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "restart") {
                    restart()
                    return@setMethodCallHandler
                }
                if (call.method != "save") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                preferences().edit()
                    .putString(KEY_SOURCE, call.argument<String>("source"))
                    .putString(KEY_MARKER, call.argument<String>("marker"))
                    .commit()
                pendingResult = result
                startActivityForResult(
                    Intent(Intent.ACTION_CREATE_DOCUMENT)
                        .addCategory(Intent.CATEGORY_OPENABLE)
                        .setType("application/octet-stream")
                        .putExtra(Intent.EXTRA_TITLE, call.argument<String>("name")),
                    REQUEST_SAVE,
                )
            }
    }

    /** Kills the process to release the database, then relaunches the app. */
    private fun restart() {
        val component = packageManager.getLaunchIntentForPackage(packageName)!!.component
        startActivity(Intent.makeRestartActivityTask(component))
        Runtime.getRuntime().exit(0)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != REQUEST_SAVE) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }
        val prefs = preferences()
        val source = prefs.getString(KEY_SOURCE, null)?.let(::File)
        val marker = prefs.getString(KEY_MARKER, null)?.let(::File)
        val destination = data?.data
        prefs.edit().clear().commit()

        if (resultCode != Activity.RESULT_OK || destination == null ||
            source == null || marker == null
        ) {
            source?.delete()
            finish(success = false, error = null)
            return
        }
        Thread {
            try {
                copyAndCheck(source, destination)
                marker.writeText(
                    SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss", Locale.ROOT).format(Date()),
                )
                source.delete()
                finish(success = true, error = null)
            } catch (error: Exception) {
                // An incomplete file must never pass for a backup.
                try {
                    DocumentsContract.deleteDocument(contentResolver, destination)
                } catch (_: Exception) {
                }
                source.delete()
                finish(success = false, error = error.message ?: "Copy failed")
            }
        }.start()
    }

    private fun copyAndCheck(source: File, destination: Uri) {
        val output = contentResolver.openOutputStream(destination, "wt")
            ?: error("Destination unavailable")
        output.use { stream ->
            source.inputStream().use { it.copyTo(stream) }
            stream.flush()
            (stream as? FileOutputStream)?.fd?.sync()
        }
        val input = contentResolver.openInputStream(destination)
            ?: error("Cannot read back")
        val readBack = input.use { stream ->
            val buffer = ByteArray(64 * 1024)
            var total = 0L
            while (true) {
                val read = stream.read(buffer)
                if (read < 0) break
                total += read
            }
            total
        }
        check(readBack == source.length()) { "Incomplete copy" }
    }

    /** Without a pending result, the app was recreated in between. */
    private fun finish(success: Boolean, error: String?) {
        runOnUiThread {
            val result = pendingResult
            pendingResult = null
            if (error != null) {
                result?.error("FAILED", error, null)
            } else {
                result?.success(success)
            }
        }
    }

    private fun preferences() = getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE)

    private companion object {
        const val CHANNEL = "matontine/backup"
        const val PREFERENCES = "backup_in_progress"
        const val KEY_SOURCE = "source"
        const val KEY_MARKER = "marker"
        const val REQUEST_SAVE = 4207
    }
}
