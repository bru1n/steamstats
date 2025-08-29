import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void displayMessageToUser(String message, BuildContext context, {int duration = 3000}) {
  SchedulerBinding.instance.addPostFrameCallback(
    (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF323232),
          margin: EdgeInsets.all(15),
          content: Text(
            message,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          duration: Duration(milliseconds: duration),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    },
  );
}
