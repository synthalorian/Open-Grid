import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/grid_theme.dart';
import '../models/system_stats.dart';
import '../services/system_monitor.dart';
import '../widgets/neon_gauge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final List<double> _cpuHistory = List.filled(60, 0);
  final List<double> _memHistory = List.filled(60, 0);
  final List<double> _gpuHistory = List.filled(60, 0);
  final List<double> _netHistory = List.filled(60, 0);
  late Timer _timer;
  final _monitor = SystemMonitor();

  SystemSnapshot _snapshot = SystemSnapshot(timestamp: DateTime.now());

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _update() async {
    final snapshot = await _monitor.read();
    if (!mounted) return;

    setState(() {
      _snapshot = snapshot;

      _cpuHistory.removeAt(0);
      _cpuHistory.add(snapshot.cpu.usagePercent);

      _memHistory.removeAt(0);
      _memHistory.add(snapshot.memory.usagePercent);

      _gpuHistory.removeAt(0);
      _gpuHistory.add(snapshot.gpu?.usagePercent ?? 0);

      _netHistory.removeAt(0);
      // Convert to MB/s for readable graph
      _netHistory.add(snapshot.network.receiveRate / 1048576);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GridTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ScanlinePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _Header(snapshot: _snapshot),
                const SizedBox(height: 16),
                SizedBox(
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      NeonGauge(
                        label: 'CPU',
                        value: _snapshot.cpu.usagePercent,
                        color: GridTheme.neonCyan,
                        detail: _snapshot.cpu.temperature > 0
                            ? '${_snapshot.cpu.temperature.toStringAsFixed(0)}°C'
                            : null,
                      ),
                      NeonGauge(
                        label: 'MEMORY',
                        value: _snapshot.memory.usagePercent,
                        color: GridTheme.neonMagenta,
                        detail:
                            '${_snapshot.memory.usedFormatted} / ${_snapshot.memory.totalFormatted}',
                      ),
                      NeonGauge(
                        label: 'DISK /',
                        value: _snapshot.disks.isNotEmpty
                            ? _snapshot.disks.first.usagePercent
                            : 0,
                        color: GridTheme.neonYellow,
                      ),
                      if (_snapshot.gpu != null)
                        NeonGauge(
                          label: 'GPU',
                          value: _snapshot.gpu!.usagePercent,
                          color: GridTheme.neonOrange,
                          detail: _snapshot.gpu!.temperature > 0
                              ? '${_snapshot.gpu!.temperature.toStringAsFixed(0)}°C'
                              : null,
                        ),
                      NeonGauge(
                        label: 'SWAP',
                        value: _snapshot.memory.swapPercent,
                        color: GridTheme.neonGreen,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _GraphCard(
                          child: NeonGraph(
                            label: 'CPU USAGE',
                            data: _cpuHistory,
                            color: GridTheme.neonCyan,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GraphCard(
                          child: NeonGraph(
                            label: 'MEMORY',
                            data: _memHistory,
                            color: GridTheme.neonMagenta,
                          ),
                        ),
                      ),
                      if (_snapshot.gpu != null) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GraphCard(
                            child: NeonGraph(
                              label: 'GPU USAGE',
                              data: _gpuHistory,
                              color: GridTheme.neonOrange,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GraphCard(
                          child: NeonGraph(
                            label: 'NETWORK RX (MB/s)',
                            data: _netHistory,
                            color: GridTheme.neonGreen,
                            maxValue: _netMaxValue(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                _CoreBars(cores: _snapshot.cpu.perCoreUsage),
                if (_snapshot.disks.length > 1) ...[
                  const SizedBox(height: 8),
                  _DiskBars(disks: _snapshot.disks),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _netMaxValue() {
    final max = _netHistory.fold<double>(1, (a, b) => b > a ? b : a);
    if (max < 1) return 1;
    if (max < 10) return 10;
    if (max < 100) return 100;
    return max * 1.2;
  }
}

class _Header extends StatelessWidget {
  final SystemSnapshot snapshot;

  const _Header({required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: GridTheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: GridTheme.gridLine),
      ),
      child: Row(
        children: [
          const Text(
            'OPEN GRID',
            style: TextStyle(
              color: GridTheme.neonCyan,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              fontFamily: 'monospace',
            ),
          ),
          const Spacer(),
          if (snapshot.cpu.modelName.isNotEmpty)
            _InfoChip(label: snapshot.cpu.modelName, color: GridTheme.textDim),
          const SizedBox(width: 12),
          _InfoChip(label: snapshot.hostname, color: GridTheme.neonMagenta),
          const SizedBox(width: 12),
          _InfoChip(label: snapshot.kernel, color: GridTheme.textDim),
          const SizedBox(width: 12),
          _InfoChip(
            label: _formatUptime(snapshot.uptimeSeconds),
            color: GridTheme.neonGreen,
          ),
        ],
      ),
    );
  }

  String _formatUptime(double seconds) {
    final d = (seconds / 86400).floor();
    final h = ((seconds % 86400) / 3600).floor();
    final m = ((seconds % 3600) / 60).floor();
    if (d > 0) return 'UP ${d}d ${h}h';
    return 'UP ${h}h ${m}m';
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontFamily: 'monospace',
        letterSpacing: 0.5,
      ),
    );
  }
}

class _GraphCard extends StatelessWidget {
  final Widget child;

  const _GraphCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GridTheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: GridTheme.gridLine),
      ),
      child: child,
    );
  }
}

class _CoreBars extends StatelessWidget {
  final List<double> cores;

  const _CoreBars({required this.cores});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: GridTheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: GridTheme.gridLine),
      ),
      child: Row(
        children: [
          const Text(
            'CORES',
            style: TextStyle(
              color: GridTheme.textDim,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 12),
          ...cores.asMap().entries.map((e) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: (e.value / 100).clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _coreColor(e.value),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Color _coreColor(double usage) {
    if (usage > 80) return GridTheme.neonRed;
    if (usage > 50) return GridTheme.neonOrange;
    return GridTheme.neonCyan;
  }
}

class _DiskBars extends StatelessWidget {
  final List<DiskStats> disks;

  const _DiskBars({required this.disks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: GridTheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: GridTheme.gridLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: disks.map((disk) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    disk.mountPoint,
                    style: const TextStyle(
                      color: GridTheme.textDim,
                      fontSize: 10,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (disk.usagePercent / 100).clamp(0, 1),
                      minHeight: 8,
                      backgroundColor: GridTheme.gridLine,
                      valueColor: AlwaysStoppedAnimation(
                        disk.usagePercent > 90
                            ? GridTheme.neonRed
                            : disk.usagePercent > 70
                                ? GridTheme.neonOrange
                                : GridTheme.neonYellow,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${disk.usagePercent.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: GridTheme.textPrimary,
                    fontSize: 10,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = GridTheme.scanline;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
