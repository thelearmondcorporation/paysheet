import 'package:flutter/material.dart';

/// Styling-only paysheet: all payment logic and inputs removed.

class PaymentResult {
  final bool success;
  final String? error;
  final String? errorMessage;

  const PaymentResult({
    required this.success,
    this.error,
    this.errorMessage,
  });
}

/// Convenience singleton that exposes a stable public API:
/// `Paysheet.instance.present(...)` shows the paysheet directly.
class Paysheet {
  Paysheet._();
  static final Paysheet instance = Paysheet._();

  Future<PaymentResult?> present(
    BuildContext context, {
    required String method,
    String? amount,
    Map<String, dynamic>? merchantArgs,
    bool mountOnShow = false,
    bool enableStripeJs = false,
    void Function(PaymentResult)? onResult,
    Future<void> Function()? onPay,
  }) {
    return showModalBottomSheet<PaymentResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: _StylingPaysheet(
                method: method,
                amount: amount,
                merchantArgs: merchantArgs,
                scrollController: scrollController,
                onResult: (r) => onResult?.call(r),
                onPay: onPay,
              ),
            );
          },
        );
      },
    );
  }
}

String _formatAmountFromCents(int cents, {String currency = 'USD'}) {
  final dollars = (cents / 100).toStringAsFixed(2);
  if (currency.toUpperCase() == 'USD') return '\$$dollars';
  return '$dollars $currency';
}

Map<String, dynamic> computeEffectiveMerchantArgs({
  Map<String, dynamic>? merchantArgs,
  String? amount,
  String? merchantId,
  String? merchantName,
  String? merchantInfo,
  List<dynamic>? summaryItems,
}) {
  if (merchantArgs != null) return merchantArgs;
  final items = <dynamic>[];
  if (summaryItems != null) items.addAll(summaryItems);
  if (items.isEmpty && amount != null) {
    final parsed = double.tryParse(amount) ?? 0.0;
    items.add({'label': 'Total', 'amountCents': (parsed * 100).round()});
  }
  return {
    'merchantName': merchantName ?? merchantId ?? 'Merchant',
    'merchantInfo': merchantInfo ?? '',
    'summaryItems': items,
  };
}

// Top-level `showLpePaysheet` removed; use `Paysheet.instance.present(...)`.
class _StylingPaysheet extends StatelessWidget {
  final String method;
  final String? amount;
  final Map<String, dynamic>? merchantArgs;
  final ScrollController? scrollController;
  final void Function(PaymentResult) onResult;
  final Future<void> Function()? onPay;

  const _StylingPaysheet({
    Key? key,
    required this.method,
    this.amount,
    this.merchantArgs,
    this.scrollController,
    required this.onResult,
    this.onPay,
  }) : super(key: key);

  Widget _merchantHeader(String? merchantName, String? merchantInfo) {
    return Material(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              merchantName ?? 'Merchant',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if ((merchantInfo ?? '').isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                merchantInfo ?? '',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _summarySection(List<dynamic> summaryItems) {
    if (summaryItems.isEmpty) return const SizedBox.shrink();
    final children = <Widget>[];
    children.add(
      const Text('Summary', style: TextStyle(color: Colors.black54)),
    );
    children.add(const SizedBox(height: 8));
    for (final s in summaryItems) {
      try {
        final label = s['label']?.toString() ?? 'Item';
        final amountCents =
            (s['amountCents'] is int) ? s['amountCents'] as int : 0;
        final amount = _formatAmountFromCents(amountCents);
        children.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(label), Text(amount)],
            ),
          ),
        );
      } catch (_) {}
    }
    children.add(const SizedBox(height: 12));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effective = computeEffectiveMerchantArgs(
      merchantArgs: merchantArgs,
      amount: amount,
    );
    final merchantName = (effective['merchantName'] ?? 'Merchant') as String?;
    final merchantInfo = (effective['merchantInfo'] ?? '') as String?;
    final List<dynamic> summaryItems = (effective['summaryItems'] is List)
        ? effective['summaryItems'] as List
        : [];

    return SafeArea(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: Material(
          color: Colors.white,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _merchantHeader(merchantName, merchantInfo),
                const SizedBox(height: 12),
                _summarySection(summaryItems),
                const SizedBox(height: 28),
                Center(
                  child: SizedBox(
                    width: 110.0,
                    child: ElevatedButton(
                      onPressed: onPay != null
                          ? () async {
                              try {
                                await onPay!();
                              } catch (_) {}
                            }
                          : () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 8.0,
                        ),
                        shape: const StadiumBorder(),
                        textStyle: const TextStyle(fontSize: 14.0),
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        elevation: 3,
                      ),
                      child: const Text('Pay'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
