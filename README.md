 # paysheet

A lightweight, styling-only paysheet widget for Flutter apps. This package
provides a minimal bottom-sheet paysheet UI intended for SDK / merchant
integration where the host app handles payment interactions.

## Features

- Stylized paysheet layout with merchant header and summary list
- Lightweight `Paysheet.instance.present` API
- Example app included

## Quick example

```dart
await Paysheet.instance.present(
  context,
  method: 'card',
  amount: '9.99',
  onPay: () async {
    // call your server side integration here
  },
);
```

## Styling & Widgets (`_u`)

`paysheet` exposes a lightweight `UIAdjust` configuration object that lets
host apps customize the sheet's visual appearance and inject custom UI
widgets into the paysheet body. The most common use is adding input controls
such as a single-line card entry (card number, expiry, CVV) using the
optional `u` parameter which accepts a `List<Widget>`.

Key `UIAdjust` fields:

- `u` : `List<Widget>?` — optional list of widgets to render inside the
  paysheet (rendered where the summary ends). Useful for custom inputs.
- `backgroundColor` : `Color?` — sheet background color (whitespace only).
- `sheetCornerRadius` : `double?` — corner radius for the header card.
- `merchantHeaderColor`, `merchantHeaderElevation` — header styling.
- `buttonBackgroundColor`, `buttonForegroundColor`, `buttonTextStyle` — pay
  button appearance.
- `contentPadding` : `EdgeInsets?` — outer padding for the sheet content.

The paysheet merges your `UIAdjust` with the package defaults via
`UIAdjust.defaults.merge(uiAdjust)` so you only need to provide overrides.

Example: inject a single-line card field (card number | MM/YY | CVV)

```dart
await Paysheet.instance.present(
  context,
  method: 'card',
  amount: '1.00',
  uiAdjust: UIAdjust(u: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Card number',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextField(
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'MM/YY',
                ),
                keyboardType: TextInputType.datetime,
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 70,
              child: TextField(
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'CVV',
                ),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
            ),
          ],
        ),
      ),
    ),
  ]),
  onPay: () async {
    // perform your payment action
  },
);
```

Notes:

- Prefer white or neutral backgrounds for injected widgets to match the
  package's default look and avoid strong color clashes.
- The `u` widgets are placed after the summary and before the Pay button.
- If you need to programmatically read values from injected inputs, manage
  controllers or state within your own widgets and use the `onPay` callback
  to read them.

## License
MIT

## Author

The Learmond Corporation



