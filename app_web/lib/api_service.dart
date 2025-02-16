import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class ApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ApiResponse({required this.success, required this.message, this.data});
}

class ApiService {
  static const String baseUrl = "http://localhost:4000/api/auth";

  Map<String, String> get _headers {
    final token = TokenService.getToken();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<ApiResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return ApiResponse(success: true, message: "Login successful", data: body);
      } else {
        var message = "Invalid email or password";
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
        } catch (_) {}
        return ApiResponse(success: false, message: message);
      }
    } catch (e) {
      return ApiResponse(success: false, message: "Connection error: ${e.toString()}");
    }
  }

  Future<ApiResponse> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return ApiResponse(success: true, message: "Registration successful", data: body);
      } else {
        var message = "Registration failed";
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
        } catch (_) {}
        return ApiResponse(success: false, message: message);
      }
    } catch (e) {
      return ApiResponse(success: false, message: "Connection error: ${e.toString()}");
    }
  }

  Future<ApiResponse> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return ApiResponse(success: true, message: "Profile fetched", data: body);
      } else {
        return ApiResponse(
          success: false,
          message: "Failed to fetch profile",
        );
      }
    } catch (e) {
      return ApiResponse(success: false, message: "Connection error: ${e.toString()}");
    }
  }
}
