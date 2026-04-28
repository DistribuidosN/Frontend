import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final String baseUrl = 'https://ea47-181-55-22-220.ngrok-free.app/api/v1';
  
  print('Logging in...');
  final loginRes = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "email": "enma@enfok.com",
      "password": "Aceros2005"
    })
  );
  
  final token = jsonDecode(loginRes.body)['token'];
  
  // Use one of the batch UUIDs from the previous test
  final String batchUuid = '038b07cf-0397-4bc6-939d-503fbb250ed3';
  
  print('Testing /download-batch/:id...');
  final res1 = await http.get(
    Uri.parse('$baseUrl/download-batch/$batchUuid'),
    headers: {
      'Authorization': 'Bearer $token',
    }
  );
  print('Status 1: ${res1.statusCode}');
  
  print('Testing /node/batch/:id/download...');
  final res2 = await http.get(
    Uri.parse('$baseUrl/node/batch/$batchUuid/download'),
    headers: {
      'Authorization': 'Bearer $token',
    }
  );
  print('Status 2: ${res2.statusCode}');
  
  print('Testing /bd/gallery?batchUuid=...');
  final res3 = await http.get(
    Uri.parse('$baseUrl/bd/gallery?batchUuid=$batchUuid&page=1&limit=20'),
    headers: {
      'Authorization': 'Bearer $token',
    }
  );
  print('Gallery Status: ${res3.statusCode}');
  print('Gallery Body:');
  print(res3.body);
}
