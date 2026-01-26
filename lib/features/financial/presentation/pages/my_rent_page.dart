import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/pdf_generator_service.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/rent_contract.dart';
import '../../domain/entities/rent_payment.dart';
import '../../domain/entities/contract_context.dart';
import '../bloc/fintech_bloc.dart';

class MyRentPage extends StatelessWidget {
  final RentContract contract;

  const MyRentPage({super.key, required this.contract});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<FintechBloc>()..add(LoadPaymentCalendar(contract)),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundDark,
          title: const Text('Mi Renta'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<FintechBloc, FintechState>(
          builder: (context, state) {
            if (state is FintechLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FintechError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is FintechCalendarLoaded) {
              return _buildCalendar(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context, FintechCalendarLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderDark),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Renta Mensual',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${state.contract.monthlyRent.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Día de Pago',
                        style: TextStyle(
                            color: AppTheme.primaryColor, fontSize: 12),
                      ),
                      Text(
                        state.contract.paymentDay.toString(),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Calendar Grid
          const Text(
            'Calendario de Pagos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: state.payments.length,
            itemBuilder: (context, index) {
              final payment = state.payments[index];
              return _buildPaymentCard(context, payment, state.context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, RentPayment payment,
      ContractContext contractContext) {
    final isPaid = payment.status == 'paid';
    final isOverdue = payment.status == 'overdue';

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.schedule_rounded;
    String statusText = 'Pendiente';

    if (isPaid) {
      statusColor = AppTheme.successColor;
      statusIcon = Icons.receipt_long_rounded;
      statusText = 'Pagado';
    } else if (isOverdue) {
      statusColor = AppTheme.errorColor;
      statusIcon = Icons.warning_rounded;
      statusText = 'Vencido';
    } else {
      statusColor = AppTheme.warningColor;
      statusIcon = Icons.payment_rounded;
      statusText = contractContext.canPay ? 'Pagar' : 'Por Cobrar';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? AppTheme.successColor.withOpacity(0.3)
              : AppTheme.borderDark,
          width: isPaid ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isPaid) {
              _showReceipt(context, payment);
            } else if (contractContext.canPay) {
              _showPaymentSheet(context, payment);
            } else {
              // Host view: show details or nothing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Vista de anfitrión: Pago pendiente del inquilino'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getMonthName(payment.dueDate.month),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${payment.dueDate.day}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReceipt(BuildContext context, RentPayment payment) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Generando recibo PDF...'),
        backgroundColor: AppTheme.primaryColor,
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final pdfService = getIt<PdfGeneratorService>();
      await pdfService.generateRentReceipt(
        paymentId: payment.id,
        amount: payment.grossAmount,
        date: payment.dueDate,
        contractId: contract.id,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generando recibo: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showPaymentSheet(BuildContext context, RentPayment payment) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.credit_card_rounded,
                size: 48, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Confirmar Pago',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Se procesará el cobro de \$${payment.grossAmount.toStringAsFixed(2)} de tu tarjeta terminada en 4242.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  // Trigger payment simulation
                  context.read<FintechBloc>().add(SimulatePayment(payment));

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pago procesado correctamente'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Pagar Ahora',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months[month - 1];
  }
}
