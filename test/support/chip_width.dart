import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Checks that the chip showing [label] is as wide as its text plus its
/// 14 px side paddings, and not the whole row of its Wrap.
void expectHugsLabel(WidgetTester tester, Finder label) {
  final chip = find.ancestor(of: label, matching: find.byType(InkWell)).first;
  expect(tester.getSize(chip).width, tester.getSize(label).width + 28);
}
