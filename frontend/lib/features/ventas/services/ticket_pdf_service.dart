import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/orden_trabajo_model.dart';

/// Configuración de sucursales basada en la base de datos (config_tienda)
class _ConfigSucursal {
  final String nombre;
  final String ruc;
  final String direccion;
  final String telefono;

  const _ConfigSucursal({
    required this.nombre,
    required this.ruc,
    required this.direccion,
    required this.telefono,
  });
}

const Map<String, _ConfigSucursal> _sucursales = {
  'C1': _ConfigSucursal(
    nombre: 'OCC PERÚ SAC',
    ruc: '20555499826',
    direccion: 'Av. Abancay 268, Lima',
    telefono: '959 659 340',
  ),
  'C2': _ConfigSucursal(
    nombre: 'Huber Lenin Cubas Romaina',
    ruc: '10803339771',
    direccion: 'Av. Angélica Gamarra 1254, Los Olivos',
    telefono: '959 659 340',
  ),
  'C3': _ConfigSucursal(
    nombre: 'Frank Lenin Cubas Coral',
    ruc: '10738659088',
    direccion: 'Av. Abancay 222, Lima',
    telefono: '959 659 340',
  ),
};

class TicketPdfService {

  static Future<void> imprimirTicket(OrdenTrabajo orden, String tienda) async {
    final sucursal = _sucursales[tienda] ?? _sucursales['C1']!;
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // 1. CABECERA DINÁMICA
              pw.Text('ÓPTICA CUBAS', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text(sucursal.nombre, style: const pw.TextStyle(fontSize: 11)),
              pw.Text('RUC: ${sucursal.ruc}', style: const pw.TextStyle(fontSize: 10)),
              pw.Text(sucursal.direccion, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center),
              pw.Text('Tel: ${sucursal.telefono}', style: const pw.TextStyle(fontSize: 10)),

              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              // 2. DATOS DEL COMPROBANTE
              pw.Text('TICKET DE ATENCIÓN', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              _buildFilaTexto('Orden N°:', orden.numeroOrden),
              _buildFilaTexto('Fecha:', orden.fecha.isNotEmpty ? orden.fecha.substring(0, 10) : 'Hoy'),
              _buildFilaTexto('Paciente:', orden.pacienteNombre),

              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              // 3. DETALLE TÉCNICO
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('DETALLE DEL PEDIDO', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 6),

              if (orden.montura != null && orden.montura!.isNotEmpty)
                _buildFilaTexto('Montura:', orden.esMonturaCliente == true ? '${orden.montura} (Cliente)' : orden.montura!),
              
              if (orden.tipoLuna != null && orden.tipoLuna!.isNotEmpty)
                _buildFilaTexto('Lente:', orden.esLunaCliente == true ? '${orden.tipoLuna} (Cliente)' : orden.tipoLuna!),

              if (orden.graduacionOd != null && orden.graduacionOd!.isNotEmpty)
                _buildFilaTexto('O.D.:', orden.graduacionOd!),
              
              if (orden.graduacionOi != null && orden.graduacionOi!.isNotEmpty)
                _buildFilaTexto('O.I.:', orden.graduacionOi!),

              pw.SizedBox(height: 10),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 8),

              // 4. RESUMEN FINANCIERO
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('RESUMEN DE PAGO', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 6),
              _buildFilaDinero('TOTAL:', orden.montoTotal),
              _buildFilaDinero('A CUENTA:', orden.montoTotal - orden.montoSaldo),
              pw.SizedBox(height: 4),
              _buildFilaDinero('SALDO PENDIENTE:', orden.montoSaldo, isBold: true),

              pw.SizedBox(height: 14),
              pw.Divider(borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 10),

              // 5. PIE DE PÁGINA
              pw.Text('¡Gracias por su preferencia!', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.SizedBox(height: 6),
              pw.Text('Revise su medida antes de retirarse. No hay devoluciones de efectivo una vez iniciado el trabajo en laboratorio.',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 16),

              pw.BarcodeWidget(
                barcode: pw.Barcode.code128(),
                data: orden.numeroOrden,
                width: 160,
                height: 40,
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Ticket_${orden.numeroOrden}.pdf',
    );
  }

  static pw.Widget _buildFilaTexto(String etiqueta, String valor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(etiqueta, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.Flexible(child: pw.Text(valor, style: const pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.right)),
        ],
      ),
    );
  }

  static pw.Widget _buildFilaDinero(String etiqueta, double valor, {bool isBold = false}) {
    final style = isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11) : const pw.TextStyle(fontSize: 10);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(etiqueta, style: style),
          pw.Text('S/ ${valor.toStringAsFixed(2)}', style: style),
        ],
      ),
    );
  }
}