import 'package:flutter/foundation.dart';
import 'ollama_engine.dart';
import 'llama_cpp_engine.dart';

/// Token-by-token streaming callback.
typedef TokenCallback = void Function(String token);

/// Unified interface for all local inference backends.
/// - Android/Desktop → OllamaEngine (local Ollama server)
/// - Desktop fallback → LlamaCppEngineImpl (llama.cpp via dart:ffi)
/// - Dev/Test        → MockEngine (instant canned responses)
abstract class InferenceEngine {
  bool get isReady;
  String get backendLabel;

  /// Load the model file from [modelPath].
  Future<void> loadModel(String modelPath);

  /// Generate a response, streaming tokens via [onToken].
  Future<String> generate({
    required String prompt,
    int maxTokens = 512,
    double temperature = 0.7,
    TokenCallback? onToken,
  });

  /// Release native resources.
  Future<void> dispose();
}

class ModelLoadException implements Exception {
  ModelLoadException(this.message);
  final String message;
  @override
  String toString() => 'ModelLoadException: $message';
}

/// Returns the correct engine for the current platform.
/// Tries Ollama first (works on any platform), falls back to platform-specific.
InferenceEngine createPlatformEngine() {
  return OllamaEngine();
}
