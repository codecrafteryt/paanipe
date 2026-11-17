import 'package:flutter/material.dart';
import 'package:get/get.dart';

void _snack(String title, String message, Color color) {
  Get.closeCurrentSnackbar();
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: color,
    colorText: Colors.white,
    margin: const EdgeInsets.all(12),
  );
}

void showError(String message) => _snack('Oops', message, const Color(0xFFDC2626));

void showOk(String message) => _snack('Done', message, const Color(0xFF16A34A));

Future<bool> confirmDialog(String title, String message, {String ok = 'Yes'}) async {
  final result = await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: const Text('No')),
        FilledButton(onPressed: () => Get.back(result: true), child: Text(ok)),
      ],
    ),
  );
  return result == true;
}

/// Single text-field dialog. Returns the trimmed value, or null if cancelled.
Future<String?> inputDialog(String title, {String initial = ''}) {
  final controller = TextEditingController(text: initial);
  return Get.dialog<String>(
    AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Get.back(result: controller.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}
