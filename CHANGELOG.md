## 2.0.0+4

-  Styling-only paysheet UI
- Includes `onPay` callback so host apps can integrate payment flows
- Package includes `README.md`, and `LICENSE` (MIT)

- Includes `UIAdjust.u` support to inject custom widgets into the paysheet body
	(e.g. single-line card entry: card number / expiry / CVV).
- Examples updated to show `UIAdjust(u: [...])` usage and how to style via
	`UIAdjust` named parameters.
- Example card input visuals: removed border/shadow for a flat look.

