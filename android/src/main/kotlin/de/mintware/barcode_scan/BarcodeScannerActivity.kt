package de.mintware.barcode_scan

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.*
import android.widget.TextView
import com.google.zxing.BarcodeFormat
import com.google.zxing.Result
import me.dm7.barcodescanner.zxing.ZXingScannerView
import androidx.appcompat.app.AppCompatActivity

/**
 *   "title" : "扫一扫",
 *   "detail" : "请将条码/二维码放入框内",
 *   "flash_on" : "打开手电筒",
 *   "flash_off" : "关闭手电筒",
 *   "hand_input" : "手动输入",
 *   "show_hand_input" : 0 代表不显示手动输入, 1 代表显示手动输入
 */

var detailStr: String = "";

class BarcodeScannerActivity : AppCompatActivity(), ZXingScannerView.ResultHandler {

    init {
        title = ""
    }

    private lateinit var config: Protos.Configuration
    private var scannerView: ZXingScannerView? = null

    private lateinit var flashOnStr: String
    private lateinit var flashOffStr: String
    private lateinit var handInputStr: String
    private lateinit var handInputDialogTitleStr: String
    /**
     * 0 代表不显示手动输入
     * 1 代表显示手动输入
     */
    private lateinit var showHandInput: String


    companion object {
        const val EXTRA_CONFIG = "config"
        const val EXTRA_RESULT = "scan_result"
        const val EXTRA_ERROR_CODE = "error_code"

        private val formatMap: Map<Protos.BarcodeFormat, BarcodeFormat> = mapOf(
                Protos.BarcodeFormat.aztec to BarcodeFormat.AZTEC,
                Protos.BarcodeFormat.code39 to BarcodeFormat.CODE_39,
                Protos.BarcodeFormat.code93 to BarcodeFormat.CODE_93,
                Protos.BarcodeFormat.code128 to BarcodeFormat.CODE_128,
                Protos.BarcodeFormat.dataMatrix to BarcodeFormat.DATA_MATRIX,
                Protos.BarcodeFormat.ean8 to BarcodeFormat.EAN_8,
                Protos.BarcodeFormat.ean13 to BarcodeFormat.EAN_13,
                Protos.BarcodeFormat.interleaved2of5 to BarcodeFormat.ITF,
                Protos.BarcodeFormat.pdf417 to BarcodeFormat.PDF_417,
                Protos.BarcodeFormat.qr to BarcodeFormat.QR_CODE,
                Protos.BarcodeFormat.upce to BarcodeFormat.UPC_E
        )

    }

    // region Activity lifecycle
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        config = Protos.Configuration.parseFrom(intent.extras!!.getByteArray(EXTRA_CONFIG))
        title = config.stringsMap["title"] ?: getString(R.string.scan)
        detailStr = config.stringsMap["detail"] ?: getString(R.string.hint)
        flashOnStr = config.stringsMap["flash_on"] ?: getString(R.string.open_flashlight)
        flashOffStr = config.stringsMap["flash_off"] ?: getString(R.string.close_flashlight)
        handInputStr = config.stringsMap["hand_input"] ?: getString(R.string.manual_input_txt)
        handInputDialogTitleStr = config.stringsMap["hand_input_dialog_title"] ?: getString(R.string.manual_input_txt)
        showHandInput = config.stringsMap["show_hand_input"] ?: "0"

        setContentView(R.layout.activity_barcode_scanner)
    }

    private fun setupScannerView() {
        if (scannerView != null) {
            return
        }
        findViewById<TextView>(R.id.tv_title).setText(title)
        val tVFlashLight = findViewById<TextView>(R.id.tv_flashlight)
        tVFlashLight.setText(flashOnStr);
        findViewById<View>(R.id.back).setOnClickListener { onBackPressed() }

        findViewById<TextView>(R.id.hand_input_txt).setText(handInputStr)
        findViewById<View>(R.id.hand_input).visibility = if (showHandInput == "1") View.VISIBLE else View.GONE
        findViewById<View>(R.id.hand_input).setOnClickListener {
            showInputDialog()
        }

        findViewById<View>(R.id.flashlight)
                .setOnClickListener {
            scannerView?.toggleFlash()
            tVFlashLight.setText(if (scannerView?.flash == true) flashOffStr else flashOnStr)
        }
        scannerView = findViewById(R.id.scannerView)
        scannerView?.apply {
            setAutoFocus(config.android.useAutoFocus)
            val restrictedFormats = mapRestrictedBarcodeTypes()
            if (restrictedFormats.isNotEmpty()) {
                setFormats(restrictedFormats)
            }

            // this parameter will make your HUAWEI phone works great!
            setAspectTolerance(config.android.aspectTolerance.toFloat())
            if (config.autoEnableFlash) {
                flash = config.autoEnableFlash
                invalidateOptionsMenu()
            }
        }
    }

    override fun onPause() {
        super.onPause()
        scannerView?.stopCamera()
    }

    override fun onResume() {
        super.onResume()
        setupScannerView()
        scannerView?.setResultHandler(this)
        if (config.useCamera > -1) {
            scannerView?.startCamera(config.useCamera)
        } else {
            scannerView?.startCamera()
        }
    }
    // endregion

    override fun handleResult(result: Result?) {
        val intent = Intent()

        val builder = Protos.ScanResult.newBuilder()
        if (result == null) {

            builder.let {
                it.format = Protos.BarcodeFormat.unknown
                it.rawContent = "No data was scanned"
                it.type = Protos.ResultType.Error
            }
        } else {

            val format = (formatMap.filterValues { it == result.barcodeFormat }.keys.firstOrNull()
                    ?: Protos.BarcodeFormat.unknown)

            var formatNote = ""
            if (format == Protos.BarcodeFormat.unknown) {
                formatNote = result.barcodeFormat.toString()
            }

            builder.let {
                it.format = format
                it.formatNote = formatNote
                it.rawContent = result.text
                it.type = Protos.ResultType.Barcode
            }
        }
        val res = builder.build()
        intent.putExtra(EXTRA_RESULT, res.toByteArray())
        setResult(RESULT_OK, intent)
        finish()
    }

    private fun mapRestrictedBarcodeTypes(): List<BarcodeFormat> {
        val types: MutableList<BarcodeFormat> = mutableListOf()

        this.config.restrictFormatList.filterNotNull().forEach {
            if (!formatMap.containsKey(it)) {
                print("Unrecognized")
                return@forEach
            }

            types.add(formatMap.getValue(it))
        }

        return types
    }

    private fun showInputDialog() {
        var fragment = ManualInputDialogFragment.newInstance(title = handInputDialogTitleStr)
        fragment.listener = object : InputTextListener {
            override fun onClickOk(txt: String) {
                val builder = Protos.ScanResult.newBuilder()
                builder.let {
                    it.format = Protos.BarcodeFormat.unknown
                    it.rawContent = txt
                    it.type = Protos.ResultType.HandInput
                }

                val res = builder.build()
                intent.putExtra(EXTRA_RESULT, res.toByteArray())
                setResult(RESULT_OK, intent)
                finish()
            }
        }

        fragment.show(supportFragmentManager, "ManualInputDialog")
    }
}
