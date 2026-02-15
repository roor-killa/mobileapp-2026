import 'package:flutter/material.dart';
import '../../core/tokens.dart';
import '../../core/ui.dart';
import '../../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settings;
  const SettingsScreen({super.key, required this.settings});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final s = widget.settings;

    return Scaffold(
      backgroundColor: T.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Glass(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                value: s.proMode,
                onChanged: (v) async {
                  await s.setProMode(v);
                  if (mounted) setState(() {});
                },
                title: const Text('Mode Pro'),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('Résolution'),
                subtitle: Text('${s.resolution} x ${s.resolution}'),
                trailing: DropdownButton<int>(
                  value: s.resolution,
                  items: const [
                    DropdownMenuItem(value: 512, child: Text('512')),
                    DropdownMenuItem(value: 1024, child: Text('1024')),
                  ],
                  onChanged: (v) async {
                    if (v == null) return;
                    await s.setResolution(v);
                    if (mounted) setState(() {});
                  },
                ),
              ),
              const Divider(height: 1),
              if (s.proMode)
                ListTile(
                  title: const Text('Batch (galerie multi-photos)'),
                  subtitle: Text('${s.batchCount} photos'),
                  trailing: DropdownButton<int>(
                    value: s.batchCount,
                    items: [1, 2, 3, 5, 8, 12, 20]
                        .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                        .toList(),
                    onChanged: (v) async {
                      if (v == null) return;
                      await s.setBatchCount(v);
                      if (mounted) setState(() {});
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
