import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MeditationContent extends StatefulWidget {
  final VoidCallback onGoBack;
  const MeditationContent({super.key, required this.onGoBack});

  @override
  State<MeditationContent> createState() => _MeditationContentState();
}

class _MeditationContentState extends State<MeditationContent> {
  final AudioPlayer _mainPlayer = AudioPlayer();
  final AudioPlayer _bgPlayer = AudioPlayer();

  bool isPlaying = false;
  String selectedMain = '기상 명상';
  String? selectedBg;

  final Map<String, String> mainSources = {
    '기상 명상': 'assets/sounds/wake_web.mp3',
    '스트레스 해소': 'assets/sounds/stress_fixed.mp3',
    '마음 안정': 'assets/sounds/peace_fixed.mp3',
  };

  final Map<String, String> bgSources = {
    '기상': 'assets/sounds/wake_web.mp3',
    '힐링': 'assets/sounds/stress_fixed.mp3',
    '안정': 'assets/sounds/peace_fixed.mp3',
    '빗소리': 'assets/sounds/rain_fixed.mp3',
  };

  @override
  void initState() {
    super.initState();
    _mainPlayer.onPlayerStateChanged.listen((state) {
      setState(() => isPlaying = state == PlayerState.playing);
    });
    _bgPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _mainPlayer.dispose();
    _bgPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleMain() async {
    if (isPlaying) {
      await _mainPlayer.pause();
    } else {
      await _mainPlayer.stop();
      await _mainPlayer.play(AssetSource(mainSources[selectedMain]!));
    }
  }

  Future<void> _selectMain(String label) async {
    selectedMain = label;
    await _mainPlayer.stop();
    await _mainPlayer.play(AssetSource(mainSources[label]!));
    setState(() => isPlaying = true);
  }

  Future<void> _selectBg(String label) async {
    if (selectedBg == label) {
      await _bgPlayer.stop();
      selectedBg = null;
    } else {
      selectedBg = label;
      await _bgPlayer.stop();
      await _bgPlayer.play(AssetSource(bgSources[label]!));
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: widget.onGoBack,
                icon: const Icon(Icons.chevron_left),
                label: const Text("뒤로가기"),
              ),
              const SizedBox(height: 10),
              const Text(
                "🧘 명상 & 릴렉스",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                children: mainSources.keys.map((label) {
                  return ChoiceChip(
                    label: Text(label),
                    selected: label == selectedMain,
                    onSelected: (_) => _selectMain(label),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🎧 $selectedMain 오디오", style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _toggleMain,
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(isPlaying ? '정지' : '재생'),
                    ),
                    const SizedBox(height: 20),
                    Text("🔊 배경 사운드", style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: bgSources.keys.map((label) {
                        final sel = label == selectedBg;
                        return ChoiceChip(
                          label: Text(label),
                          selected: sel,
                          onSelected: (_) => _selectBg(label),
                          selectedColor: Colors.indigo.withOpacity(0.2),
                        );
                      }).toList(),
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
}
