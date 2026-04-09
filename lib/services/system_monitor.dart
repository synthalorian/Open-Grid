import 'dart:io';
import '../models/system_stats.dart';

/// Reads real system stats from /proc and /sys on Linux.
/// Falls back to zeros on non-Linux platforms.
class SystemMonitor {
  List<int>? _prevCpuTotal;
  List<int>? _prevCpuIdle;
  int? _prevNetRx;
  int? _prevNetTx;

  Future<SystemSnapshot> read() async {
    return SystemSnapshot(
      timestamp: DateTime.now(),
      hostname: await _readHostname(),
      kernel: await _readKernel(),
      uptimeSeconds: await _readUptime(),
      cpu: await _readCpu(),
      gpu: await _readGpu(),
      memory: await _readMemory(),
      network: await _readNetwork(),
      disks: await _readDisks(),
    );
  }

  Future<String> _readHostname() async {
    try {
      return (await File('/etc/hostname').readAsString()).trim();
    } catch (_) {
      return Platform.localHostname;
    }
  }

  Future<String> _readKernel() async {
    try {
      final result = await Process.run('uname', ['-r']);
      return 'Linux ${(result.stdout as String).trim()}';
    } catch (_) {
      return '';
    }
  }

  Future<double> _readUptime() async {
    try {
      final content = await File('/proc/uptime').readAsString();
      return double.parse(content.split(' ').first);
    } catch (_) {
      return 0;
    }
  }

  Future<CpuStats> _readCpu() async {
    try {
      final content = await File('/proc/stat').readAsString();
      final lines = content.split('\n');

      // Parse overall CPU line
      final cpuLine = lines.first.split(RegExp(r'\s+'));
      final values = cpuLine.sublist(1).map(int.parse).toList();
      final total = values.fold<int>(0, (a, b) => a + b);
      final idle = values[3] + (values.length > 4 ? values[4] : 0);

      double usage = 0;
      if (_prevCpuTotal != null && _prevCpuTotal!.isNotEmpty) {
        final totalDiff = total - _prevCpuTotal![0];
        final idleDiff = idle - _prevCpuIdle![0];
        if (totalDiff > 0) {
          usage = (1.0 - idleDiff / totalDiff) * 100;
        }
      }

      // Per-core usage
      final coreLines = lines.where((l) => l.startsWith('cpu') && !l.startsWith('cpu '));
      final prevTotals = _prevCpuTotal ?? [];
      final prevIdles = _prevCpuIdle ?? [];
      final newTotals = <int>[total];
      final newIdles = <int>[idle];
      final perCore = <double>[];
      int coreIdx = 1;

      for (final line in coreLines) {
        final parts = line.split(RegExp(r'\s+'));
        final vals = parts.sublist(1).map(int.parse).toList();
        final coreTotal = vals.fold<int>(0, (a, b) => a + b);
        final coreIdle = vals[3] + (vals.length > 4 ? vals[4] : 0);
        newTotals.add(coreTotal);
        newIdles.add(coreIdle);

        if (coreIdx < prevTotals.length) {
          final td = coreTotal - prevTotals[coreIdx];
          final id = coreIdle - prevIdles[coreIdx];
          perCore.add(td > 0 ? (1.0 - id / td) * 100 : 0);
        } else {
          perCore.add(0);
        }
        coreIdx++;
      }

      _prevCpuTotal = newTotals;
      _prevCpuIdle = newIdles;

      // Temperature
      double temp = 0;
      try {
        // Try hwmon first
        final hwmonDir = Directory('/sys/class/hwmon');
        if (hwmonDir.existsSync()) {
          for (final entry in hwmonDir.listSync()) {
            final nameFile = File('${entry.path}/name');
            if (nameFile.existsSync()) {
              final name = (await nameFile.readAsString()).trim();
              if (name == 'k10temp' || name == 'coretemp') {
                final tempFile = File('${entry.path}/temp1_input');
                if (tempFile.existsSync()) {
                  temp = int.parse((await tempFile.readAsString()).trim()) / 1000;
                  break;
                }
              }
            }
          }
        }
      } catch (_) {}

      // Model name
      String model = '';
      try {
        final cpuInfo = await File('/proc/cpuinfo').readAsString();
        final modelMatch = RegExp(r'model name\s*:\s*(.+)').firstMatch(cpuInfo);
        if (modelMatch != null) model = modelMatch.group(1)!.trim();
      } catch (_) {}

      return CpuStats(
        usagePercent: usage.clamp(0, 100),
        temperature: temp,
        coreCount: perCore.length,
        perCoreUsage: perCore,
        modelName: model,
      );
    } catch (_) {
      return const CpuStats();
    }
  }

  Future<GpuStats?> _readGpu() async {
    // Try AMD via sysfs first
    try {
      final drmDir = Directory('/sys/class/drm');
      if (drmDir.existsSync()) {
        for (final entry in drmDir.listSync()) {
          final name = entry.path.split('/').last;
          if (!RegExp(r'^card\d+$').hasMatch(name)) continue;

          final busyFile = File('${entry.path}/device/gpu_busy_percent');
          if (!busyFile.existsSync()) continue;

          final usage = double.tryParse(
                  (await busyFile.readAsString()).trim()) ??
              0;

          // Temperature from hwmon
          double temp = 0;
          final hwmonDir = Directory('${entry.path}/device/hwmon');
          if (hwmonDir.existsSync()) {
            for (final hwmon in hwmonDir.listSync()) {
              final tempFile = File('${hwmon.path}/temp1_input');
              if (tempFile.existsSync()) {
                temp = (int.tryParse(
                            (await tempFile.readAsString()).trim()) ??
                        0) /
                    1000;
                break;
              }
            }
          }

          // VRAM
          int vramUsedMB = 0;
          int vramTotalMB = 0;
          final vramUsedFile =
              File('${entry.path}/device/mem_info_vram_used');
          final vramTotalFile =
              File('${entry.path}/device/mem_info_vram_total');
          if (vramUsedFile.existsSync() && vramTotalFile.existsSync()) {
            vramUsedMB = ((int.tryParse(
                            (await vramUsedFile.readAsString()).trim()) ??
                        0) /
                    1048576)
                .round();
            vramTotalMB = ((int.tryParse(
                            (await vramTotalFile.readAsString()).trim()) ??
                        0) /
                    1048576)
                .round();
          }

          // Skip iGPUs with no/tiny VRAM (< 256MB dedicated)
          if (vramTotalMB > 0 && vramTotalMB < 256) continue;

          // GPU name from lspci-style uevent or fallback
          String gpuName = 'AMD GPU';
          try {
            final uevent =
                await File('${entry.path}/device/uevent').readAsString();
            final pciId =
                RegExp(r'PCI_ID=(\w+):(\w+)').firstMatch(uevent);
            if (pciId != null) {
              // Try to get a friendly name from lspci
              final result = await Process.run(
                  'lspci', ['-d', '${pciId.group(1)}:${pciId.group(2)}', '-mm']);
              final output = (result.stdout as String).trim();
              final nameMatch =
                  RegExp(r'"([^"]*\[([^\]]+)\])"').firstMatch(output);
              if (nameMatch != null) {
                gpuName = nameMatch.group(2)!;
              }
            }
          } catch (_) {}

          return GpuStats(
            name: gpuName,
            usagePercent: usage.clamp(0, 100),
            temperature: temp,
            memoryUsedMB: vramUsedMB,
            memoryTotalMB: vramTotalMB,
            vendor: GpuVendor.amd,
          );
        }
      }
    } catch (_) {}

    // Try NVIDIA via nvidia-smi
    try {
      final result = await Process.run('nvidia-smi', [
        '--query-gpu=name,utilization.gpu,temperature.gpu,memory.used,memory.total',
        '--format=csv,noheader,nounits',
      ]);
      if (result.exitCode == 0) {
        final parts = (result.stdout as String).trim().split(',').map((s) => s.trim()).toList();
        if (parts.length >= 5) {
          return GpuStats(
            name: parts[0],
            usagePercent: (double.tryParse(parts[1]) ?? 0).clamp(0, 100),
            temperature: double.tryParse(parts[2]) ?? 0,
            memoryUsedMB: int.tryParse(parts[3]) ?? 0,
            memoryTotalMB: int.tryParse(parts[4]) ?? 0,
            vendor: GpuVendor.nvidia,
          );
        }
      }
    } catch (_) {}

    return null;
  }

  Future<MemoryStats> _readMemory() async {
    try {
      final content = await File('/proc/meminfo').readAsString();
      final map = <String, int>{};
      for (final line in content.split('\n')) {
        final match = RegExp(r'(\w+):\s+(\d+)').firstMatch(line);
        if (match != null) {
          map[match.group(1)!] = int.parse(match.group(2)!) * 1024; // kB to bytes
        }
      }
      final total = map['MemTotal'] ?? 0;
      final available = map['MemAvailable'] ?? 0;
      return MemoryStats(
        totalBytes: total,
        usedBytes: total - available,
        swapTotalBytes: map['SwapTotal'] ?? 0,
        swapUsedBytes: (map['SwapTotal'] ?? 0) - (map['SwapFree'] ?? 0),
      );
    } catch (_) {
      return const MemoryStats();
    }
  }

  Future<NetworkStats> _readNetwork() async {
    try {
      final content = await File('/proc/net/dev').readAsString();
      int totalRx = 0;
      int totalTx = 0;

      for (final line in content.split('\n').skip(2)) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length < 10) continue;
        final iface = parts[0].replaceAll(':', '');
        if (iface == 'lo') continue; // skip loopback

        totalRx += int.tryParse(parts[1]) ?? 0;
        totalTx += int.tryParse(parts[9]) ?? 0;
      }

      int rxRate = 0;
      int txRate = 0;
      if (_prevNetRx != null) {
        rxRate = totalRx - _prevNetRx!;
        txRate = totalTx - _prevNetTx!;
      }
      _prevNetRx = totalRx;
      _prevNetTx = totalTx;

      return NetworkStats(
        bytesReceived: totalRx,
        bytesSent: totalTx,
        receiveRate: rxRate.clamp(0, rxRate),
        sendRate: txRate.clamp(0, txRate),
      );
    } catch (_) {
      return const NetworkStats();
    }
  }

  Future<List<DiskStats>> _readDisks() async {
    try {
      final result = await Process.run('df', ['-B1', '--output=target,size,used']);
      final lines = (result.stdout as String).split('\n').skip(1);
      final disks = <DiskStats>[];

      for (final line in lines) {
        final parts = line.trim().split(RegExp(r'\s+'));
        if (parts.length < 3) continue;
        final mount = parts[0];
        if (!mount.startsWith('/')) continue;
        if (mount.startsWith('/snap') || mount.startsWith('/boot/efi')) continue;

        disks.add(DiskStats(
          mountPoint: mount,
          totalBytes: int.tryParse(parts[1]) ?? 0,
          usedBytes: int.tryParse(parts[2]) ?? 0,
        ));
      }
      return disks;
    } catch (_) {
      return [];
    }
  }
}
