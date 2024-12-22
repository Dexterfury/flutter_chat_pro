import 'package:flutter/material.dart';
import 'package:flutter_chat_pro/models/message_model.dart';
import 'package:flutter_chat_pro/utilities/global_methods.dart';
import 'package:google_fonts/google_fonts.dart';

class DateWidget extends StatelessWidget {
  const DateWidget({
    super.key,
    required this.message,
  });

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            GlobalMethods.formatDateHeader(message.timeSent),
            style: GoogleFonts.openSans(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}
