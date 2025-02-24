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

  String? _userId;

  Map<String, String> get _headers {
    final token = TokenService.getToken();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  Future<ApiResponse> login(String emailOrMobile, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: _headers,
        body: jsonEncode({"emailOrMobile": emailOrMobile, "password": password}),
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

  Future<ApiResponse> register(String email, String name, String dateOfBirth, String gender,  String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: _headers,
        body: jsonEncode({"email": email, "name": name, "dateOfBirth": dateOfBirth, "gender": gender, "password": password}),
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

  Future<ApiResponse> sendOtp(String email, String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: _headers,
        body: jsonEncode({
          "email": email,
          "phoneNumber": phoneNumber
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return ApiResponse(success: true, message: "OTP sent successfully", data: body);
      } else {
        var message = "Failed to send OTP";
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

  Future<ApiResponse> verifyOtp(String phoneNumber, String tempToken, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: _headers,
        body: jsonEncode({
          "phoneNumber": phoneNumber,
          "tempToken": tempToken,
          "otp": otp
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return ApiResponse(success: true, message: "OTP verified successfully", data: body);
      } else {
        var message = "Failed to verify OTP";
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

  Future<ApiResponse> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return ApiResponse(success: true, message: "Logged out successfully");
      } else {
        return ApiResponse(success: false, message: "Failed to logout");
      }
    } catch (e) {
      return ApiResponse(success: false, message: "Connection error: ${e.toString()}");
    }
  }

  Future<ApiResponse> getOnlineUsers() async {
    return _get('/users/online');
  }

  Future<ApiResponse> sendMessage(String receiverId, String message) async {
    print('Sending message to $receiverId: $message');
    
    if (message.trim().isEmpty) {
      return ApiResponse(success: false, message: "Message cannot be empty");
    }
    
    try {
      final response = await http.post(
        Uri.parse('${baseUrl.replaceAll('/auth', '')}/chat/send'),
        headers: _headers,
        body: jsonEncode({
          'receiverId': receiverId,
          'message': message.trim(),
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) { // Changed from 200 to 201
        final responseBody = jsonDecode(response.body);
        if (responseBody['success'] && responseBody['message'] != null) {
          return ApiResponse(
            success: true, 
            message: "Message sent",
            data: {'message': responseBody['message']},
          );
        }
      }
      
      var errorMessage = "Failed to send message";
      try {
        final responseBody = jsonDecode(response.body);
        errorMessage = responseBody['error'] ?? responseBody['message'] ?? errorMessage;
      } catch (_) {}
      return ApiResponse(success: false, message: errorMessage);
    } catch (e) {
      print('Error sending message: $e');
      return ApiResponse(success: false, message: "Connection error: ${e.toString()}");
    }
  }

  Future<ApiResponse> markMessagesAsRead(String senderId) async {
    return _put('/chat/read/$senderId', {});
  }

  Future<ApiResponse> getChatHistory(String conversationId) async {
    if (conversationId.isEmpty) {
      return ApiResponse(success: false, message: "Invalid conversation ID");
    }
    return _get('/chat/history/$conversationId');
  }

  Future<ApiResponse> getRecentChats() async {
    return _get('/chat/recent');
  }

  Future<ApiResponse> checkExistingConversation(String userId) async {
    if (userId.isEmpty) {
      return ApiResponse(success: false, message: "Invalid user ID");
    }
    return _get('/chat/check-conversation/$userId');
  }

  Future<String?> getCurrentUserId() async {
    if (_userId != null) return _userId;
    
    final response = await getProfile();
    if (response.success && response.data != null) {
      _userId = response.data!['_id'];
      return _userId;
    }
    return null;
  }

  Future<ApiResponse> _get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${baseUrl.replaceAll('/auth', '')}$endpoint'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return ApiResponse(success: true, message: "Request successful", data: body);
      } else {
        var message = "Request failed";
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

  Future<ApiResponse> _post(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl.replaceAll('/auth', '')}$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return ApiResponse(success: true, message: "Request successful", data: responseBody);
      } else {
        var message = "Request failed";
        try {
          final responseBody = jsonDecode(response.body);
          message = responseBody['message'] ?? message;
        } catch (_) {}
        return ApiResponse(success: false, message: message);
      }
    } catch (e) {
      return ApiResponse(success: false, message: "Connection error: ${e.toString()}");
    }
  }

  Future<ApiResponse> _put(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('${baseUrl.replaceAll('/auth', '')}$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        return ApiResponse(success: true, message: "Request successful", data: responseBody);
      } else {
        var message = "Request failed";
        try {
          final responseBody = jsonDecode(response.body);
          message = responseBody['message'] ?? message;
        } catch (_) {}
        return ApiResponse(success: false, message: message);
      }
    } catch (e) {
      return ApiResponse(success: false, message: "Connection error: ${e.toString()}");
    }
  }
}
