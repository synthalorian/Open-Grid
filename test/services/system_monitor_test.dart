import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:open_grid/services/system_monitor.dart';

void main() {
  group('SystemMonitor', () {
    test('reads system snapshot on Linux', () async {
      if (!Platform.isLinux) return; // skip on non-Linux

      final monitor = SystemMonitor();
      // First read to initialize deltas
      await monitor.read();
      // Second read gets actual delta-based values
      final snapshot = await monitor.read();

      expect(snapshot.hostname, isNotEmpty);
      expect(snapshot.kernel, contains('Linux'));
      expect(snapshot.uptimeSeconds, greaterThan(0));
      expect(snapshot.memory.totalBytes, greaterThan(0));
      expect(snapshot.cpu.coreCount, greaterThan(0));
      expect(snapshot.cpu.perCoreUsage.length, snapshot.cpu.coreCount);
      expect(snapshot.disks, isNotEmpty);
    });

    test('consecutive reads produce valid CPU deltas', () async {
      if (!Platform.isLinux) return;

      final monitor = SystemMonitor();
      await monitor.read();
      await Future.delayed(const Duration(milliseconds: 100));
      final snapshot = await monitor.read();

      expect(snapshot.cpu.usagePercent, greaterThanOrEqualTo(0));
      expect(snapshot.cpu.usagePercent, lessThanOrEqualTo(100));
    });
  });
}
