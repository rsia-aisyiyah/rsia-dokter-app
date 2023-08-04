import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BoxMessage extends StatelessWidget {
  final String title;
  final String body;
  final Color borderColor;
  final Color backgroundColour;

  const BoxMessage({
    super.key,
    this.title = "",
    required this.body,
    this.borderColor = Colors.black,
    this.backgroundColour = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.1,
      padding: const EdgeInsets.all(15),
      margin: const EdgeInsets.symmetric(
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: backgroundColour,
        border: Border.all(
          width: 1.3,
          color: borderColor,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: title.isEmpty
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          title.isNotEmpty
              ? Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                    title,
                    style: TextStyle(
                      color: borderColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              )
              : const SizedBox(),
          Text(
            body,
            style: TextStyle(
              color: borderColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
