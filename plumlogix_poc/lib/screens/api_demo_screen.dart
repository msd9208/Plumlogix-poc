import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:plumlogix_poc/services/api_service.dart';

/// API Demo Screen
/// Demonstrates REST API integration with MuleSoft
/// Shows bearer token authentication and JSON response handling
class ApiDemoScreen extends StatefulWidget {
  const ApiDemoScreen({super.key});

  @override
  State<ApiDemoScreen> createState() => _ApiDemoScreenState();
}

class _ApiDemoScreenState extends State<ApiDemoScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _responseData;
  String? _errorMessage;
  int? _statusCode;
  String? _requestUrl;
  String? _requestMethod;

  Future<void> _callGetApi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _responseData = null;
      _requestMethod = 'GET';
      _requestUrl = '/users/1';
    });

    final response = await _apiService.get('/users/1');

    setState(() {
      _isLoading = false;
      _statusCode = response.statusCode;
      
      if (response.success) {
        _responseData = const JsonEncoder.withIndent('  ').convert(response.data);
      } else {
        _errorMessage = response.error;
      }
    });
  }

  Future<void> _callPostApi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _responseData = null;
      _requestMethod = 'POST';
      _requestUrl = '/posts';
    });

    final response = await _apiService.post(
      '/posts',
      body: {
        'title': 'Plumlogix POC Test',
        'body': 'This is a test API call from Flutter app',
        'userId': 1,
      },
    );

    setState(() {
      _isLoading = false;
      _statusCode = response.statusCode;
      
      if (response.success) {
        _responseData = const JsonEncoder.withIndent('  ').convert(response.data);
      } else {
        _errorMessage = response.error;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Integration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.purple.shade50],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.api, color: Colors.blue.shade700, size: 32),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'MuleSoft API Integration',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This demonstrates secure REST API calls with bearer token authentication. '
                      'All requests include the OAuth access token in the Authorization header.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    title: 'GET Request',
                    icon: Icons.download,
                    color: Colors.green,
                    onPressed: _isLoading ? null : _callGetApi,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    title: 'POST Request',
                    icon: Icons.upload,
                    color: Colors.orange,
                    onPressed: _isLoading ? null : _callPostApi,
                  ),
                ),
              ],
            ),
            
            if (_isLoading) ...[
              const SizedBox(height: 32),
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('Making API call...'),
              ),
            ],
            
            // Request Info
            if (_requestMethod != null && _requestUrl != null) ...[
              const SizedBox(height: 24),
              _buildInfoCard(
                title: 'Request Details',
                icon: Icons.send,
                color: Colors.blue,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Method', _requestMethod!),
                    const SizedBox(height: 8),
                    _buildInfoRow('Endpoint', _requestUrl!),
                    const SizedBox(height: 8),
                    _buildInfoRow('Auth', 'Bearer Token'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Content-Type', 'application/json'),
                  ],
                ),
              ),
            ],
            
            // Response Info
            if (_statusCode != null) ...[
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Response',
                icon: Icons.receipt_long,
                color: _errorMessage != null ? Colors.red : Colors.green,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow(
                      'Status Code',
                      '$_statusCode ${_errorMessage != null ? "❌" : "✅"}',
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            
            // Response Data
            if (_responseData != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.code, color: Colors.purple.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'JSON Response',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SelectableText(
                            _responseData!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
