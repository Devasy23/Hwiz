import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

/// Document Picker Service - Handles image and PDF file selection
class DocumentPickerService {
  final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress for API efficiency
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  /// Take a photo with camera
  Future<File?> takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  /// Pick a PDF file
  Future<File?> pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick PDF: $e');
    }
  }

  /// Pick any supported document (image or PDF)
  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick document: $e');
    }
  }

  /// Check if file is an image
  bool isImage(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['jpg', 'jpeg', 'png'].contains(extension);
  }

  /// Check if file is a PDF
  bool isPDF(File file) {
    return file.path.toLowerCase().endsWith('.pdf');
  }

  /// Get file size in MB
  Future<double> getFileSizeMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  /// Validate file (size and type)
  Future<bool> validateFile(File file, {double maxSizeMB = 10}) async {
    // Check file size
    final sizeMB = await getFileSizeMB(file);
    if (sizeMB > maxSizeMB) {
      throw Exception('File size exceeds $maxSizeMB MB limit');
    }

    // Check file type
    if (!isImage(file) && !isPDF(file)) {
      throw Exception('Unsupported file type. Please select an image or PDF.');
    }

    return true;
  }
}
