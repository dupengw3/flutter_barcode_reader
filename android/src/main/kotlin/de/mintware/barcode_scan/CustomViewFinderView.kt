package de.mintware.barcode_scan

import android.animation.ValueAnimator
import android.animation.ValueAnimator.INFINITE
import android.animation.ValueAnimator.RESTART
import android.content.Context
import android.content.res.Resources
import android.graphics.*
import android.os.Build
import android.util.Log
import android.view.View
import android.view.animation.AccelerateInterpolator
import android.view.animation.LinearInterpolator
import androidx.annotation.RequiresApi
import me.dm7.barcodescanner.core.ViewFinderView
import kotlin.math.roundToInt

/**
 * Created on 2020/7/21.
 * 包名:de.mintware.barcode_scan
 * @author 李舰舸 <jiange.li@56qq.com>
 */
class CustomViewFinderView(context: Context) : ViewFinderView(context) {

    private var currentAnimValue: Float = 0f
    private var laser : Bitmap
    private val animator: ValueAnimator

    init {
        setLayerType(LAYER_TYPE_SOFTWARE, null);
        setBorderColor(Color.parseColor("#3EBADE"))
        setSquareViewFinder(true)
        setBorderLineLength((Resources.getSystem().displayMetrics.density * 15).toInt())
        setLaserEnabled(true)
        laser = BitmapFactory.decodeResource(resources, R.drawable.laser)

        animator = ValueAnimator.ofFloat(0f, 1f)
        animator.addUpdateListener { animation ->
            currentAnimValue = animation.animatedValue as Float
            invalidate()
        }
        animator.duration = 2000
        animator.interpolator = LinearInterpolator()
        animator.repeatMode = RESTART
        animator.repeatCount = INFINITE
        animator.startDelay = 500
        animator.start()
    }

    override fun drawLaser(canvas: Canvas?) {
        val total = framingRect.height() + laser.height
        val percent = (laser.height.toFloat() / total)
        var laserheight = laser.height.toFloat()
        if (currentAnimValue < percent || currentAnimValue > (1 - percent)) {
            val tempValue = if (currentAnimValue > 0.5) 1 - currentAnimValue else currentAnimValue
            laserheight *= tempValue / percent
        }
        mLaserPaint.xfermode = PorterDuffXfermode(PorterDuff.Mode.SRC_OVER)
        val rect = Rect()
        rect.top = (framingRect.top - laserheight + currentAnimValue * (framingRect.height() + laserheight)).toInt()
        rect.left = framingRect.left
        rect.right = framingRect.right
        rect.bottom = (framingRect.top + currentAnimValue * (framingRect.height() + laserheight)).toInt()
        canvas?.drawBitmap(laser, null, rect, mLaserPaint)
    }

    override fun onWindowVisibilityChanged(visibility: Int) {
        if (visibility == View.GONE) {
            animator.removeAllListeners()
            animator.cancel()
        }
        super.onWindowVisibilityChanged(visibility)
    }
}