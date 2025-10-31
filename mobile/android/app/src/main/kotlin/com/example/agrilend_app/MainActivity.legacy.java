package com.example.agrilend_app;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

// Hedera SDK imports
import com.hedera.hashgraph.sdk.*;
import java.util.Base64; // Nécessite Android API Level 26 pour Base64.getDecoder()

/**
 * Activité principale pour l'application Flutter, gérant les appels natifs pour les opérations Hedera.
 */
public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.agrilend.app/hedera"; // Doit correspondre au canal dans le code Dart

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    if (call.method.equals("signHederaTransaction")) {
                        String unsignedTxBase64 = call.argument("unsignedTxBase64");
                        String privateKeyString = call.argument("privateKey");

                        if (unsignedTxBase64 == null || privateKeyString == null) {
                            result.error("ARGUMENT_ERROR", "Transaction non signée ou clé privée manquante.", null);
                            return;
                        }

                        try {
                            // --- Logique Hedera SDK pour Android ---
                            byte[] unsignedTxBytes = Base64.getDecoder().decode(unsignedTxBase64);

                            // Désérialiser la transaction non signée
                            Transaction<?> unsignedTransaction = Transaction.fromBytes(unsignedTxBytes);

                            PrivateKey privateKey = PrivateKey.fromString(privateKeyString);
                            Transaction<?> signedTransaction = unsignedTransaction.sign(privateKey);

                            byte[] signedTxBytes = signedTransaction.toBytes();
                            String signedTxBase64 = Base64.getEncoder().encodeToString(signedTxBytes);
                            // --- Fin logique Hedera SDK ---

                            result.success(signedTxBase64);
                        } catch (Exception e) {
                            result.error("HEDERA_SIGNING_ERROR", e.getMessage(), e.toString());
                        }
                    } else {
                        result.notImplemented();
                    }
                });
    }
}
