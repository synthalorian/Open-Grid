class CpuStats {
  final double usagePercent;
  final double temperature;
  final int coreCount;
  final List<double> perCoreUsage;
  final String modelName;

  const CpuStats({
    this.usagePercent = 0,
    this.temperature = 0,
    this.coreCount = 0,
    this.perCoreUsage = const [],
    this.modelName = '',
  });
}

class MemoryStats {
  final int totalBytes;
  final int usedBytes;
  final int swapTotalBytes;
  final int swapUsedBytes;

  const MemoryStats({
    this.totalBytes = 0,
    this.usedBytes = 0,
    this.swapTotalBytes = 0,
    this.swapUsedBytes = 0,
  });

  double get usagePercent =>
      totalBytes > 0 ? usedBytes / totalBytes * 100 : 0;
  double get swapPercent =>
      swapTotalBytes > 0 ? swapUsedBytes / swapTotalBytes * 100 : 0;

  String get usedFormatted => _formatBytes(usedBytes);
  String get totalFormatted => _formatBytes(totalBytes);

  static String _formatBytes(int bytes) {
    if (bytes >= 1073741824) return '${(bytes / 1073741824).toStringAsFixed(1)} GB';
    if (bytes >= 1048576) return '${(bytes / 1048576).toStringAsFixed(0)} MB';
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }
}

class GpuStats {
  final String name;
  final double usagePercent;
  final double temperature;
  final int memoryUsedMB;
  final int memoryTotalMB;
  final GpuVendor vendor;

  const GpuStats({
    this.name = '',
    this.usagePercent = 0,
    this.temperature = 0,
    this.memoryUsedMB = 0,
    this.memoryTotalMB = 0,
    this.vendor = GpuVendor.unknown,
  });

  double get memoryPercent =>
      memoryTotalMB > 0 ? memoryUsedMB / memoryTotalMB * 100 : 0;
}

enum GpuVendor { nvidia, amd, intel, unknown }

class NetworkStats {
  final int bytesReceived;
  final int bytesSent;
  final int receiveRate; // bytes/sec
  final int sendRate; // bytes/sec

  const NetworkStats({
    this.bytesReceived = 0,
    this.bytesSent = 0,
    this.receiveRate = 0,
    this.sendRate = 0,
  });
}

class DiskStats {
  final String mountPoint;
  final int totalBytes;
  final int usedBytes;

  const DiskStats({
    this.mountPoint = '/',
    this.totalBytes = 0,
    this.usedBytes = 0,
  });

  double get usagePercent =>
      totalBytes > 0 ? usedBytes / totalBytes * 100 : 0;
}

class SystemSnapshot {
  final DateTime timestamp;
  final CpuStats cpu;
  final GpuStats? gpu;
  final MemoryStats memory;
  final NetworkStats network;
  final List<DiskStats> disks;
  final double uptimeSeconds;
  final String hostname;
  final String kernel;

  const SystemSnapshot({
    required this.timestamp,
    this.cpu = const CpuStats(),
    this.gpu,
    this.memory = const MemoryStats(),
    this.network = const NetworkStats(),
    this.disks = const [],
    this.uptimeSeconds = 0,
    this.hostname = '',
    this.kernel = '',
  });
}
