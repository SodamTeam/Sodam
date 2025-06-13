import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:audioplayers/audioplayers.dart';

class MeditationContent extends StatefulWidget {
  final VoidCallback onGoBack;
  const MeditationContent({super.key, required this.onGoBack});

  @override
  State<MeditationContent> createState() => _MeditationContentState();
}

class _MeditationContentState extends State<MeditationContent> {
  final AudioPlayer _bgPlayer = AudioPlayer();

  String selectedCategory = '기상 수면';
  String? selectedSound;

  final Map<String, Map<String, String>> bgSources = {
    '기상 수면': {
      '기상': 'assets/sounds/wake_fixed.mp3',
      '수면': 'assets/sounds/stress_fixed.mp3',
      '깊은 수면': 'assets/sounds/deep_sleep.mp3',
    },
    '마음 안정': {
      '안정': 'assets/sounds/peace_fixed.mp3',
      '힐링': 'assets/sounds/relax.mp3',
      '진정': 'assets/sounds/calming.mp3',
    },
    '자연': {
      '빗소리': 'assets/sounds/rain_fixed.mp3',
      '바다': 'assets/sounds/ocean.mp3',
      '계곡': 'assets/sounds/mountain.mp3',
    }
  };

  @override
  void initState() {
    super.initState();
    _bgPlayer.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    _bgPlayer.dispose();
    super.dispose();
  }

  Future<void> _selectCategory(String category) async {
    selectedCategory = category;
    selectedSound = null;
    await _bgPlayer.stop();
    setState(() {});
  }

  Future<void> _selectSound(String label) async {
    if (selectedSound == label) {
      await _bgPlayer.stop();
      selectedSound = null;
    } else {
      selectedSound = label;
      await _bgPlayer.stop();
      await _bgPlayer.play(
        kIsWeb
            ? UrlSource(bgSources[selectedCategory]![label]!)
            : AssetSource(bgSources[selectedCategory]![label]!)
      );
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final currentSounds = bgSources[selectedCategory]!;

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
                children: bgSources.keys.map((category) {
                  final selected = selectedCategory == category;
                  return ChoiceChip(
                    label: Text(category),
                    selected: selected,
                    onSelected: (_) => _selectCategory(category),
                    selectedColor: Colors.indigo.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: selected ? Colors.indigo[800] : Colors.black,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    ),
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
                    if (selectedSound != null)
                      Text(
                        "🎧 $selectedCategory - $selectedSound 오디오",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    if (selectedSound != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextButton.icon(
                          onPressed: () => _selectSound(selectedSound!),
                          icon: const Icon(Icons.stop, color: Colors.purple),
                          label: const Text("정지", style: TextStyle(color: Colors.purple)),
                        ),
                      ),
                    const SizedBox(height: 10),
                    Text(
                      "🔊 배경 사운드 (선택 시 자동 재생)",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: currentSounds.keys.map((label) {
                        final selected = label == selectedSound;
                        return ChoiceChip(
                          label: Text(label),
                          selected: selected,
                          onSelected: (_) => _selectSound(label),
                          selectedColor: Colors.deepPurple.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: selected ? Colors.deepPurple[800] : Colors.black,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
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
