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

## License
MIT

## Author
The Learmond Corporation



