import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../../../../core/theme/app_theme.dart';
import '../../providers/products_provider.dart';
import 'import_results_dialog.dart'; // Importamos tu diálogo de resultados

class ImportProductsDialog extends StatefulWidget {
  final String companyId;
  final String supplierId;

  const ImportProductsDialog({
    super.key,
    required this.companyId,
    required this.supplierId,
  });

  @override
  State<ImportProductsDialog> createState() => _ImportProductsDialogState();
}

class _ImportProductsDialogState extends State<ImportProductsDialog> {
  File? _selectedFile;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );
      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      _showError('Error al seleccionar el archivo: $e');
    }
  }

  Future<void> _startImport() async {
    if (_selectedFile == null) {
      _showError('Por favor, selecciona un archivo de Excel primero.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bytes = await _selectedFile!.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables[excel.tables.keys.first];

      if (sheet == null) {
        throw Exception('El archivo de Excel no contiene hojas de cálculo.');
      }

      final headers = sheet.rows.first.map((cell) => cell?.value.toString().trim().toLowerCase()).toList();
      
      // SOLUCIÓN: Mapeo de columnas en español a inglés
      final columnMapping = {
        // Nombres en español
        'nombre': 'name',
        'precio': 'price',
        'categoria': 'category',
        'categoría': 'category',
        'unidad': 'unit',
        'codigo': 'sku',
        'código': 'sku',
        'descripcion': 'description',
        'descripción': 'description',
        'imagen': 'image',
        'url_imagen': 'image',
        // Nombres en inglés (mantener compatibilidad)
        'name': 'name',
        'price': 'price',
        'category': 'category',
        'unit': 'unit',
        'sku': 'sku',
        'description': 'description',
        'image': 'image',
        'image_url': 'image',
      };
      
      // Convertir headers usando el mapeo
      final mappedHeaders = headers.map((header) => 
        header != null ? columnMapping[header] ?? header : null
      ).toList();
      
      final requiredHeaders = ['name', 'price'];

      for (var header in requiredHeaders) {
        if (!mappedHeaders.contains(header)) {
          throw Exception('La columna requerida "$header" (o "${_getSpanishColumnName(header)}") no se encontró en el archivo.');
        }
      }

      final productsData = <Map<String, dynamic>>[];
      for (var i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        final productMap = <String, dynamic>{};
        for (var j = 0; j < mappedHeaders.length; j++) {
          final header = mappedHeaders[j];
          if(header != null && row.length > j && row[j]?.value != null) {
            productMap[header] = row[j]!.value;
          }
        }
        if(productMap.isNotEmpty) {
          productsData.add(productMap);
        }
      }

      if (productsData.isEmpty) {
        throw Exception('No se encontraron datos de productos en el archivo.');
      }

      final provider = Provider.of<ProductsProvider>(context, listen: false);
      final result = await provider.importProductsFromExcel(
        companyId: widget.companyId,
        supplierId: widget.supplierId,
        productsData: productsData,
      );

      if (mounted) {
        // Cerramos este diálogo y abrimos el tuyo con los resultados
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (_) => ImportResultsDialog(
            imported: result['successCount'] ?? 0,
            errors: List<String>.from(result['errors'] ?? []),
          ),
        );
      }

    } catch (e) {
      _showError('Error al procesar el archivo: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorColor),
    );
  }
  
  String _getSpanishColumnName(String englishName) {
    switch (englishName) {
      case 'name':
        return 'nombre';
      case 'price':
        return 'precio';
      case 'category':
        return 'categoria';
      case 'unit':
        return 'unidad';
      case 'sku':
        return 'codigo';
      case 'description':
        return 'descripcion';
      default:
        return englishName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Importar Productos'),
      content: _isLoading
          ? _buildLoading()
          : _buildFilePicker(),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedFile == null ? null : _startImport,
          child: const Text('Importar'),
        ),
      ],
    );
  }

  Widget _buildFilePicker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Selecciona un archivo .xlsx con las columnas:'),
        const SizedBox(height: 8),
        const Text('• nombre (requerido)\n• precio (requerido)\n• categoria\n• unidad\n• codigo\n• descripcion', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _pickFile,
          icon: const Icon(Icons.upload_file),
          label: const Text('Seleccionar Archivo'),
        ),
        if (_selectedFile != null) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedFile!.path.split(Platform.pathSeparator).last,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ]
      ],
    );
  }

  Widget _buildLoading() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text('Importando productos...'),
        Text('Esto puede tardar unos segundos.'),
      ],
    );
  }
}
