import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'analysing_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  // ── File state ──────────────────────────────────────────────────────
  PlatformFile? _pickedFile;
  bool _isPicking = false;
  bool _isRecording = false;

  // ── Animation for record pulse ───────────────────────────────────────
  late final AnimationController _recordCtrl;
  late final Animation<double> _recordPulse;

  @override
  void initState() {
    super.initState();
    _recordCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _recordPulse = Tween<double>(begin: 1.0, end: 1.18).animate(
        CurvedAnimation(parent: _recordCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _recordCtrl.dispose();
    super.dispose();
  }

  // ── File helpers ────────────────────────────────────────────────────
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _extension(String name) {
    final idx = name.lastIndexOf('.');
    return idx == -1 ? '' : name.substring(idx).toLowerCase();
  }

  // ── Pick file via system file picker ────────────────────────────────
  Future<void> _pickFile() async {
    if (_isPicking) return;
    setState(() => _isPicking = true);

    try {
      final FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['wav', 'mp3', 'ogg', 'm4a', 'aac', 'flac'],
        withData: false,
        withReadStream: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _pickedFile = result.files.first);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: $e'),
            backgroundColor: AppColors.highRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  // ── Navigate to analysing screen ─────────────────────────────────────
  void _analyse() {
    if (_pickedFile == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysingScreen(
          fileName: _pickedFile!.name,
          filePath: _pickedFile!.path,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool hasFile = _pickedFile != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 20),
        ),
        title: const Text('Analyse Call', style: AppTextStyles.title),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // ── Upload Zone ────────────────────────────────────────────
              GestureDetector(
                onTap: _isPicking ? null : _pickFile,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  decoration: BoxDecoration(
                    color: hasFile ? AppColors.primaryLight : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasFile
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.border,
                      width: 1.8,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                  child: _isPicking
                      ? const Column(
                          children: [
                            SizedBox(
                              width: 32,
                              height: 32,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Opening file picker…',
                              style: TextStyle(
                                  color: AppColors.textLight, fontSize: 13),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Text(
                              hasFile ? '✅' : '📁',
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              hasFile
                                  ? 'File selected — tap to change'
                                  : 'Tap to select audio file',
                              style: AppTextStyles.subtitle.copyWith(
                                color: hasFile
                                    ? AppColors.primary
                                    : AppColors.textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '.wav · .mp3 · .ogg · .m4a · .aac · .flac',
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.textLight),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // ── OR Divider ─────────────────────────────────────────────
              Row(
                children: [
                  const Expanded(
                      child: Divider(color: AppColors.divider, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textMuted)),
                  ),
                  const Expanded(
                      child: Divider(color: AppColors.divider, thickness: 1)),
                ],
              ),

              const SizedBox(height: 20),

              // ── Record Button ──────────────────────────────────────────
              GestureDetector(
                onLongPressStart: (_) => setState(() => _isRecording = true),
                onLongPressEnd: (_) {
                  setState(() => _isRecording = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AnalysingScreen(
                        fileName: 'Recorded_Call_Live.wav',
                        filePath: 'internal/recording/live_01.wav',
                      ),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color:
                        _isRecording ? AppColors.highRedBg : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isRecording
                          ? AppColors.highRed
                          : AppColors.divider,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _isRecording
                          ? ScaleTransition(
                              scale: _recordPulse,
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: AppColors.highRed,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.highRed
                                          .withValues(alpha: 0.4),
                                      blurRadius: 16,
                                      spreadRadius: 4,
                                    )
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.mic_rounded,
                                      color: Colors.white, size: 26),
                                ),
                              ),
                            )
                          : const Text('🎙️',
                              style: TextStyle(fontSize: 34)),
                      const SizedBox(height: 10),
                      Text(
                        _isRecording ? 'Recording…' : 'Hold to Record',
                        style: AppTextStyles.subtitle.copyWith(
                          color: _isRecording
                              ? AppColors.highRed
                              : AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Press & hold during a suspicious call',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Selected File Chip ────────────────────────────────────
              if (hasFile)
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        const Text('🎵', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _pickedFile!.name,
                                style: AppTextStyles.subtitle
                                    .copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              Text(
                                '${_formatBytes(_pickedFile!.size)}'
                                ' · ${_extension(_pickedFile!.name)}',
                                style: AppTextStyles.caption
                                    .copyWith(color: AppColors.textLight),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _pickedFile = null),
                          child: const Icon(Icons.close_rounded,
                              color: AppColors.textLight, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),

              const Spacer(),

              // ── Analyse Button ────────────────────────────────────────
              AnimatedOpacity(
                opacity: hasFile ? 1.0 : 0.4,
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  onTap: hasFile ? _analyse : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: hasFile
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.30),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              )
                            ]
                          : [],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Analyse Now',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
