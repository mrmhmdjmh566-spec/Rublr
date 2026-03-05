import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'webview_screen.dart';

class Task {
  final String title;
  final String taskUrl;
  final String? videoUrl;

  Task({required this.title, required this.taskUrl, this.videoUrl});

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      title: map['task_title'] ?? 'No Title',
      taskUrl: map['task_url'] ?? '',
      videoUrl: map['video_url'],
    );
  }
}

class TaskScreen extends StatefulWidget {
  final String siteName;

  const TaskScreen({super.key, required this.siteName});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _supabase = Supabase.instance.client;
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      final response = await _supabase
          .from('tasks')
          .select('task_title, task_url, video_url')
          .eq('site_name', widget.siteName.toLowerCase());

      if (mounted) {
        setState(() {
          _tasks = (response as List)
              .map((taskData) => Task.fromMap(taskData))
              .toList();
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to fetch tasks: $e';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          // This is fine, but we'll also show the error in the UI
          SnackBar(content: Text('Failed to fetch tasks: $e')),
        );
      }
    }
  }

  void _openWebView(String url) {
    if (url.isNotEmpty && Uri.tryParse(url)?.isAbsolute == true) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WebViewScreen(url: url)),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL is not available.')));
    }
  }

  String _getReferralUrl() {
    switch (widget.siteName.toLowerCase()) {
      case 'seofast':
        return 'https://seo-fast.ru/?r=3151488';
      case 'aviso':
        return 'https://aviso.bz/?r=khroba_242';
      case 'socpublic':
        return 'https://socpublic.com/?i=9565193&slide=3';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.siteName),
        backgroundColor: Colors.orange[300], // Light Orange
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            )
          : _tasks.isEmpty
          ? const Center(child: Text('No tasks available for this site.'))
          : Column(
              children: [
                // Referral Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () => _openWebView(_getReferralUrl()),
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.orange[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Go to Website',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                // Task List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      return Card(
                        elevation: 4,
                        shadowColor: Colors.grey.withOpacity(0.5),
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _openWebView(task.taskUrl),
                                    icon: const Icon(Icons.arrow_forward),
                                    label: const Text('Start Task'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (task.videoUrl != null &&
                                      task.videoUrl!.isNotEmpty)
                                    ElevatedButton.icon(
                                      onPressed: () => _openWebView(
                                        task.videoUrl!,
                                      ), // Watch Tutorial
                                      icon: const Icon(Icons.arrow_forward),
                                      label: const Text('Watch Video'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
