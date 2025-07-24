import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/app_gradients.dart';

class HelpSupportSection extends StatelessWidget {
  const HelpSupportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.help_center, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ayuda y Soporte',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.support_agent, color: Colors.white, size: 20),
              ],
            ),
          ),
          Column(
            children: [
              _buildSettingsItem(
                Icons.help_center,
                'Centro de Ayuda',
                'Preguntas frecuentes y tutoriales',
                () => _openHelpCenter(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.support_agent,
                'Contactar Soporte',
                'Obtener ayuda directa de nuestro equipo',
                () => _contactSupport(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.video_library,
                'Tutoriales en Video',
                'Aprende a usar todas las funciones',
                () => _openVideoTutorials(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.feedback,
                'Enviar Comentarios',
                'Comparte tu experiencia y sugerencias',
                () => _sendFeedback(context),
              ),
              const Divider(height: 1),
              _buildSettingsItem(
                Icons.bug_report,
                'Reportar Problema',
                'Informar sobre errores o problemas técnicos',
                () => _reportBug(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: AppGradients.primaryGradient,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppTheme.secondaryTextColor,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _openHelpCenter(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_center, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Centro de Ayuda'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('❓ Preguntas Frecuentes:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              _HelpItem('¿Cómo añadir un nuevo proveedor?', 
                'Ve a Proveedores > Nuevo Proveedor y completa la información'),
              _HelpItem('¿Cómo importar productos desde Excel?', 
                'Selecciona un proveedor > Importar Productos > Elige archivo Excel'),
              _HelpItem('¿Cómo aprobar pedidos de empleados?', 
                'En Inicio verás pedidos pendientes con botones Aprobar/Rechazar'),
              _HelpItem('¿Cómo generar PDFs de pedidos?', 
                'Después de aprobar, usa "Enviar Pedido" > Genera PDF automáticamente'),
              _HelpItem('¿Cómo invitar empleados?', 
                'Ve a Empleados > Comparte el código de empresa'),
              
              SizedBox(height: 16),
              Text('💡 Consejos:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              _TipItem('Mantén actualizada la información de proveedores'),
              _TipItem('Configura límites apropiados para empleados'),
              _TipItem('Revisa regularmente los pedidos pendientes'),
              _TipItem('Usa imágenes para identificar productos fácilmente'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.support_agent, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Contactar Soporte'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('¿Necesitas ayuda personalizada? Contáctanos:'),
            SizedBox(height: 20),
            
            _ContactItem(Icons.email, 'Email', 'soporte@restau-pedidos.com'),
            SizedBox(height: 12),
            _ContactItem(Icons.phone, 'Teléfono', '+34 900 123 456'),
            SizedBox(height: 12),
            _ContactItem(Icons.chat, 'WhatsApp', '+34 666 123 456'),
            SizedBox(height: 12),
            _ContactItem(Icons.schedule, 'Horario', 'Lun-Vie 9:00-18:00'),
            
            SizedBox(height: 16),
            Text('⚡ Respuesta promedio: 2 horas',
              style: TextStyle(color: AppTheme.successColor, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('📧 Abriendo cliente de email...')),
              );
            },
            icon: const Icon(Icons.email),
            label: const Text('Enviar Email'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _openVideoTutorials(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.video_library, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Tutoriales en Video'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎥 Próximamente disponibles:'),
            SizedBox(height: 12),
            _VideoItem('Configuración inicial de la empresa', '5 min'),
            _VideoItem('Cómo importar productos desde Excel', '3 min'),
            _VideoItem('Gestión de pedidos paso a paso', '7 min'),
            _VideoItem('Configuración de empleados y límites', '4 min'),
            _VideoItem('Trucos y consejos avanzados', '10 min'),
            SizedBox(height: 16),
            Text('📺 Los tutoriales estarán disponibles en nuestro canal de YouTube próximamente.',
              style: TextStyle(fontSize: 12, color: AppTheme.secondaryTextColor)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _sendFeedback(BuildContext context) {
    final feedbackController = TextEditingController();
    String selectedType = 'suggestion';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.feedback, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Enviar Comentarios'),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Nos encantaría conocer tu experiencia:'),
              const SizedBox(height: 16),
              
              // Tipo de feedback
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(
                  labelText: 'Tipo de comentario',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'suggestion', child: Text('💡 Sugerencia')),
                  DropdownMenuItem(value: 'compliment', child: Text('👏 Felicitación')),
                  DropdownMenuItem(value: 'complaint', child: Text('😟 Queja')),
                  DropdownMenuItem(value: 'feature', child: Text('🚀 Nueva función')),
                ],
                onChanged: (value) => setState(() => selectedType = value!),
              ),
              const SizedBox(height: 16),
              
              // Comentario
              TextField(
                controller: feedbackController,
                decoration: InputDecoration(
                  hintText: 'Escribe tus comentarios aquí...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (feedbackController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Comentarios enviados. ¡Gracias!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  void _reportBug(BuildContext context) {
    final bugController = TextEditingController();
    String selectedSeverity = 'low';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.bug_report, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Reportar Problema'),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Describe el problema que encontraste:'),
              const SizedBox(height: 16),
              
              // Severidad
              DropdownButtonFormField<String>(
                value: selectedSeverity,
                decoration: InputDecoration(
                  labelText: 'Gravedad del problema',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('🟢 Leve')),
                  DropdownMenuItem(value: 'medium', child: Text('🟡 Moderado')),
                  DropdownMenuItem(value: 'high', child: Text('🟠 Importante')),
                  DropdownMenuItem(value: 'critical', child: Text('🔴 Crítico')),
                ],
                onChanged: (value) => setState(() => selectedSeverity = value!),
              ),
              const SizedBox(height: 16),
              
              // Descripción del problema
              TextField(
                controller: bugController,
                decoration: InputDecoration(
                  hintText: 'Describe qué pasó, cuándo ocurrió y qué esperabas que pasara...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 4,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (bugController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🐛 Reporte enviado. Lo revisaremos pronto.'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reportar'),
          ),
        ],
      ),
    );
  }
}

// Widgets auxiliares
class _HelpItem extends StatelessWidget {
  final String question;
  final String answer;
  
  const _HelpItem(this.question, this.answer);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• $question', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          const SizedBox(height: 2),
          Text('  $answer', style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String tip;
  
  const _TipItem(this.tip);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: AppTheme.primaryColor, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  
  const _ContactItem(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
            Text(value, style: const TextStyle(color: AppTheme.secondaryTextColor, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _VideoItem extends StatelessWidget {
  final String title;
  final String duration;
  
  const _VideoItem(this.title, this.duration);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.play_circle, color: AppTheme.primaryColor, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 13))),
          Text(duration, style: const TextStyle(fontSize: 11, color: AppTheme.secondaryTextColor)),
        ],
      ),
    );
  }
}
