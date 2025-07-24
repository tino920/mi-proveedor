import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/order_model.dart';
import '../../../shared/models/supplier_model.dart';

class OrderPdfActions {
  /// Genera un PDF profesional para el pedido - VERSIÓN CORREGIDA
  static Future<Map<String, dynamic>> generateOrderPdf({
    required Order order,
    required Supplier supplier,
    required Map<String, dynamic> companyData,
  }) async {
    try {
      // Crear documento PDF
      final pdf = pw.Document();

      // Intentar cargar fuentes embebidas
      try {
        final fontData = await rootBundle.load("fonts/Roboto-Regular.ttf");
        final fontBoldData = await rootBundle.load("fonts/Roboto-Bold.ttf");
        
        final font = pw.Font.ttf(fontData);
        final fontBold = pw.Font.ttf(fontBoldData);

        // ✅ SOLUCIÓN: Usar Page simple en lugar de MultiPage
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20), // Márgenes más pequeños para más espacio
            build: (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header compacto
                _buildCompactHeader(companyData, order, fontBold),
                pw.SizedBox(height: 15),
                
                // Información del proveedor y pedido en fila
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: _buildCompactSupplierInfo(supplier, font, fontBold),
                    ),
                    pw.SizedBox(width: 15),
                    pw.Expanded(
                      flex: 1,
                      child: _buildCompactOrderInfo(order, font, fontBold),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
                
                // ✅ SOLUCIÓN: Tabla de productos CON comentarios
                pw.Expanded(
                  child: _buildProductsTableWithComments(order, font, fontBold),
                ),
                pw.SizedBox(height: 10),
                
                // Total en la misma página
                _buildCompactTotalSection(order, font, fontBold),
                pw.SizedBox(height: 10),
                
                // Footer compacto
                _buildCompactFooter(companyData, font),
              ],
            ),
          ),
        );
      } catch (e) {
        // Fallback con fuentes básicas
        print('Usando fuentes básicas: $e');
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(20),
            build: (pw.Context context) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildBasicCompactHeader(companyData, order),
                pw.SizedBox(height: 15),
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: _buildBasicCompactSupplierInfo(supplier),
                    ),
                    pw.SizedBox(width: 15),
                    pw.Expanded(
                      flex: 1,
                      child: _buildBasicCompactOrderInfo(order),
                    ),
                  ],
                ),
                pw.SizedBox(height: 15),
                pw.Expanded(
                  child: _buildBasicProductsTableWithComments(order),
                ),
                pw.SizedBox(height: 10),
                _buildBasicCompactTotalSection(order),
                pw.SizedBox(height: 10),
                _buildBasicCompactFooter(companyData),
              ],
            ),
          ),
        );
      }

      // Generar bytes del PDF
      final Uint8List pdfBytes = await pdf.save();

      // Guardar archivo temporal
      final String fileName = 'pedido_${supplier.name.replaceAll(' ', '_')}-${order.orderNumber}.pdf';
      final File pdfFile = await _savePdfFile(pdfBytes, fileName);

      return {
        'success': true,
        'pdfFile': pdfFile,
        'pdfBytes': pdfBytes,
        'fileName': fileName,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Error generando PDF: $e',
      };
    }
  }

  // ========================================
  // MÉTODOS COMPACTOS CON FUENTES PERSONALIZADAS
  // ========================================

  /// Header compacto que deja más espacio para contenido
  static pw.Widget _buildCompactHeader(
    Map<String, dynamic> companyData,
    Order order,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                companyData['name'] ?? 'MiProveedor',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 18,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Text(
                'Gestión de pedidos',
                style: pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.blue600,
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'PEDIDO #${order.orderNumber}',
                style: pw.TextStyle(
                  font: fontBold,
                  fontSize: 16,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Text(
                'Fecha: ${_formatDate(DateTime.now())}',
                style: pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.blue600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Información del proveedor compacta
  static pw.Widget _buildCompactSupplierInfo(
    Supplier supplier,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL PROVEEDOR',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 11,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            supplier.name,
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 14,
            ),
          ),
          if (supplier.address != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              supplier.address!,
              style: pw.TextStyle(font: font, fontSize: 9),
            ),
          ],
          if (supplier.phone != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              'Tel: ${supplier.phone}',
              style: pw.TextStyle(font: font, fontSize: 9),
            ),
          ],
          if (supplier.email != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(
              supplier.email!,
              style: pw.TextStyle(font: font, fontSize: 9),
            ),
          ],
        ],
      ),
    );
  }

  /// Información del pedido compacta
  static pw.Widget _buildCompactOrderInfo(
    Order order,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DETALLES DEL PEDIDO',
            style: pw.TextStyle(
              font: fontBold,
              fontSize: 11,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Fecha: ${_formatDate(order.createdAt)}',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
          pw.Text(
            'Empleado: ${order.employeeName}',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
          pw.Text(
            'Estado: ${_getStatusText(order.status)}',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
          pw.Text(
            'Productos: ${order.items.length}',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              'Notas: ${order.notes}',
              style: pw.TextStyle(font: font, fontSize: 8),
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ TABLA DE PRODUCTOS CON COMENTARIOS - SOLUCIÓN PRINCIPAL
  static pw.Widget _buildProductsTableWithComments(
    Order order,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PRODUCTOS SOLICITADOS',
          style: pw.TextStyle(
            font: fontBold,
            fontSize: 12,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Expanded(
          child: pw.ListView(
            children: [
              // ✅ Header de la tabla actualizado con columna de comentarios
              pw.Container(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey300),
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                    left: pw.BorderSide(color: PdfColors.grey300),
                    right: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: _buildTableHeaderCell('PRODUCTO', fontBold),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: _buildTableHeaderCell('CANT.', fontBold),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: _buildTableHeaderCell('PRECIO', fontBold),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: _buildTableHeaderCell('TOTAL', fontBold),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: _buildTableHeaderCell('COMENTARIOS', fontBold),
                    ),
                  ],
                ),
              ),
              
              // ✅ Productos con comentarios
              ...order.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isEven = index % 2 == 0;
                
                return pw.Container(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : PdfColors.grey50,
                    border: const pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey300),
                      left: pw.BorderSide(color: PdfColors.grey300),
                      right: pw.BorderSide(color: PdfColors.grey300),
                    ),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: _buildTableDataCell(item.productName, font),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: _buildTableDataCell('${item.quantity} ${item.unit}', font),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: _buildTableDataCell('€${item.unitPrice.toStringAsFixed(2)}', font),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: _buildTableDataCell('€${item.totalPrice.toStringAsFixed(2)}', font),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: _buildTableDataCell(
                          // ✅ AQUÍ USAMOS LOS COMENTARIOS DEL MODELO
                          item.notes ?? 'Sin comentarios',
                          font,
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  /// Sección de totales compacta
  static pw.Widget _buildCompactTotalSection(
    Order order,
    pw.Font font,
    pw.Font fontBold,
  ) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 180,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.blue50,
          border: pw.Border.all(color: PdfColors.blue200),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildTotalRow('Subtotal:', '€${order.subtotal.toStringAsFixed(2)}', font),
            pw.SizedBox(height: 3),
            _buildTotalRow(
              'IVA (${(order.tax / order.subtotal * 100).toStringAsFixed(0)}%):',
              '€${order.tax.toStringAsFixed(2)}',
              font,
            ),
            pw.Divider(color: PdfColors.blue300),
            _buildTotalRow(
              'TOTAL:',
              '€${order.total.toStringAsFixed(2)}',
              fontBold,
              isFinal: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Footer compacto
  static pw.Widget _buildCompactFooter(
    Map<String, dynamic> companyData,
    pw.Font font,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generado por MiProveedor - ${_formatDate(DateTime.now())}',
            style: pw.TextStyle(
              font: font,
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
          if (companyData['phone'] != null) ...[
            pw.Text(
              'Tel: ${companyData['phone']}',
              style: pw.TextStyle(
                font: font,
                fontSize: 8,
                color: PdfColors.grey600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ========================================
  // MÉTODOS BÁSICOS COMPACTOS (FALLBACK)
  // ========================================

  static pw.Widget _buildBasicCompactHeader(Map<String, dynamic> companyData, Order order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                companyData['name'] ?? 'MiProveedor',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Text(
                'Gestión de pedidos',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.blue600),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'PEDIDO #${order.orderNumber}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue800,
                ),
              ),
              pw.Text(
                'Fecha: ${_formatDate(DateTime.now())}',
                style: pw.TextStyle(fontSize: 9, color: PdfColors.blue600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBasicCompactSupplierInfo(Supplier supplier) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'INFORMACIÓN DEL PROVEEDOR',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey800,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            supplier.name,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          if (supplier.address != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(supplier.address!, style: pw.TextStyle(fontSize: 9)),
          ],
          if (supplier.phone != null) ...[
            pw.SizedBox(height: 2),
            pw.Text('Tel: ${supplier.phone}', style: pw.TextStyle(fontSize: 9)),
          ],
          if (supplier.email != null) ...[
            pw.SizedBox(height: 2),
            pw.Text(supplier.email!, style: pw.TextStyle(fontSize: 9)),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildBasicCompactOrderInfo(Order order) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DETALLES DEL PEDIDO',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.green800,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text('Fecha: ${_formatDate(order.createdAt)}', style: pw.TextStyle(fontSize: 9)),
          pw.Text('Empleado: ${order.employeeName}', style: pw.TextStyle(fontSize: 9)),
          pw.Text('Estado: ${_getStatusText(order.status)}', style: pw.TextStyle(fontSize: 9)),
          pw.Text('Productos: ${order.items.length}', style: pw.TextStyle(fontSize: 9)),
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            pw.SizedBox(height: 3),
            pw.Text(
              'Notas: ${order.notes}',
              style: pw.TextStyle(fontSize: 8),
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ TABLA BÁSICA CON COMENTARIOS
  static pw.Widget _buildBasicProductsTableWithComments(Order order) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'PRODUCTOS SOLICITADOS',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Expanded(
          child: pw.ListView(
            children: [
              // Header
              pw.Container(
                decoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                  border: pw.Border(
                    top: pw.BorderSide(color: PdfColors.grey300),
                    bottom: pw.BorderSide(color: PdfColors.grey300),
                    left: pw.BorderSide(color: PdfColors.grey300),
                    right: pw.BorderSide(color: PdfColors.grey300),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: _buildBasicTableHeaderCell('PRODUCTO')),
                    pw.Expanded(flex: 1, child: _buildBasicTableHeaderCell('CANT.')),
                    pw.Expanded(flex: 1, child: _buildBasicTableHeaderCell('PRECIO')),
                    pw.Expanded(flex: 1, child: _buildBasicTableHeaderCell('TOTAL')),
                    pw.Expanded(flex: 2, child: _buildBasicTableHeaderCell('COMENTARIOS')),
                  ],
                ),
              ),
              
              // Productos
              ...order.items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isEven = index % 2 == 0;
                
                return pw.Container(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : PdfColors.grey50,
                    border: const pw.Border(
                      bottom: pw.BorderSide(color: PdfColors.grey300),
                      left: pw.BorderSide(color: PdfColors.grey300),
                      right: pw.BorderSide(color: PdfColors.grey300),
                    ),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(flex: 3, child: _buildBasicTableDataCell(item.productName)),
                      pw.Expanded(flex: 1, child: _buildBasicTableDataCell('${item.quantity} ${item.unit}')),
                      pw.Expanded(flex: 1, child: _buildBasicTableDataCell('€${item.unitPrice.toStringAsFixed(2)}')),
                      pw.Expanded(flex: 1, child: _buildBasicTableDataCell('€${item.totalPrice.toStringAsFixed(2)}')),
                      pw.Expanded(
                        flex: 2, 
                        child: _buildBasicTableDataCell(
                          item.notes ?? 'Sin comentarios',
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBasicCompactTotalSection(Order order) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Container(
        width: 180,
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.blue50,
          border: pw.Border.all(color: PdfColors.blue200),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            _buildBasicTotalRow('Subtotal:', '€${order.subtotal.toStringAsFixed(2)}'),
            pw.SizedBox(height: 3),
            _buildBasicTotalRow('IVA:', '€${order.tax.toStringAsFixed(2)}'),
            pw.Divider(color: PdfColors.blue300),
            _buildBasicTotalRow(
              'TOTAL:',
              '€${order.total.toStringAsFixed(2)}',
              isFinal: true,
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _buildBasicCompactFooter(Map<String, dynamic> companyData) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Generado por MiProveedor - ${_formatDate(DateTime.now())}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
          if (companyData['phone'] != null) ...[
            pw.Text(
              'Tel: ${companyData['phone']}',
              style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ],
        ],
      ),
    );
  }

  // ========================================
  // MÉTODOS AUXILIARES PARA TABLA
  // ========================================

  static pw.Widget _buildTableHeaderCell(String text, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: fontBold,
          fontSize: 9,
          color: PdfColors.grey800,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableDataCell(
    String text,
    pw.Font font, {
    int maxLines = 1,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: 8,
          color: PdfColors.grey700,
        ),
        maxLines: maxLines,
        textAlign: pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _buildBasicTableHeaderCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.grey800,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildBasicTableDataCell(String text, {int maxLines = 1}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          color: PdfColors.grey700,
        ),
        maxLines: maxLines,
        textAlign: pw.TextAlign.left,
      ),
    );
  }

  static pw.Widget _buildTotalRow(
    String label,
    String value,
    pw.Font font, {
    bool isFinal = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: font,
            fontSize: isFinal ? 12 : 10,
            color: isFinal ? PdfColors.blue800 : PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: font,
            fontSize: isFinal ? 12 : 10,
            color: isFinal ? PdfColors.blue800 : PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildBasicTotalRow(
    String label,
    String value, {
    bool isFinal = false,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: isFinal ? 12 : 10,
            fontWeight: isFinal ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isFinal ? PdfColors.blue800 : PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isFinal ? 12 : 10,
            fontWeight: isFinal ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: isFinal ? PdfColors.blue800 : PdfColors.grey700,
          ),
        ),
      ],
    );
  }

  // ========================================
  // MÉTODOS UTILITARIOS (REUTILIZADOS)
  // ========================================

  static Future<File> _savePdfFile(Uint8List pdfBytes, String fileName) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String filePath = '${tempDir.path}/$fileName';
    final File file = File(filePath);
    await file.writeAsBytes(pdfBytes);
    return file;
  }

  static String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date);
  }

  static String _getStatusText(OrderStatus status) {
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

  // ========================================
  // MÉTODOS DE COMPARTIR (IGUALES QUE ANTES)
  // ========================================

  static Future<Map<String, dynamic>> shareViaWhatsApp({
    required Order order,
    required Supplier supplier,
    required File pdfFile,
    required Map<String, dynamic> companyData,
  }) async {
    try {
      final String message = _createWhatsAppMessage(order, supplier, companyData);
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: message,
        subject: 'Pedido #${order.orderNumber} - ${companyData['name']}',
      );
      return {'success': true, 'message': 'Pedido compartido exitosamente'};
    } catch (e) {
      return {'success': false, 'error': 'Error compartiendo por WhatsApp: $e'};
    }
  }

  static Future<Map<String, dynamic>> shareViaEmail({
    required Order order,
    required Supplier supplier,
    required File pdfFile,
    required Map<String, dynamic> companyData,
  }) async {
    try {
      if (supplier.email == null || supplier.email!.isEmpty) {
        return {'success': false, 'error': 'El proveedor no tiene email configurado'};
      }
      final String subject = 'Pedido #${order.orderNumber} - ${companyData['name']}';
      final String body = _createEmailBody(order, supplier, companyData);
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: subject,
        text: body,
      );
      return {'success': true, 'message': 'Pedido compartido exitosamente'};
    } catch (e) {
      return {'success': false, 'error': 'Error compartiendo por email: $e'};
    }
  }

  static Future<Map<String, dynamic>> shareBoth({
    required Order order,
    required Supplier supplier,
    required File pdfFile,
    required Map<String, dynamic> companyData,
  }) async {
    try {
      final List<String> results = [];
      final List<String> errors = [];

      // Intentar WhatsApp
      final whatsappResult = await shareViaWhatsApp(
        order: order,
        supplier: supplier,
        pdfFile: pdfFile,
        companyData: companyData,
      );

      if (whatsappResult['success']) {
        results.add('WhatsApp: ${whatsappResult['message']}');
      } else {
        errors.add('WhatsApp: ${whatsappResult['error']}');
      }

      // Intentar Email
      final emailResult = await shareViaEmail(
        order: order,
        supplier: supplier,
        pdfFile: pdfFile,
        companyData: companyData,
      );

      if (emailResult['success']) {
        results.add('Email: ${emailResult['message']}');
      } else {
        errors.add('Email: ${emailResult['error']}');
      }

      // Evaluar resultado general
      if (results.isNotEmpty) {
        return {
          'success': true,
          'message': 'Enviado exitosamente:\n${results.join('\n')}',
          'errors': errors.isNotEmpty ? errors : null,
        };
      } else {
        return {
          'success': false,
          'error': 'No se pudo enviar por ningún método:\n${errors.join('\n')}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error en envío múltiple: $e',
      };
    }
  }

  static Future<Uint8List?> generatePdfPreview({
    required Order order,
    required Supplier supplier,
    required Map<String, dynamic> companyData,
  }) async {
    try {
      final result = await generateOrderPdf(
        order: order,
        supplier: supplier,
        companyData: companyData,
      );

      if (result['success']) {
        return result['pdfBytes'] as Uint8List;
      }
      return null;
    } catch (e) {
      print('Error generando preview: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> generateAndShare({
    required Order order,
    required Supplier supplier,
    required Map<String, dynamic> companyData,
    required ShareMethod method,
  }) async {
    try {
      final pdfResult = await generateOrderPdf(
        order: order,
        supplier: supplier,
        companyData: companyData,
      );
      if (!pdfResult['success']) return pdfResult;
      final File pdfFile = pdfResult['pdfFile'];
      switch (method) {
        case ShareMethod.whatsapp:
          return await shareViaWhatsApp(order: order, supplier: supplier, pdfFile: pdfFile, companyData: companyData);
        case ShareMethod.email:
          return await shareViaEmail(order: order, supplier: supplier, pdfFile: pdfFile, companyData: companyData);
        case ShareMethod.both:
          return await shareBoth(order: order, supplier: supplier, pdfFile: pdfFile, companyData: companyData);
      }
    } catch (e) {
      return {'success': false, 'error': 'Error en el proceso completo: $e'};
    }
  }

  static String _createWhatsAppMessage(Order order, Supplier supplier, Map<String, dynamic> companyData) {
    return '''🍽️ *Nuevo Pedido - ${companyData['name']}*

Hola ${supplier.name},

Te enviamos el pedido #${order.orderNumber}.

📋 *Detalles del pedido:*
• Total: *€${order.total.toStringAsFixed(2)}*
• Productos: ${order.items.length} artículos
• Empleado: ${order.employeeName}
• Fecha: ${_formatDate(order.createdAt)}

${order.notes != null && order.notes!.isNotEmpty ? '📝 Notas: ${order.notes}\n' : ''}

Por favor, confirma recepción y fecha de entrega.

Saludos cordiales,
${companyData['name']}
${companyData['phone'] != null ? 'Tel: ${companyData['phone']}' : ''}

---
Enviado con MiProveedor 🍽️''';
  }

  static String _createEmailBody(Order order, Supplier supplier, Map<String, dynamic> companyData) {
    return '''Estimado ${supplier.name},

Esperamos que se encuentren bien. Adjunto encontrarás el pedido #${order.orderNumber} de ${companyData['name']}.

DETALLES DEL PEDIDO:
- Número de pedido: #${order.orderNumber}
- Total: €${order.total.toStringAsFixed(2)}
- Cantidad de productos: ${order.items.length} artículos
- Empleado solicitante: ${order.employeeName}
- Fecha de solicitud: ${_formatDate(order.createdAt)}

${order.notes != null && order.notes!.isNotEmpty ? 'NOTAS ADICIONALES:\n${order.notes}\n\n' : ''}

PRODUCTOS SOLICITADOS:
${order.items.map((item) => '• ${item.productName}: ${item.quantity} ${item.unit} - €${item.totalPrice.toStringAsFixed(2)}${item.notes != null && item.notes!.isNotEmpty ? ' (${item.notes})' : ''}').join('\n')}

Por favor, confirma la recepción de este pedido y proporciona la fecha estimada de entrega.

Agradecemos tu servicio y quedamos a la espera de tu confirmación.

Atentamente,
${companyData['name']}
${companyData['phone'] != null ? 'Teléfono: ${companyData['phone']}' : ''}
${companyData['email'] != null ? 'Email: ${companyData['email']}' : ''}

---
Este pedido fue generado automáticamente por MiProveedor.''';
  }

  static Future<void> cleanupTempFiles() async {
    try {
      final Directory tempDir = await getTemporaryDirectory();
      final List<FileSystemEntity> files = tempDir.listSync();

      for (final FileSystemEntity file in files) {
        if (file is File && file.path.contains('pedido_') && file.path.endsWith('.pdf')) {
          final DateTime fileDate = File(file.path).lastModifiedSync();
          final Duration difference = DateTime.now().difference(fileDate);

          // Eliminar archivos de más de 1 día
          if (difference.inDays > 1) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Error limpiando archivos temporales: $e');
    }
  }

  static bool validateOrderData(Order order, Supplier supplier) {
    if (order.items.isEmpty) return false;
    for (final item in order.items) {
      if (item.productName.isEmpty || item.quantity <= 0 || item.unitPrice <= 0) {
        return false;
      }
    }
    if (supplier.name.isEmpty) return false;
    return true;
  }

  static String getOrderSummary(Order order) {
    final double totalQuantity = order.items.fold(0.0, (sum, item) => sum + item.quantity);
    return 'Pedido #${order.orderNumber}: ${order.items.length} productos, '
        '${totalQuantity.toStringAsFixed(1)} artículos, '
        '€${order.total.toStringAsFixed(2)}';
  }
}

// Enum para métodos de envío (igual que antes)
enum ShareMethod { whatsapp, email, both }

extension ShareMethodExtension on ShareMethod {
  String get name {
    switch (this) {
      case ShareMethod.whatsapp: return 'whatsapp';
      case ShareMethod.email: return 'email';
      case ShareMethod.both: return 'both';
    }
  }
  String get displayName {
    switch (this) {
      case ShareMethod.whatsapp: return 'WhatsApp';
      case ShareMethod.email: return 'Email';
      case ShareMethod.both: return 'WhatsApp y Email';
    }
  }
  IconData get icon {
    switch (this) {
      case ShareMethod.whatsapp: return Icons.message;
      case ShareMethod.email: return Icons.email;
      case ShareMethod.both: return Icons.share;
    }
  }
}
