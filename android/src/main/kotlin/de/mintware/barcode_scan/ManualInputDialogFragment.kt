package de.mintware.barcode_scan

import android.content.DialogInterface
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.EditText
import android.widget.TextView
import androidx.fragment.app.DialogFragment
private const val ARG_TITLE = "ARG_TITLE"

interface InputTextListener {
    fun onClickOk(txt: String)
}

class ManualInputDialogFragment : DialogFragment() {
    private var title: String = ""
    private lateinit var contentEt: EditText


    var listener: InputTextListener? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        arguments?.let {
            title = it.getString(ARG_TITLE, "")
        }

        if (title.isEmpty()) {
            title = "手动输入"
        }
    }

    override fun onCreateView(
            inflater: LayoutInflater, container: ViewGroup?,
            savedInstanceState: Bundle?
    ): View? {
        return inflater.inflate(R.layout.fragment_manual_input_dialog, container, false)
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        view!!.findViewById<TextView>(R.id.title).setText(title)
        contentEt = view!!.findViewById<EditText>(R.id.content_et)

        val cancelBtn = view!!.findViewById<TextView>(R.id.cancel_btn)
        cancelBtn.setOnClickListener {
            dismiss()
        }

        view!!.findViewById<TextView>(R.id.ok_btn).setOnClickListener {
            var context = contentEt.text?.toString()?.trim()
            if (!context.isNullOrEmpty()) {
                listener?.onClickOk(context)
                dismiss()
            }
        }
    }

    companion object {
        @JvmStatic
        fun newInstance(title: String) =
                ManualInputDialogFragment().apply {
                    arguments = Bundle().apply {
                        putString(ARG_TITLE, title)
                    }
                }
    }
}