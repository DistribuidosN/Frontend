class WorkerNode {
  const WorkerNode({
    required this.id,
    required this.address,
    required this.active,
    required this.load,
    required this.currentJobs,
    required this.totalProcessed,
    required this.lastHeartbeat,
    required this.uptime,
    this.busyWorkers = 0,
    this.ramUsage = 0,
  });

  final String id;
  final String address;
  final bool active;
  final int load;         // cpu_usage %
  final int currentJobs;
  final int totalProcessed;
  final String lastHeartbeat;
  final String uptime;
  final int busyWorkers;  // busy_workers from backend
  final int ramUsage;     // ram_usage % from backend
}
