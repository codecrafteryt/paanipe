import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_messages.dart';

Future<void> callPhone(String phone) async {
  if (!await launchUrl(Uri(scheme: 'tel', path: phone))) showError('Could not open the dialer');
}

Future<void> openInMaps(double lat, double lng) async {
  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) showError('Could not open maps');
}

Future<File?> pickGalleryImage({double maxWidth = 1024}) async {
  final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: maxWidth, imageQuality: 75);
  return x == null ? null : File(x.path);
}
