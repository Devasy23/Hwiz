import 'package:google_generative_ai/google_generative_ai.dart';

/// An interface to wrap the final [GenerativeModel] class, making it mockable.
abstract class GenerativeModelWrapper {
  Future<String?> generateContentText(
    Iterable<Content> content, {
    GenerationConfig? generationConfig,
    List<SafetySetting>? safetySettings,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  });
}

/// The concrete implementation of [GenerativeModelWrapper].
///
/// This class holds a real [GenerativeModel] instance and delegates calls to it.
class GenerativeModelWrapperImpl implements GenerativeModelWrapper {
  final GenerativeModel _model;

  GenerativeModelWrapperImpl(this._model);

  @override
  Future<String?> generateContentText(
    Iterable<Content> content, {
    GenerationConfig? generationConfig,
    List<SafetySetting>? safetySettings,
    List<Tool>? tools,
    ToolConfig? toolConfig,
  }) async {
    final response = await _model.generateContent(
      content,
      generationConfig: generationConfig,
      safetySettings: safetySettings,
      tools: tools,
      toolConfig: toolConfig,
    );
    return response.text;
  }
}
