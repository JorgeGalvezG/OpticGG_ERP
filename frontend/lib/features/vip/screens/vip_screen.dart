import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // No olvides: flutter pub add url_launcher
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../pacientes/providers/pacientes_provider.dart';
import '../../pacientes/models/paciente_model.dart';

class VipScreen extends StatefulWidget {
  const VipScreen({super.key});

  @override
  State<VipScreen> createState() => _VipScreenState();
}

class _VipScreenState extends State<VipScreen> {
  // 1. SET PARA CONTROLAR LA SELECCIÓN MÚLTIPLE DINÁMICA
  final Set<int> _seleccionados = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tienda = Provider.of<AuthProvider>(context, listen: false).tienda ?? 'C1';
      Provider.of<PacientesProvider>(context, listen: false).fetchPacientesVip(tienda);
    });
  }

  // 2. LÓGICA DE ENVÍO SELECTIVO POR WHATSAPP
  void _enviarPromociones(List<Paciente> seleccionados) async {
    for (var p in seleccionados) {
      final String mensaje = "¡Hola ${p.nombre}! ✨ Te saludamos de OpticGG. Por ser uno de nuestros clientes VIP, tienes un beneficio exclusivo del 20% en tus próximas resinas. ¡Te esperamos!";

      // Limpiamos el número (asumiendo formato Perú +51)
      final String phone = p.telefono?.replaceAll(RegExp(r'\D'), '') ?? '';
      if (phone.isEmpty) continue;

      final Uri url = Uri.parse("https://wa.me/51$phone?text=${Uri.encodeComponent(mensaje)}");

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
      // Delay de medio segundo para no saturar el sistema operativo al abrir pestañas
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Consumer<PacientesProvider>(
      builder: (context, provider, child) {
        final vips = provider.pacientesVip;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABECERA VIP DINÁMICA
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.warning, size: 28),
                          const SizedBox(width: 8),
                          const Text('Pacientes VIP',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.gray900)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('${_seleccionados.length} seleccionados para promoción',
                          style: const TextStyle(fontSize: 13, color: AppColors.gray500, fontWeight: FontWeight.w600)),
                    ],
                  ),

                  // BOTÓN DE ACCIÓN SELECTIVA
                  ElevatedButton.icon(
                    onPressed: _seleccionados.isEmpty
                        ? null
                        : () {
                      final listaAEnviar = vips.where((p) => _seleccionados.contains(p.id)).toList();
                      _enviarPromociones(listaAEnviar);
                    },
                    icon: const Icon(Icons.chat_rounded, size: 20),
                    label: Text(isMobile ? 'Enviar' : 'Enviar Promoción Seleccionada'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.gray200,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),

            // LISTA DE VIPs CON SELECCIÓN
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24.0).copyWith(bottom: 24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.warning))
                    : vips.isEmpty
                    ? const Center(child: Text('Aún no tienes clientes VIP registrados', style: TextStyle(color: AppColors.gray500)))
                    : ListView.separated(
                  itemCount: vips.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.gray100),
                  itemBuilder: (context, index) {
                    final paciente = vips[index];
                    final isSelected = _seleccionados.contains(paciente.id);

                    return CheckboxListTile(
                      value: isSelected,
                      activeColor: AppColors.warning,
                      checkColor: Colors.black87,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text('${paciente.nombre} ${paciente.apellidos}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      subtitle: Text('Cel: ${paciente.telefono} | Nac: ${paciente.fechaNacimiento ?? "N/A"}'),
                      secondary: isMobile ? null : _buildBadgeVip(),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _seleccionados.add(paciente.id!);
                          } else {
                            _seleccionados.remove(paciente.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBadgeVip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.stars_rounded, color: AppColors.warning, size: 14),
          SizedBox(width: 4),
          Text('VIP', style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}