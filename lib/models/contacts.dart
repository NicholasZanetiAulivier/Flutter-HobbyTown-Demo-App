import 'package:flutter/material.dart';

class ContactChannel {
  final String title;
  final String phone;
  final String description;

  const ContactChannel({
    required this.title,
    required this.phone,
    required this.description,
  });
}

class StoreLocation {
  final String address;
  final String note;

  const StoreLocation({required this.address, required this.note});
}

class FaqItem {
  final IconData icon;
  final String question;

  const FaqItem({required this.icon, required this.question});
}
