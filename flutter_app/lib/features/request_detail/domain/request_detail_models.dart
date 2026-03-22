class TransformationDetail {
  const TransformationDetail({required this.name, required this.value});

  final String name;
  final String value;
}

class RequestImageDetail {
  const RequestImageDetail({
    required this.name,
    required this.node,
    required this.start,
    required this.end,
    required this.status,
  });

  final String name;
  final String node;
  final String start;
  final String end;
  final String status;
}
