package de.mintware.barcode_scan

import android.app.Activity
import android.content.Intent
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.ActivityResultListener

class ScanResultHandler(private val result: MethodChannel.Result) : ActivityResultListener {

    companion object {
        const val RESULT_HAND_INPUT = 0x999
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {

        var scanResult = ByteArray(0)
        when (resultCode) {
            Activity.RESULT_OK -> {
                scanResult = data?.getByteArrayExtra(BarcodeScannerActivity.EXTRA_RESULT)
                        ?: scanResult
            }
            Activity.RESULT_CANCELED -> {
                scanResult = Protos.ScanResult.newBuilder()
                        .setType(Protos.ResultType.Cancelled)
                        .build()
                        .toByteArray()
            }
            RESULT_HAND_INPUT -> {
                scanResult = Protos.ScanResult.newBuilder()
                        .setType(Protos.ResultType.HandInput)
                        .build()
                        .toByteArray()
            }
            else -> {
                val errorCode = data?.getStringExtra(BarcodeScannerActivity.EXTRA_ERROR_CODE)
                scanResult = Protos.ScanResult.newBuilder()
                        .setType(Protos.ResultType.Error)
                        .setFormat(Protos.BarcodeFormat.unknown)
                        .setRawContent(errorCode)
                        .build()
                        .toByteArray()
            }
        }
        result.success(scanResult)

        return true
    }
}