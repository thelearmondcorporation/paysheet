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

/// Optional UI adjust configuration for the paysheet UI.
class UIAdjust {
  final Color? backgroundColor;
  final double? sheetCornerRadius;
  final Color? merchantHeaderColor;
  final double? merchantHeaderElevation;
  final TextStyle? merchantNameTextStyle;
  final TextStyle? merchantInfoTextStyle;
  final TextStyle? summaryTitleTextStyle;
  final TextStyle? summaryItemTextStyle;
  final Color? buttonBackgroundColor;
  final Color? buttonForegroundColor;
  final TextStyle? buttonTextStyle;
  final EdgeInsets? contentPadding;
  final List<Widget>? _u;

  /// Optional configuration and an optional `u` list of widgets.
  const UIAdjust({
    List<Widget>? u,
    this.backgroundColor,
    this.sheetCornerRadius,
    this.merchantHeaderColor,
    this.merchantHeaderElevation,
    this.merchantNameTextStyle,
    this.merchantInfoTextStyle,
    this.summaryTitleTextStyle,
    this.summaryItemTextStyle,
    this.buttonBackgroundColor,
    this.buttonForegroundColor,
    this.buttonTextStyle,
    this.contentPadding,
  }) : _u = u;

  /// Default UI adjust used by the paysheet. Backgrounds/button backgrounds
  /// are always white by design; never use blue as a background.
  static const UIAdjust defaults = UIAdjust(
    u: null,
    backgroundColor: Colors.white,
    sheetCornerRadius: 16.0,
    merchantHeaderColor: Colors.white,
    merchantHeaderElevation: 4.0,
    merchantNameTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    merchantInfoTextStyle: TextStyle(color: Colors.black54),
    summaryTitleTextStyle: TextStyle(color: Colors.black54),
    summaryItemTextStyle: TextStyle(),
    buttonBackgroundColor: Colors.white,
    buttonForegroundColor: Colors.black,
    buttonTextStyle: TextStyle(fontSize: 14.0),
    contentPadding: EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 16),
  );

  /// Merge user-provided ui adjust with defaults; user values override defaults
  /// except for background/button backgrounds which remain white and blue
  /// values are ignored.
  UIAdjust merge(UIAdjust? other) {
    final d = UIAdjust.defaults;
    if (other == null) return d;

    Color sanitizeBackground(Color? c) {
      if (c == null) return d.backgroundColor!;
      if (c == Colors.blue) return Colors.white;
      return c;
    }

    Color sanitizeButtonBg(Color? c) => Colors.white;

    Color sanitizeMerchantHeader(Color? c) {
      if (c == null) return d.merchantHeaderColor!;
      if (c == Colors.blue) return Colors.white;
      return c;
    }

    Color sanitizeForeground(Color? c) {
      if (c == null) return d.buttonForegroundColor!;
      if (c == Colors.blue) return Colors.black;
      return c;
    }

    return UIAdjust(
      u: other._u ?? d._u,
      backgroundColor: sanitizeBackground(other.backgroundColor ?? d.backgroundColor),
      sheetCornerRadius: other.sheetCornerRadius ?? d.sheetCornerRadius,
      merchantHeaderColor: sanitizeMerchantHeader(other.merchantHeaderColor ?? d.merchantHeaderColor),
      merchantHeaderElevation: other.merchantHeaderElevation ?? d.merchantHeaderElevation,
      merchantNameTextStyle: other.merchantNameTextStyle ?? d.merchantNameTextStyle,
      merchantInfoTextStyle: other.merchantInfoTextStyle ?? d.merchantInfoTextStyle,
      summaryTitleTextStyle: other.summaryTitleTextStyle ?? d.summaryTitleTextStyle,
      summaryItemTextStyle: other.summaryItemTextStyle ?? d.summaryItemTextStyle,
      buttonBackgroundColor: sanitizeButtonBg(other.buttonBackgroundColor ?? d.buttonBackgroundColor),
      buttonForegroundColor: sanitizeForeground(other.buttonForegroundColor ?? d.buttonForegroundColor),
      buttonTextStyle: other.buttonTextStyle ?? d.buttonTextStyle,
      contentPadding: other.contentPadding ?? d.contentPadding,
    );
  }
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
    UIAdjust? uiAdjust,
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
                child: _UIAdjustPaysheet(
                method: method,
                amount: amount,
                merchantArgs: merchantArgs,
                  uiAdjust: uiAdjust,
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
class _UIAdjustPaysheet extends StatelessWidget {
  final String method;
  final String? amount;
  final Map<String, dynamic>? merchantArgs;
  final UIAdjust? uiAdjust;
  final ScrollController? scrollController;
  final void Function(PaymentResult) onResult;
  final Future<void> Function()? onPay;

  const _UIAdjustPaysheet({
    Key? key,
    required this.method,
    this.amount,
    this.merchantArgs,
    this.uiAdjust,
    this.scrollController,
    required this.onResult,
    this.onPay,
  }) : super(key: key);



  Widget _summarySection(List<dynamic> summaryItems, UIAdjust style) {
    if (summaryItems.isEmpty) return const SizedBox.shrink();
    final children = <Widget>[];
    children.add(
      Text('Summary', style: style.summaryTitleTextStyle ?? const TextStyle(color: Colors.black54)),
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
              children: [Text(label, style: style.summaryItemTextStyle), Text(amount, style: style.summaryItemTextStyle)],
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
    final effectiveStyle = UIAdjust.defaults.merge(uiAdjust);
    final merchantName = (effective['merchantName'] ?? 'Merchant') as String?;
    final merchantInfo = (effective['merchantInfo'] ?? '') as String?;
    final List<dynamic> summaryItems = (effective['summaryItems'] is List)
        ? effective['summaryItems'] as List
        : [];
    final basePadding = effectiveStyle.contentPadding ?? const EdgeInsets.only(bottom: 16, left: 16, right: 16, top: 16);
    final padding = basePadding.copyWith(bottom: basePadding.bottom + MediaQuery.of(context).viewInsets.bottom);

    return SafeArea(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 520),
        child: Material(
          color: effectiveStyle.backgroundColor,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  elevation: effectiveStyle.merchantHeaderElevation ?? 4,
                  color: effectiveStyle.merchantHeaderColor ?? Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(effectiveStyle.sheetCornerRadius ?? 12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          merchantName ?? 'Merchant',
                          style: effectiveStyle.merchantNameTextStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if ((merchantInfo ?? '').isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            merchantInfo ?? '',
                            style: effectiveStyle.merchantInfoTextStyle ?? const TextStyle(color: Colors.black54),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _summarySection(summaryItems, effectiveStyle),
                const SizedBox(height: 12),
                // Render any user-provided u supplied to `UIAdjust`
                if (uiAdjust?._u != null) ...uiAdjust!._u!,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                        shape: const StadiumBorder(),
                        textStyle: effectiveStyle.buttonTextStyle ?? const TextStyle(fontSize: 14.0),
                        backgroundColor: effectiveStyle.buttonBackgroundColor ?? Colors.white,
                        foregroundColor: effectiveStyle.buttonForegroundColor ?? Colors.black,
                        elevation: 3,
                      ),
                      child: Text('Pay', style: effectiveStyle.buttonTextStyle ?? const TextStyle(fontSize: 14.0)),
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
