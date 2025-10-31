package com.example.agrilend_app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// Hedera SDK imports
import com.hedera.hashgraph.sdk.*
import java.util.Base64 // Nécessite Android API Level 26 pour Base64.getDecoder()

/**
 * Activité principale pour l'application Flutter, gérant les appels natifs pour les opérations Hedera.
 */
class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.agrilend.app/hedera" // Doit correspondre au canal dans le code Dart

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "signHederaTransaction") {
                val unsignedTxBase64 = call.argument<String>("unsignedTxBase64")
                val privateKeyString = call.argument<String>("privateKey")

                if (unsignedTxBase64 == null || privateKeyString == null) {
                    result.error("ARGUMENT_ERROR", "Transaction non signée ou clé privée manquante.", null)
                    return@setMethodCallHandler
                }

                try {
                    // --- Logique Hedera SDK pour Android ---
                    val unsignedTxBytes = Base64.getDecoder().decode(unsignedTxBase64)

                    // Désérialiser la transaction non signée
                    val unsignedTransaction = Transaction.fromBytes(unsignedTxBytes)

                    val privateKey = PrivateKey.fromString(privateKeyString)
                    val signedTransaction = unsignedTransaction.sign(privateKey)

                    val signedTxBytes = signedTransaction.toBytes()
                    val signedTxBase64 = Base64.getEncoder().encodeToString(signedTxBytes)
                    // --- Fin logique Hedera SDK ---

                    result.success(signedTxBase64)
                } catch (e: Exception) {
                    result.error("HEDERA_SIGNING_ERROR", e.message, e.toString())
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
