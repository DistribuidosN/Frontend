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
  });

  final String id;
  final String address;
  final bool active;
  final int load;
  final int currentJobs;
  final int totalProcessed;
  final String lastHeartbeat;
  final String uptime;
}
