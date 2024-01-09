import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlurWidget extends StatelessWidget {
  final Widget child;

  BlurWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      // Fetch the value of 'isDemo' from shared preferences
      future: _getBlurPreference(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the value is being fetched, you can show a loading indicator or fallback widget
          // return CircularProgressIndicator();

          return child;
        } else if (snapshot.hasError || !snapshot.hasData) {
          // Handle errors if any
          // return Text('Error: ${snapshot.error}');
          // print('Error: ${snapshot.error}');

          return child;
        } else {
          // Check the value and apply blur if necessary
          bool applyBlur = snapshot.data ?? false; // Default value if SharedPreferences is empty

          if (applyBlur) {
            return ClipRect(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(tileMode: TileMode.decal, sigmaX: 3, sigmaY: 2),
                child: child,
              ),
            );
          } else {
            return child;
          }
        }
      },
    );
  }

  Future<bool> _getBlurPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Replace 'isDemo' with the actual key used to store the preference in SharedPreferences
    return prefs.getBool('isDemo') ?? false; // Default value if the preference is not found
  }
}
