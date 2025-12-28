import 'package:flutter/material.dart';
import 'package:paysheet/paysheet.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Paysheet Example',
      home: Scaffold(
        appBar: AppBar(title: Text('Paysheet Example')),
        body: Center(
          child: ElevatedButton(
            child: Text('Open Paysheet'),
            onPressed: () async {
              await showLpePaysheet(
                context,
                publishableKey: 'pk_test_example',
                method: 'card',
                amount: '9.99',
                onPay: () async {
                  // Example: app builders should call their server or SDK here.
                  // This example simply waits for a short duration then returns.
                  await Future.delayed(Duration(seconds: 1));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
