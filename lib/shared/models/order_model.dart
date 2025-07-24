import 'package:cloud_firestore/cloud_firestore.dart';
import 'order_item_model.dart';

enum OrderStatus {
  draft,
  pending,
  approved,
  rejected,
  sent,
  completed,
}

class Order {
  final String id;
  final String orderNumber;
  final String companyId;
  final String employeeId;
  final String employeeName;
  final String supplierId;
  final String supplierName;
  final OrderStatus status;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool viewedByEmployee; // ✅ NUEVO CAMPO


  // Campos de aprobación
  final String? approvedBy;
  final String? approverName;
  final DateTime? approvedAt;
  final String? approvalNotes;
  
  // Campos de rechazo
  final String? rejectedBy;
  final String? rejectorName;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  
  // Campos de envío
  final DateTime? sentAt;
  final String? sentMethod; // 'email', 'whatsapp', 'both'
  final String? pdfUrl;
  
  // Límites y validaciones
  final double? employeeOrderLimit;
  final bool requiresApproval;

  Order({
    required this.id,
    required this.orderNumber,
    required this.companyId,
    required this.employeeId,
    required this.employeeName,
    required this.supplierId,
    required this.supplierName,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.approvedBy,
    this.approverName,
    this.approvedAt,
    this.approvalNotes,
    this.rejectedBy,
    this.rejectorName,
    this.rejectedAt,
    this.rejectionReason,
    this.sentAt,
    this.sentMethod,
    this.pdfUrl,
    this.employeeOrderLimit,
    this.requiresApproval = true,
    this.viewedByEmployee = false, // ✅ VALOR POR DEFECTO

  });

  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Order(
      id: doc.id,
      orderNumber: data['orderNumber'] ?? '',
      companyId: data['companyId'] ?? '',
      employeeId: data['employeeId'] ?? '',
      employeeName: data['employeeName'] ?? '',
      supplierId: data['supplierId'] ?? '',
      supplierName: data['supplierName'] ?? '',
      status: _parseStatus(data['status']),
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => OrderItem.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      tax: (data['tax'] ?? 0.0).toDouble(),
      total: (data['total'] ?? 0.0).toDouble(),
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedBy: data['approvedBy'],
      approverName: data['approverName'],
      approvedAt: (data['approvedAt'] as Timestamp?)?.toDate(),
      approvalNotes: data['approvalNotes'],
      rejectedBy: data['rejectedBy'],
      rejectorName: data['rejectorName'],
      rejectedAt: (data['rejectedAt'] as Timestamp?)?.toDate(),
      rejectionReason: data['rejectionReason'],
      sentAt: (data['sentAt'] as Timestamp?)?.toDate(),
      sentMethod: data['sentMethod'],
      pdfUrl: data['pdfUrl'],
      employeeOrderLimit: (data['employeeOrderLimit'] ?? 0.0).toDouble(),
      requiresApproval: data['requiresApproval'] ?? true,
      viewedByEmployee: data['viewedByEmployee'] ?? false, // ✅ LEER DE FIREBASE

    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'orderNumber': orderNumber,
      'companyId': companyId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'status': status.name,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'approvedBy': approvedBy,
      'approverName': approverName,
      'approvedAt': approvedAt,
      'approvalNotes': approvalNotes,
      'rejectedBy': rejectedBy,
      'rejectorName': rejectorName,
      'rejectedAt': rejectedAt,
      'rejectionReason': rejectionReason,
      'sentAt': sentAt,
      'sentMethod': sentMethod,
      'pdfUrl': pdfUrl,
      'employeeOrderLimit': employeeOrderLimit,
      'requiresApproval': requiresApproval,
      'viewedByEmployee': viewedByEmployee, // ✅ ESCRIBIR EN FIREBASE

    };
  }

  static OrderStatus _parseStatus(String? statusString) {
    switch (statusString?.toLowerCase()) {
      case 'draft':
        return OrderStatus.draft;
      case 'pending':
        return OrderStatus.pending;
      case 'approved':
        return OrderStatus.approved;
      case 'rejected':
        return OrderStatus.rejected;
      case 'sent':
        return OrderStatus.sent;
      case 'completed':
        return OrderStatus.completed;
      default:
        return OrderStatus.draft;
    }
  }

  // Helper methods
  bool get canBeEdited => status == OrderStatus.draft;
  bool get canBeSubmitted => status == OrderStatus.draft && items.isNotEmpty;
  bool get canBeApproved => status == OrderStatus.pending;
  bool get canBeRejected => status == OrderStatus.pending;
  bool get canBeSent => status == OrderStatus.approved;
  bool get isPending => status == OrderStatus.pending;
  bool get isApproved => status == OrderStatus.approved;
  bool get isRejected => status == OrderStatus.rejected;
  bool get isSent => status == OrderStatus.sent;

  String get statusDisplayName {
    switch (status) {
      case OrderStatus.draft:
        return 'Borrador';
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.approved:
        return 'Aprobado';
      case OrderStatus.rejected:
        return 'Rechazado';
      case OrderStatus.sent:
        return 'Enviado';
      case OrderStatus.completed:
        return 'Completado';
    }
  }

  // Generate order number
  static String generateOrderNumber() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    
    return 'ORD-$year$month$day-$hour$minute';
  }

  // Calculate totals
  factory Order.calculateTotals(Order order) {
    double subtotal = 0.0;
    
    for (final item in order.items) {
      subtotal += item.totalPrice;
    }
    
    // Tax calculation (21% IVA in Spain)
    double tax = subtotal * 0.0; // Por ahora sin impuestos
    double total = subtotal + tax;
    
    return order.copyWith(
      subtotal: subtotal,
      tax: tax,
      total: total,
    );
  }

  Order copyWith({
    String? id,
    String? orderNumber,
    String? companyId,
    String? employeeId,
    String? employeeName,
    String? supplierId,
    String? supplierName,
    OrderStatus? status,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvedBy,
    String? approverName,
    DateTime? approvedAt,
    String? approvalNotes,
    String? rejectedBy,
    String? rejectorName,
    DateTime? rejectedAt,
    String? rejectionReason,
    DateTime? sentAt,
    String? sentMethod,
    String? pdfUrl,
    double? employeeOrderLimit,
    bool? requiresApproval,
    bool? viewedByEmployee, // ✅ AÑADIR A COPYWITH

  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      companyId: companyId ?? this.companyId,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approverName: approverName ?? this.approverName,
      approvedAt: approvedAt ?? this.approvedAt,
      approvalNotes: approvalNotes ?? this.approvalNotes,
      rejectedBy: rejectedBy ?? this.rejectedBy,
      rejectorName: rejectorName ?? this.rejectorName,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      sentAt: sentAt ?? this.sentAt,
      sentMethod: sentMethod ?? this.sentMethod,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      employeeOrderLimit: employeeOrderLimit ?? this.employeeOrderLimit,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      viewedByEmployee: viewedByEmployee ?? this.viewedByEmployee, // ✅ AÑADIR A COPYWITH

    );
  }
}
