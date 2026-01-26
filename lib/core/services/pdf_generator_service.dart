import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../../features/listings/domain/entities/listing_entity.dart';
import '../../features/requests/domain/entities/listing_request_entity.dart';
import 'package:intl/intl.dart';

class PdfGeneratorService {
  // Colores de Marca (Estilo Startup Moderna)
  static const PdfColor _primaryColor =
      PdfColor.fromInt(0xff263238); // Dark Grey
  static const PdfColor _accentColor =
      PdfColor.fromInt(0xff00BFA5); // Teal Accent
  static const PdfColor _textLightColor =
      PdfColor.fromInt(0xff78909c); // Blue Grey
  static const PdfColor _lightBackground =
      PdfColor.fromInt(0xfff5f7f8); // Very light grey

  // CORRECCIÓN: Colores mucho más sutiles (más transparentes) para la marca de agua
  // Alpha bajado a 0.05 (5%) y 0.1 (10%) para que no tape el texto
  static const PdfColor _watermarkColor = PdfColor(0, 0.5, 0, 0.05);
  static const PdfColor _watermarkBorderColor = PdfColor(0, 0.5, 0, 0.1);

  Future<void> generateAcceptanceLetter({
    required ListingEntity listing,
    required ListingRequestEntity request,
    required UserEntity host,
  }) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final fontSemiBold = await PdfGoogleFonts.interMedium();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              _buildWatermark(fontBold),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildHeader(fontBold, request.id),
                  pw.SizedBox(height: 40),
                  _buildIntro(fontRegular),
                  pw.SizedBox(height: 30),
                  _buildPeopleSection(
                      host, request, fontBold, fontRegular, fontSemiBold),
                  pw.SizedBox(height: 30),
                  _buildPropertySection(
                      listing, fontBold, fontRegular, fontSemiBold),
                  pw.Spacer(),
                  _buildSignatures(host, request, fontRegular),
                  _buildFooter(fontRegular),
                ],
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Haus_PreContrato_${request.id.substring(0, 6)}.pdf',
    );
  }

  Future<void> generateRentReceipt({
    required String paymentId,
    required double amount,
    required DateTime date,
    required String contractId,
  }) async {
    final pdf = pw.Document();
    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5, // Recibo pequeño
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _primaryColor, width: 2),
              borderRadius: pw.BorderRadius.circular(10),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text('RECIBO DE PAGO',
                      style: pw.TextStyle(
                          font: fontBold, fontSize: 20, color: _primaryColor)),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                _buildInfoRow(
                    'Recibo #',
                    paymentId.substring(0, 8).toUpperCase(),
                    fontRegular,
                    fontBold),
                pw.SizedBox(height: 10),
                _buildInfoRow(
                    'Contrato #',
                    contractId.substring(0, 8).toUpperCase(),
                    fontRegular,
                    fontBold),
                pw.SizedBox(height: 10),
                _buildInfoRow('Fecha', DateFormat('dd MMM yyyy').format(date),
                    fontRegular, fontBold),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('TOTAL PAGADO',
                        style: pw.TextStyle(font: fontBold, fontSize: 14)),
                    pw.Text('\$${amount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                            font: fontBold, fontSize: 24, color: _accentColor)),
                  ],
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text('Gracias por tu pago',
                      style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 10,
                          color: _textLightColor)),
                ),
                pw.Center(
                  child: pw.Text('HAUS App',
                      style: pw.TextStyle(
                          font: fontBold, fontSize: 12, color: _primaryColor)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Haus_Recibo_${paymentId.substring(0, 6)}.pdf',
    );
  }

  pw.Widget _buildHeader(pw.Font fontBold, String requestId) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: const pw.BoxDecoration(
                color: _primaryColor,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text('HAUS',
                  style: pw.TextStyle(
                      font: fontBold, color: PdfColors.white, fontSize: 20)),
            ),
            pw.SizedBox(height: 4),
            pw.Text('Conecta. Comparte. Vive.',
                style: const pw.TextStyle(color: _textLightColor, fontSize: 8)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('CARTA DE ACEPTACIÓN',
                style: pw.TextStyle(
                    font: fontBold, fontSize: 14, color: _textLightColor)),
            pw.Text('#${requestId.substring(0, 8).toUpperCase()}',
                style: pw.TextStyle(
                    font: fontBold, fontSize: 10, color: _accentColor)),
          ],
        )
      ],
    );
  }

  pw.Widget _buildIntro(pw.Font fontRegular) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: const pw.BoxDecoration(
        border: pw.Border(left: pw.BorderSide(color: _accentColor, width: 3)),
        color: _lightBackground,
      ),
      child: pw.Text(
        'Por medio de la presente, se hace constar que el Propietario ha evaluado y aprobado satisfactoriamente la solicitud de arrendamiento presentada por el Solicitante. Este documento formaliza la intención firme de ambas partes de proceder con la firma del contrato de arrendamiento definitivo, sujeto a los términos y condiciones aquí detallados, los cuales han sido revisados y aceptados preliminarmente en la plataforma HAUS.',
        style: pw.TextStyle(
            font: fontRegular,
            fontSize: 10,
            color: _primaryColor,
            lineSpacing: 1.5),
        textAlign: pw.TextAlign.justify,
      ),
    );
  }

  pw.Widget _buildPeopleSection(UserEntity host, ListingRequestEntity request,
      pw.Font fontBold, pw.Font fontRegular, pw.Font fontSemiBold) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('ANFITRIÓN (PROPIETARIO)',
                  style: pw.TextStyle(
                      font: fontBold, fontSize: 9, color: _textLightColor)),
              pw.SizedBox(height: 4),
              pw.Text(host.displayName.toUpperCase(),
                  style: pw.TextStyle(
                      font: fontBold, fontSize: 12, color: _primaryColor)),
              pw.Text(host.email,
                  style: pw.TextStyle(
                      font: fontRegular, fontSize: 10, color: _primaryColor)),
            ],
          ),
        ),
        pw.Container(
            width: 1,
            height: 30,
            color: PdfColors.grey300,
            margin: const pw.EdgeInsets.symmetric(horizontal: 20)),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('SOLICITANTE (INQUILINO)',
                  style: pw.TextStyle(
                      font: fontBold, fontSize: 9, color: _textLightColor)),
              pw.SizedBox(height: 4),
              pw.Text(request.requesterName?.toUpperCase() ?? 'DESCONOCIDO',
                  style: pw.TextStyle(
                      font: fontBold, fontSize: 12, color: _primaryColor)),
              pw.Text('ID Verificado: ${request.requesterId.substring(0, 8)}',
                  style: pw.TextStyle(
                      font: fontRegular, fontSize: 10, color: _primaryColor)),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildPropertySection(ListingEntity listing, pw.Font fontBold,
      pw.Font fontRegular, pw.Font fontSemiBold) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey200),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: const pw.BoxDecoration(
              color: _lightBackground,
              borderRadius:
                  pw.BorderRadius.vertical(top: pw.Radius.circular(8)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('DETALLES DE LA PROPIEDAD',
                    style: pw.TextStyle(
                        font: fontBold, fontSize: 10, color: _primaryColor)),
                pw.Text(listing.housingType.toUpperCase(),
                    style: pw.TextStyle(
                        font: fontBold, fontSize: 10, color: _accentColor)),
              ],
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(15),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                    'Dirección', listing.address, fontRegular, fontSemiBold),
                pw.Divider(color: PdfColors.grey100),
                _buildInfoRow(
                    'Ubicación',
                    '${listing.neighborhood}, ${listing.city}',
                    fontRegular,
                    fontSemiBold),
                pw.Divider(color: PdfColors.grey100),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Precio Acordado',
                            style: pw.TextStyle(
                                font: fontRegular,
                                fontSize: 9,
                                color: _textLightColor)),
                        pw.Text('\$${listing.price.toStringAsFixed(2)} / mes',
                            style: pw.TextStyle(
                                font: fontBold,
                                fontSize: 16,
                                color: _primaryColor)),
                      ],
                    ),
                    pw.Flexible(
                      child: pw.Wrap(
                        spacing: 5,
                        runSpacing: 5,
                        alignment: pw.WrapAlignment.end,
                        children: listing.amenities
                            .take(4)
                            .map((amenity) => pw.Container(
                                padding: const pw.EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.grey300),
                                    borderRadius: const pw.BorderRadius.all(
                                        pw.Radius.circular(10))),
                                child: pw.Text(amenity,
                                    style: const pw.TextStyle(
                                        fontSize: 8,
                                        color: PdfColors.grey700))))
                            .toList(),
                      ),
                    )
                  ],
                ),
                if (listing.houseRules.isNotEmpty) ...[
                  pw.Divider(color: PdfColors.grey100),
                  pw.SizedBox(height: 5),
                  pw.Text('Reglas de la Casa',
                      style: pw.TextStyle(
                          font: fontRegular,
                          fontSize: 9,
                          color: _textLightColor)),
                  pw.SizedBox(height: 6),
                  pw.Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: listing.houseRules
                        .map((rule) => pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                pw.Container(
                                    width: 4,
                                    height: 4,
                                    decoration: const pw.BoxDecoration(
                                        color: _accentColor,
                                        shape: pw.BoxShape.circle),
                                    margin: const pw.EdgeInsets.only(right: 6)),
                                pw.Text(rule,
                                    style: pw.TextStyle(
                                        font: fontSemiBold,
                                        fontSize: 10,
                                        color: _primaryColor)),
                              ],
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(
      String label, String value, pw.Font fontLabel, pw.Font fontValue) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label,
            style: pw.TextStyle(
                font: fontLabel, fontSize: 10, color: _textLightColor)),
        pw.Text(value,
            style: pw.TextStyle(
                font: fontValue, fontSize: 10, color: _primaryColor)),
      ],
    );
  }

  // CORRECCIÓN: Sello más pequeño y difuminado
  pw.Widget _buildWatermark(pw.Font font) {
    return pw.Positioned(
      bottom: 180, // Ajustado posición
      right: 40,
      child: pw.Transform.rotate(
        angle: -0.3,
        child: pw.Container(
          // Tamaño reducido (padding más pequeño)
          padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: pw.BoxDecoration(
            // Borde más fino y transparente
            border: pw.Border.all(color: _watermarkBorderColor, width: 2),
            borderRadius: pw.BorderRadius.circular(12),
          ),
          child: pw.Text(
            'APROBADO',
            style: pw.TextStyle(
              font: font,
              fontSize: 30, // Fuente más pequeña (antes 50)
              color: _watermarkColor,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  pw.Widget _buildSignatures(
      UserEntity host, ListingRequestEntity request, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildSignatureLine(host.displayName, 'Anfitrión', font),
        _buildSignatureLine(
            request.requesterName ?? 'Inquilino', 'Solicitante', font),
      ],
    );
  }

  pw.Widget _buildSignatureLine(String name, String role, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(width: 180, height: 1, color: PdfColors.black),
        pw.SizedBox(height: 8),
        pw.Text(name,
            style: pw.TextStyle(
                font: font, fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.Text(role.toUpperCase(),
            style:
                pw.TextStyle(font: font, fontSize: 8, color: _textLightColor)),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Font font) {
    final date = DateFormat('dd MMM yyyy').format(DateTime.now());
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 30),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: PdfColors.grey200))),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Generado automáticamente por HAUS App',
              style: pw.TextStyle(
                  font: font, fontSize: 8, color: _textLightColor)),
          pw.Text('Fecha de emisión: $date',
              style: pw.TextStyle(
                  font: font, fontSize: 8, color: _textLightColor)),
        ],
      ),
    );
  }
}
