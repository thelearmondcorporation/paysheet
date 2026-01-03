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
              await Paysheet.instance.present(
                context,
                method: 'card',
                amount: '9.99',
                onPay: () async {
                  // Example: app builders should call their server or SDK here.
                  // This example simply waits for a short duration then returns.
                  await Future.delayed(Duration(seconds: 1));
                },
                uiAdjust: UIAdjust(u: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: const [],
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
              );
            },
          ),
        ),
      ),
    );
  }
}
