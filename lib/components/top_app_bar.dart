import 'package:flutter/material.dart';

class TopAppBarContent extends StatelessWidget {
  const TopAppBarContent({
    super.key,
    required this.titleText,
    required this.shouldShowBackButton,
  });

  final String titleText;
  final bool shouldShowBackButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: shouldShowBackButton
              ? Colors.white
              : Colors.transparent,
          child: IconButton(
            onPressed: shouldShowBackButton
                ? () {
                    Navigator.of(context).pop();
                  }
                : null,
            color: Colors.black,
            disabledColor: Colors.transparent,
            icon: Icon(Icons.arrow_back_outlined, size: 20),
          ),
        ),
        Text(titleText, style: Theme.of(context).textTheme.headlineLarge),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_horiz, size: 20),
          ),
        ),
      ],
    );
  }
}
