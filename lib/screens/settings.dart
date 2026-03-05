import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = StorageService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF607D8B), Color(0xFF455A64)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Settings',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _SettingsTile(
                      icon: Icons.music_note,
                      title: 'Music',
                      trailing: Switch(
                        value: _storage.musicEnabled,
                        onChanged: (value) {
                          setState(() {
                            _storage.musicEnabled = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SettingsTile(
                      icon: Icons.volume_up,
                      title: 'Music Volume',
                      trailing: SizedBox(
                        width: 200,
                        child: Slider(
                          value: _storage.musicVolume,
                          onChanged: _storage.musicEnabled
                              ? (value) {
                                  setState(() {
                                    _storage.musicVolume = value;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SettingsTile(
                      icon: Icons.speaker,
                      title: 'Sound Effects',
                      trailing: Switch(
                        value: _storage.sfxEnabled,
                        onChanged: (value) {
                          setState(() {
                            _storage.sfxEnabled = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SettingsTile(
                      icon: Icons.volume_up,
                      title: 'SFX Volume',
                      trailing: SizedBox(
                        width: 200,
                        child: Slider(
                          value: _storage.sfxVolume,
                          onChanged: _storage.sfxEnabled
                              ? (value) {
                                  setState(() {
                                    _storage.sfxVolume = value;
                                  });
                                }
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _SettingsTile(
                      icon: Icons.delete_forever,
                      title: 'Reset All Progress',
                      titleColor: Colors.red.shade300,
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: () => _confirmReset(context),
                        child: const Text('Reset'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Progress?'),
        content: const Text(
          'This will delete ALL your stars, coins, cars, and trophies. This cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _storage.resetAll();
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress reset.')),
                );
              }
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: titleColor ?? Colors.white, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                color: titleColor ?? Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
