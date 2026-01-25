import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/listings/domain/entities/listing_entity.dart';
import '../../features/requests/domain/entities/listing_request_entity.dart';
import 'package:intl/intl.dart';

class PdfGeneratorService {
  Future<void> generateAcceptanceLetter({
    required ListingEntity listing,
    required ListingRequestEntity request,
    required UserEntity host,
  }) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              _buildWatermark(fontBold),
              _buildContent(
                  context, listing, request, host, fontRegular, fontBold),
            ],
          );
        },
      ),
    );

    // Prompt user to download/print
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Carta_Aceptacion_${request.id}.pdf',
    );
  }

  pw.Widget _buildWatermark(pw.Font font) {
    return pw.Center(
      child: pw.Transform.rotate(
        angle: -0.5,
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.green, width: 5),
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Text(
            'APROBADO',
            style: pw.TextStyle(
              font: font,
              fontSize: 60,
              color: PdfColor(0, 0.5, 0, 0.3),
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  pw.Widget _buildContent(
    pw.Context context,
    ListingEntity listing,
    ListingRequestEntity request,
    UserEntity host,
    pw.Font fontRegular,
    pw.Font fontBold,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final approvalDate = dateFormat.format(DateTime.now());

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Header
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'HAUS',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 24,
                color: PdfColors.blue900,
              ),
            ),
            pw.Text(
              'CARTA DE INTENCIÓN DE ALQUILER',
              style: pw.TextStyle(
                font: fontBold,
                fontSize: 16,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 30),

        // Introduction
        pw.Text(
          'Por medio de la presente, se certifica la intención de alquiler y aprobación de la solicitud realizada a través de la plataforma HAUS.',
          style: pw.TextStyle(font: fontRegular, fontSize: 12),
        ),
        pw.SizedBox(height: 20),

        // Details Grid
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey, width: 0.5),
          children: [
            _buildTableRow('DATOS DEL ANFITRION', '', fontBold, isHeader: true),
            _buildTableRow('Nombre:', host.displayName, fontRegular),
            _buildTableRow('Correo:', host.email, fontRegular),
            _buildTableRow('DATOS DEL INQUILINO', '', fontBold, isHeader: true),
            _buildTableRow(
                'Nombre:', request.requesterName ?? 'N/A', fontRegular),
            _buildTableRow('ID Solicitud:', request.id, fontRegular),
            _buildTableRow('DATOS DEL INMUEBLE', '', fontBold, isHeader: true),
            _buildTableRow('Dirección:', listing.address, fontRegular),
            _buildTableRow('Ciudad/Barrio:',
                '${listing.city}, ${listing.neighborhood}', fontRegular),
            _buildTableRow(
                'Tipo de Inmueble:', listing.housingType, fontRegular),
          ],
        ),
        pw.SizedBox(height: 20),

        // Conditions
        pw.Text(
          'CONDICIONES Y REGLAS',
          style: pw.TextStyle(font: fontBold, fontSize: 14),
        ),
        pw.Divider(),
        pw.Text('Precio Mensual: \$${listing.price.toStringAsFixed(2)}',
            style: pw.TextStyle(font: fontRegular)),
        pw.SizedBox(height: 5),
        pw.Text('Servicios Incluidos (Amenities):',
            style: pw.TextStyle(font: fontBold)),
        pw.Text(listing.amenities.join(', '),
            style: pw.TextStyle(font: fontRegular, color: PdfColors.grey700)),
        pw.SizedBox(height: 5),
        pw.Text('Reglas de la Casa:', style: pw.TextStyle(font: fontBold)),
        pw.Text(listing.houseRules.join(', '),
            style: pw.TextStyle(font: fontRegular, color: PdfColors.grey700)),

        pw.Spacer(),

        // Signatures
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              children: [
                pw.Container(width: 150, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 5),
                pw.Text('Firma del Anfitrión',
                    style: pw.TextStyle(font: fontRegular)),
                pw.Text(host.displayName,
                    style: pw.TextStyle(font: fontRegular, fontSize: 10)),
              ],
            ),
            pw.Column(
              children: [
                pw.Container(width: 150, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 5),
                pw.Text('Firma del Inquilino',
                    style: pw.TextStyle(font: fontRegular)),
                pw.Text(request.requesterName ?? 'Inquilino',
                    style: pw.TextStyle(font: fontRegular, fontSize: 10)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        pw.Center(
          child: pw.Text(
            'Fecha de emisión: $approvalDate',
            style: pw.TextStyle(
                font: fontRegular, fontSize: 10, color: PdfColors.grey),
          ),
        ),
      ],
    );
  }

  pw.TableRow _buildTableRow(String label, String value, pw.Font font,
      {bool isHeader = false}) {
    return pw.TableRow(
      decoration:
          isHeader ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(5),
          child: pw.Text(
            label,
            style: pw.TextStyle(
                font: font,
                fontWeight:
                    isHeader ? pw.FontWeight.bold : pw.FontWeight.normal),
          ),
        ),
        if (!isHeader)
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font),
            ),
          )
        else
          pw.Padding(
            padding: const pw.EdgeInsets.all(5),
            child: pw.Text(''),
          ),
      ],
    );
  }
}
