import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/cache_management_service.dart';
import '../config/app_config.dart';

class DebugCachePanel extends StatefulWidget {
  const DebugCachePanel({super.key});

  @override
  State<DebugCachePanel> createState() => _DebugCachePanelState();
}

class _DebugCachePanelState extends State<DebugCachePanel> {
  Map<String, dynamic>? _cacheInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  Future<void> _loadCacheInfo() async {
    setState(() => _isLoading = true);
    try {
      final info = await CacheManagementService.getCacheInfo();
      setState(() => _cacheInfo = info);
    } catch (e) {
      debugPrint('Error loading cache info: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearCache() async {
    setState(() => _isLoading = true);
    try {
      await CacheManagementService.forceRefreshCache();
      await _loadCacheInfo();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing cache: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Debug Cache Panel',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadCacheInfo,
                icon: const Icon(Icons.refresh, color: Colors.white70, size: 16),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_isLoading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (_cacheInfo != null) ...[
            _buildInfoRow('Environment', AppConfig.environment.name),
            _buildInfoRow('Database', AppConfig.databaseUrl.split('/').last),
            _buildInfoRow('Last Environment', _cacheInfo!['lastEnvironment'] ?? 'None'),
            _buildInfoRow('Data Version', _cacheInfo!['dataVersion'] ?? 'None'),
            if (_cacheInfo!['imageCache'] != null) ...[
              const Divider(color: Colors.white24),
              const Text(
                'Image Cache:',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              _buildInfoRow('Memory Size', '${_cacheInfo!['imageCache']['memoryCacheSize'] ?? 0}'),
              _buildInfoRow('Disk Size', '${(_cacheInfo!['imageCache']['diskCacheSize'] ?? 0) ~/ 1024} KB'),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _clearCache,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Clear Cache', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}