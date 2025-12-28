 # paysheet

A lightweight, styling-only paysheet widget for Flutter apps. This package
provides a minimal bottom-sheet paysheet UI intended for SDK / merchant
integration where the host app handles payment interactions.

## Features

- Stylized paysheet layout with merchant header and summary list
- Lightweight `showLpePaysheet` API
- Exposes the `onPay` API for easy server side integration.
- Example app included

## Quick example

```dart
await showLpePaysheet(
  context,
  publishableKey: 'pk_test_xxx',
  method: 'card',
  amount: '9.99',
  onPay: () async {
    // call your server or stripe integration here
  },
);
```

## License
MIT

## Author 
The Learmond Corporation



