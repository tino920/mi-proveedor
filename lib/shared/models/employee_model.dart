import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String companyId;
  final bool isActive;
  final DateTime joinDate;
  final int ordersCount;
  final String? position;
  final Map<String, dynamic>? permissions;

  EmployeeModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.companyId,
    required this.isActive,
    required this.joinDate,
    this.ordersCount = 0,
    this.position,
    this.permissions,
  });

  factory EmployeeModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      
      if (data == null) {
        throw Exception('Document data is null');
      }

      // Manejar diferentes fuentes de fecha (joinDate o createdAt)
      DateTime joinDate = DateTime.now();
      if (data.containsKey('joinDate') && data['joinDate'] != null) {
        if (data['joinDate'] is Timestamp) {
          joinDate = (data['joinDate'] as Timestamp).toDate();
        } else if (data['joinDate'] is String) {
          joinDate = DateTime.tryParse(data['joinDate']) ?? DateTime.now();
        }
      } else if (data.containsKey('createdAt') && data['createdAt'] != null) {
        if (data['createdAt'] is Timestamp) {
          joinDate = (data['createdAt'] as Timestamp).toDate();
        } else if (data['createdAt'] is String) {
          joinDate = DateTime.tryParse(data['createdAt']) ?? DateTime.now();
        }
      }

      return EmployeeModel(
        uid: doc.id,
        name: _getStringValue(data, 'name', ''),
        email: _getStringValue(data, 'email', ''),
        role: _getStringValue(data, 'role', 'employee'),
        companyId: _getStringValue(data, 'companyId', ''),
        isActive: _getBoolValue(data, 'isActive', true),
        joinDate: joinDate,
        ordersCount: _getIntValue(data, 'ordersCount', 0),
        position: _getStringValue(data, 'position', null),
        permissions: data['permissions'] as Map<String, dynamic>?,
      );
    } catch (e) {
      print('Error creating EmployeeModel from Firestore: $e');
      print('Document ID: ${doc.id}');
      print('Document data: ${doc.data()}');
      
      // Crear un empleado con datos mínimos para evitar crashes
      return EmployeeModel(
        uid: doc.id,
        name: 'Error al cargar',
        email: '',
        role: 'employee',
        companyId: '',
        isActive: false,
        joinDate: DateTime.now(),
        ordersCount: 0,
      );
    }
  }

  // Métodos auxiliares para manejo seguro de datos
  static String _getStringValue(Map<String, dynamic> data, String key, String? defaultValue) {
    if (!data.containsKey(key) || data[key] == null) {
      return defaultValue ?? '';
    }
    return data[key].toString();
  }

  static bool _getBoolValue(Map<String, dynamic> data, String key, bool defaultValue) {
    if (!data.containsKey(key) || data[key] == null) {
      return defaultValue;
    }
    if (data[key] is bool) {
      return data[key] as bool;
    }
    // Manejar strings que representan booleanos
    final value = data[key].toString().toLowerCase();
    return value == 'true' || value == '1';
  }

  static int _getIntValue(Map<String, dynamic> data, String key, int defaultValue) {
    if (!data.containsKey(key) || data[key] == null) {
      return defaultValue;
    }
    if (data[key] is int) {
      return data[key] as int;
    }
    if (data[key] is double) {
      return (data[key] as double).round();
    }
    return int.tryParse(data[key].toString()) ?? defaultValue;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'companyId': companyId,
      'isActive': isActive,
      'joinDate': Timestamp.fromDate(joinDate),
      'ordersCount': ordersCount,
      'position': position,
      'permissions': permissions,
      'updatedAt': Timestamp.now(),
    };
  }

  EmployeeModel copyWith({
    String? name,
    String? email,
    String? role,
    String? companyId,
    bool? isActive,
    DateTime? joinDate,
    int? ordersCount,
    String? position,
    Map<String, dynamic>? permissions,
  }) {
    return EmployeeModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      companyId: companyId ?? this.companyId,
      isActive: isActive ?? this.isActive,
      joinDate: joinDate ?? this.joinDate,
      ordersCount: ordersCount ?? this.ordersCount,
      position: position ?? this.position,
      permissions: permissions ?? this.permissions,
    );
  }

  String get displayRole {
    if (position != null && position!.isNotEmpty) {
      return position!;
    }
    
    switch (role.toLowerCase()) {
      case 'admin':
        return 'Administrador';
      case 'manager':
        return 'Gerente';
      case 'employee':
        return 'Empleado';
      default:
        return role;
    }
  }

  String get initials {
    if (name.isEmpty) return 'U';
    
    List<String> nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'U';
  }

  String get statusText {
    return isActive ? 'Activo' : 'Inactivo';
  }

  bool get isNewEmployee {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return joinDate.isAfter(thirtyDaysAgo);
  }

  @override
  String toString() {
    return 'EmployeeModel(uid: $uid, name: $name, email: $email, role: $role, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EmployeeModel && other.uid == uid;
  }

  @override
  int get hashCode {
    return uid.hashCode;
  }
}
