import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // Request storage permissions necessary for path_provider
  static Future<bool> requestStoragePermission(BuildContext context) async {
    try {
      // Check current permission status
      if (Platform.isAndroid) {
        // For Android 13+, we need to check and request more specific permissions
        try {
          if (await Permission.storage.isGranted) {
            return true;
          }

          // Request permission
          final status = await Permission.storage.request();

          // Handle the result
          if (status.isGranted) {
            return true;
          } else if (status.isPermanentlyDenied) {
            // Only show dialog if we can safely interact with the plugin
            if (context.mounted) {
              _showSettingsDialog(context);
            }
            return false;
          }
          return false;
        } on PlatformException catch (e) {
          print('Permission plugin error: ${e.message}');
          // If plugin is missing, assume permission is granted to avoid blocking the app
          return true;
        }
      }

      // On iOS, permissions are handled differently and are generally
      // requested at runtime when needed
      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      // In case of any error, return true to let the app continue
      return true;
    }
  }

  // Show a dialog to direct the user to app settings when permission is permanently denied
  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text(
            'This app needs storage permission to save data locally. '
            'Please grant this permission in app settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                try {
                  openAppSettings();
                } catch (e) {
                  print('Error opening app settings: $e');
                }
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
