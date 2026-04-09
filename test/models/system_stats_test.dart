import 'package:flutter_test/flutter_test.dart';
import 'package:open_grid/models/system_stats.dart';

void main() {
  group('MemoryStats', () {
    test('calculates usage percent', () {
      const mem = MemoryStats(totalBytes: 1000, usedBytes: 500);
      expect(mem.usagePercent, 50.0);
    });

    test('handles zero total', () {
      const mem = MemoryStats();
      expect(mem.usagePercent, 0);
      expect(mem.swapPercent, 0);
    });

    test('formats bytes correctly', () {
      const mem = MemoryStats(
        totalBytes: 34359738368, // 32 GB
        usedBytes: 17179869184, // 16 GB
      );
      expect(mem.totalFormatted, contains('GB'));
      expect(mem.usedFormatted, contains('GB'));
    });
  });

  group('DiskStats', () {
    test('calculates usage percent', () {
      const disk = DiskStats(
        mountPoint: '/',
        totalBytes: 1000000000,
        usedBytes: 450000000,
      );
      expect(disk.usagePercent, 45.0);
    });

    test('handles zero total', () {
      const disk = DiskStats();
      expect(disk.usagePercent, 0);
    });
  });

  group('CpuStats', () {
    test('defaults to zero', () {
      const cpu = CpuStats();
      expect(cpu.usagePercent, 0);
      expect(cpu.coreCount, 0);
      expect(cpu.perCoreUsage, isEmpty);
    });
  });

  group('SystemSnapshot', () {
    test('creates with defaults', () {
      final snapshot = SystemSnapshot(timestamp: DateTime.now());
      expect(snapshot.hostname, '');
      expect(snapshot.kernel, '');
      expect(snapshot.uptimeSeconds, 0);
      expect(snapshot.disks, isEmpty);
    });

    test('holds all fields', () {
      final snapshot = SystemSnapshot(
        timestamp: DateTime(2026, 4, 8),
        hostname: 'myhost',
        kernel: 'Linux 6.19',
        uptimeSeconds: 86400,
        cpu: const CpuStats(usagePercent: 42, coreCount: 8),
        memory: const MemoryStats(totalBytes: 16000000000, usedBytes: 8000000000),
        disks: const [
          DiskStats(mountPoint: '/', totalBytes: 1000000000, usedBytes: 500000000),
        ],
      );
      expect(snapshot.hostname, 'myhost');
      expect(snapshot.cpu.coreCount, 8);
      expect(snapshot.memory.usagePercent, 50);
      expect(snapshot.disks.length, 1);
    });
  });
}
