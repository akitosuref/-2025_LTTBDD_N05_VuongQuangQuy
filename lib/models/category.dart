import 'package:flutter/material.dart';

class Category {
  final int? id;
  final String name;
  final IconData icon;
  final Color color;
  final String type;

  Category({
    this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
      'type': type,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      color: Color(map['color']),
      type: map['type'],
    );
  }
}
