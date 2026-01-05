import 'package:flutter/material.dart';
import 'package:plumlogix_poc/services/auth_service.dart';
import 'package:plumlogix_poc/models/user_model.dart';
import 'package:plumlogix_poc/widgets/poc_card.dart';
import 'package:plumlogix_poc/screens/api_demo_screen.dart';
import 'package:plumlogix_poc/screens/webview_screen.dart';
import 'package:plumlogix_poc/screens/profile_screen.dart';
import 'package:plumlogix_poc/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _user = user;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _showInfoDialog(String title, List<String> features) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: features.map((f) => Text('• $f')).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlumLogix POC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            child: Text(
                              _user?.initials ?? 'U',
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _user?.name ?? 'User',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _user?.email ?? '',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    'POC Capabilities',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      PocCard(
                        title: 'OAuth 2.0',
                        description: 'Salesforce & MuleSoft Auth',
                        icon: Icons.lock_person,
                        color: Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                      
                      PocCard(
                        title: 'REST API',
                        description: 'MuleSoft Integration',
                        icon: Icons.api,
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ApiDemoScreen(),
                            ),
                          );
                        },
                      ),
                      
                      PocCard(
                        title: 'Secure Storage',
                        description: 'HIPAA Compliant',
                        icon: Icons.security,
                        color: Colors.purple,
                        onTap: () {
                          _showInfoDialog(
                            'Secure Storage',
                            [
                              'Android Keystore encryption',
                              'iOS Keychain encryption',
                              'Tokens encrypted at rest',
                              'TLS 1.2+ in transit',
                              'No PHI in logs',
                            ],
                          );
                        },
                      ),
                      
                      PocCard(
                        title: 'WebView',
                        description: 'HTML/CSS/Angular',
                        icon: Icons.web,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WebViewScreen(),
                            ),
                          );
                        },
                      ),
                      
                      PocCard(
                        title: 'Cross-Platform',
                        description: 'Android & iOS',
                        icon: Icons.phone_android,
                        color: Colors.teal,
                        onTap: () {
                          _showInfoDialog(
                            'Cross-Platform',
                            [
                              'Android (ARM & x86)',
                              'iOS (ARM64)',
                              'Shared business logic',
                              'Platform-specific UI',
                              'Native performance',
                            ],
                          );
                        },
                      ),
                      
                      PocCard(
                        title: 'CI/CD',
                        description: 'Azure DevOps',
                        icon: Icons.build_circle,
                        color: Colors.indigo,
                        onTap: () {
                          _showInfoDialog(
                            'CI/CD Pipeline',
                            [
                              'Automated builds',
                              'Environment flavors',
                              'Secret management',
                              'Code quality checks',
                              'Artifact publishing',
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}