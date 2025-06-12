import 'package:flutter/material.dart';
import 'dart:io';

class BuildStatusWidget extends StatefulWidget {
  const BuildStatusWidget({Key? key}) : super(key: key);

  @override
  State<BuildStatusWidget> createState() => _BuildStatusWidgetState();
}

class _BuildStatusWidgetState extends State<BuildStatusWidget> {
  bool _hasReleaseFiles = false;
  String _lastBuildDate = 'Never';
  List<String> _availableFiles = [];

  @override
  void initState() {
    super.initState();
    _checkBuildStatus();
  }

  Future<void> _checkBuildStatus() async {
    try {
      final releaseDir = Directory('release');
      if (releaseDir.existsSync()) {
        final files = releaseDir
            .listSync()
            .where((entity) => 
                entity is File && 
                (entity.path.endsWith('.apk') || entity.path.endsWith('.aab')))
            .cast<File>()
            .toList();

        if (files.isNotEmpty) {
          // Get the most recent file's modification date
          files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
          final lastModified = files.first.lastModifiedSync();
          
          setState(() {
            _hasReleaseFiles = true;
            _lastBuildDate = _formatDate(lastModified);
            _availableFiles = files.map((f) => f.path.split('/').last).toList();
          });
        }
      }

      // Check build info file
      final buildInfoFile = File('release/build_info.txt');
      if (buildInfoFile.existsSync()) {
        final content = await buildInfoFile.readAsString();
        final dateMatch = RegExp(r'Build Date: (.+)').firstMatch(content);
        if (dateMatch != null) {
          setState(() {
            _lastBuildDate = dateMatch.group(1)!.split(' ')[0]; // Just the date part
          });
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _hasReleaseFiles ? Icons.check_circle : Icons.build,
                  color: _hasReleaseFiles ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Build Status',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Build: $_lastBuildDate',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _hasReleaseFiles 
                            ? '${_availableFiles.length} files available'
                            : 'No release files found',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/build-execution');
                  },
                  icon: const Icon(Icons.build, size: 16),
                  label: const Text('Build'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            if (_availableFiles.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Available Files:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: _availableFiles.map((file) => Chip(
                  label: Text(
                    file,
                    style: const TextStyle(fontSize: 10),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
