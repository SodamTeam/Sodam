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
  final AudioPlayer _rainPlayer = AudioPlayer();
  bool isPlaying = false;
  bool backgroundRain = false;
  String selected = '수면 명상';

  final Map<String, String> sources = {
    '수면 명상': 'assets/sounds/sleep.mp3',
    '스트레스 해소': 'assets/sounds/stress.mp3',
    '마음 안정': 'assets/sounds/peace.mp3',
  };

  @override
  void initState() {
    super.initState();
    _mainPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _mainPlayer.dispose();
    _rainPlayer.dispose();
    super.dispose();
  }

  Future<void> _playMainSound(String label) async {
    await _mainPlayer.stop();
    await _mainPlayer.play(AssetSource(sources[label]!));
  }

  Future<void> _toggleRain(bool enabled) async {
    setState(() => backgroundRain = enabled);
    if (enabled) {
      await _rainPlayer.setReleaseMode(ReleaseMode.loop);
      await _rainPlayer.play(AssetSource("assets/sounds/rain.mp3"));
    } else {
      await _rainPlayer.stop();
    }
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
                children: sources.keys.map((label) {
                  final isSelected = label == selected;
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => selected = label);
                      _playMainSound(label);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("🎧 $selected 오디오", style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          onPressed: () {
                            if (isPlaying) {
                              _mainPlayer.pause();
                            } else {
                              _playMainSound(selected);
                            }
                          },
                        ),
                        const Text("명상음 재생/정지")
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: backgroundRain,
                          onChanged: (val) => _toggleRain(val!),
                        ),
                        const Text("배경 사운드 (빗소리)")
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
