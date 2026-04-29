// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  final String ip = '192.168.80.22';
  final String baseUrl = 'http://$ip/api/v1';

  print('--- TEST: DOWNLOAD FLOW ---');
  
  // 1. LOGIN
  print('\n[1/4] Logging in...');
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
  print('Token obtenido correctamente.');

  // 2. GET BATCHES
  print('\n[2/4] Fetching batches to get a requestId...');
  final batchesRes = await http.get(
    Uri.parse('$baseUrl/bd/batches'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (batchesRes.statusCode != 200) {
    print('Failed to get batches: ${batchesRes.body}');
    return;
  }

  final List batches = jsonDecode(batchesRes.body);
  if (batches.isEmpty) {
    print('No batches found to test.');
    return;
  }

  print('First batch structure: ${batches.first}');
  final String requestId = batches.first['batch']['batch_uuid'] ?? 'unknown';
  print('Testing with RequestID: $requestId');

  // 3. GET DOWNLOAD URL
  print('\n[3/4] Fetching download URL for $requestId...');
  final downloadInfoRes = await http.get(
    Uri.parse('$baseUrl/download-batch/$requestId'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (downloadInfoRes.statusCode != 200) {
    print('Failed to get download info: ${downloadInfoRes.body}');
    return;
  }

  final info = jsonDecode(downloadInfoRes.body);
  final String? downloadUrl = info['download_url'];

  if (downloadUrl == null) {
    print('Download URL is null in response: $info');
    return;
  }

  print('Download URL obtained: $downloadUrl');

  // 4. DOWNLOAD FILE (Simulating ApiClient fix: NO Authorization header)
  print('\n[4/4] Downloading file from signed URL...');
  print('Note: We are NOT sending Authorization header here to avoid breaking the signature.');
  
  final downloadFileRes = await http.get(
    Uri.parse(downloadUrl),
    // headers: {'Authorization': 'Bearer $token'}, // <--- ESTO ES LO QUE NO DEBEMOS HACER
  );

  if (downloadFileRes.statusCode == 200) {
    print('SUCCESS! File downloaded correctly.');
    print('Size: ${downloadFileRes.bodyBytes.length} bytes');
    
    // Extraer el nombre real tal como lo hace el navegador
    String finalName = 'download.zip';
    final cdHeader = downloadFileRes.headers['content-disposition'];
    if (cdHeader != null && cdHeader.contains('filename=')) {
      finalName = cdHeader.split('filename=')[1].replaceAll('"', '').trim();
    } else {
      finalName = Uri.parse(downloadUrl).pathSegments.last;
    }

    final file = File(finalName);
    await file.writeAsBytes(downloadFileRes.bodyBytes);
    print('File saved to: ${file.path}');
    
    // Probar integridad (Primeros 4 bytes deben ser PK\x03\x04 para un ZIP)
    final bytes = downloadFileRes.bodyBytes.take(4).toList();
    print('First 4 bytes (HEX): ${bytes.map((b) => b.toRadixString(16).padLeft(2, "0")).join(" ")}');
    if (bytes[0] == 0x50 && bytes[1] == 0x4B) {
      print('Integrity Check: Valid ZIP Header (PK) found.');
    } else {
      print('Integrity Check: WARNING! Not a valid ZIP header.');
    }
  } else {
    print('FAILED! Status: ${downloadFileRes.statusCode}');
    print('Body: ${downloadFileRes.body}');
    
    if (downloadFileRes.body.contains('SignatureDoesNotMatch')) {
      print('Error: Signature does not match. Check if Nginx is stripping Authorization header or if IP/Path changed.');
    }
  }

  print('\n--- TEST FINISHED ---');
}
