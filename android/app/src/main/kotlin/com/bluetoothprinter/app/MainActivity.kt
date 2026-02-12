package com.bluetoothprinter.app

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Workaround for emulator "Width is zero": force a second layout pass
        // so the Flutter view gets real dimensions from the window.
        window.decorView.post {
            window.decorView.requestLayout()
        }
    }
}
