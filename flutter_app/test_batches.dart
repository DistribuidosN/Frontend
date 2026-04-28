// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final String baseUrl = 'https://ea47-181-55-22-220.ngrok-free.app/api/v1';

  print('Logging in...');
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({"email": "enma@enfok.com", "password": "Aceros2005"}),
  );

  if (loginRes.statusCode != 200) {
    print('Login failed: ${loginRes.statusCode} ${loginRes.body}');
    return;
  }

  final token = jsonDecode(loginRes.body)['token'];
  print('Token: $token');

  print('Fetching /bd/batches...');
  final batchesRes = await http.get(
    Uri.parse('$baseUrl/bd/batches'),
    headers: {'Authorization': 'Bearer $token'},
  );

  print('Batches Status: ${batchesRes.statusCode}');
  print('Batches Body:');
  print(batchesRes.body);
}
