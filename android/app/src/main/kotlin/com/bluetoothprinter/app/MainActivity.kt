package com.bluetoothprinter.app

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Workaround for black screen when launching from IDE/emulator: the Flutter
        // view sometimes gets zero size on the first frame. Force extra layout passes
        // so the view receives real dimensions before the first paint.
        window.decorView.post { window.decorView.requestLayout() }
        Handler(Looper.getMainLooper()).postDelayed({
            window.decorView.requestLayout()
        }, 150)
    }
}
