import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ImportResultsDialog extends StatelessWidget {
  final int imported;
  final List<String> errors;
  
  const ImportResultsDialog({
    super.key,
    required this.imported,
    required this.errors,
  });
  
  @override
  Widget build(BuildContext context) {
    final hasErrors = errors.isNotEmpty;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: hasErrors 
                    ? AppTheme.warningColor.withOpacity(0.1)
                    : AppTheme.successColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    hasErrors ? Icons.warning : Icons.check_circle,
                    color: hasErrors ? AppTheme.warningColor : AppTheme.successColor,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Importación Completada',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$imported productos importados correctamente',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            if (hasErrors) ...[
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Se encontraron los siguientes errores:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.shade200,
                            ),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: errors.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errors[index],
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.celebration,
                      size: 64,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '¡Excelente!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Todos los productos se importaron sin errores',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            
            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
