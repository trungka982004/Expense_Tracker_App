import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/services.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(
          title: Text(settingsProvider.translate('profile')),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildProfileHeader(context, settingsProvider),
            const SizedBox(height: 24),
            _buildSettingsSection(context, settingsProvider),
            const SizedBox(height: 24),
            _buildAppInfoSection(context, settingsProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                // File picker for web
                final uploadInput = html.FileUploadInputElement();
                uploadInput.accept = 'image/*';
                uploadInput.click();
                await uploadInput.onChange.first;
                final file = uploadInput.files?.first;
                if (file != null) {
                  final reader = html.FileReader();
                  reader.readAsDataUrl(file);
                  await reader.onLoad.first;
                  final base64 = reader.result as String;
                  // Remove the data:image/...;base64, prefix
                  final pureBase64 = base64.split(',').last;
                  settingsProvider.setUserAvatar(pureBase64);
                }
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: settingsProvider.userAvatar != null
                    ? MemoryImage(base64Decode(settingsProvider.userAvatar!))
                    : null,
                child: settingsProvider.userAvatar == null
                    ? const Icon(Icons.person, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    settingsProvider.userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () async {
                    final controller = TextEditingController(text: settingsProvider.userName);
                    final result = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Edit Name'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(controller.text),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                    if (result != null && result.trim().isNotEmpty) {
                      settingsProvider.setUserName(result.trim());
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    settingsProvider.userEmail,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () async {
                    final controller = TextEditingController(text: settingsProvider.userEmail);
                    final result = await showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Edit Email'),
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(labelText: 'Email'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(controller.text),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    );
                    if (result != null && result.trim().isNotEmpty) {
                      settingsProvider.setUserEmail(result.trim());
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Consumer<ExpenseProvider>(
              builder: (ctx, expenseProvider, child) {
                return Text(
                  '${settingsProvider.translate('total_balance')}: ${settingsProvider.formatCurrency(expenseProvider.totalExpenses)}',
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(settingsProvider.translate('notifications')),
            trailing: Switch(
              value: true,
              onChanged: (value) {
                // TODO: Implement notifications toggle
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: Text(settingsProvider.translate('dark_mode')),
            trailing: Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                );
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.currency_exchange),
            title: Text(settingsProvider.translate('currency')),
            trailing: DropdownButton<String>(
              value: settingsProvider.currency,
              items: [
                DropdownMenuItem(
                  value: 'USD',
                  child: const Text('USD (\$)'),
                ),
                DropdownMenuItem(
                  value: 'VND',
                  child: const Text('VND (₫)'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setCurrency(value);
                }
              },
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(settingsProvider.translate('language')),
            trailing: DropdownButton<String>(
              value: settingsProvider.language,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: const Text('English'),
                ),
                DropdownMenuItem(
                  value: 'vi',
                  child: const Text('Tiếng Việt'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  settingsProvider.setLanguage(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context, SettingsProvider settingsProvider) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(settingsProvider.translate('about')),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: settingsProvider.translate('app_title'),
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 48),
                children: [
                  Text(
                    settingsProvider.translate('about'),
                  ),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: Text(settingsProvider.translate('privacy_policy')),
            onTap: () {
              // TODO: Implement privacy policy
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description),
            title: Text(settingsProvider.translate('terms_of_service')),
            onTap: () {
              // TODO: Implement terms of service
            },
          ),
        ],
      ),
    );
  }
} 