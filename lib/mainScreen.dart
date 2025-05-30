// Sodam/lib/mainScreen.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'sera_chat.dart';
import 'harin_chat.dart';
import 'Yuri_chat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

enum PageState { intro, select, chat }

class _HomePageState extends State<HomePage> {
  PageState _page = PageState.intro;
  int? selectedId;

  final List<Map<String, dynamic>> slides = [
    {
      "id": 1,
      "src": "assets/girl1.png",
      "name": "하린",
      "description": "감성 문학을 좋아하는 소녀",
      "features": ['소설 작성 도우미', '문학 분석', '시 쓰기 놀이', '독서 추천 & 기록'],
    },
    {
      "id": 2,
      "src": "assets/girl2.png",
      "name": "세라",
      "description": "기술에 빠진 테크 소녀",
      "features": ['앱/웹 아이디어 도우미', 'IT 용어 쉽게 풀기', '유용한 앱 소개', '코딩 놀이'],
    },
    {
      "id": 3,
      "src": "assets/girl3.png",
      "name": "미나",
      "description": "마음을 어루만지는 힐링 소녀",
      "features": ['감정일기 작성 도우미', '릴렉스 콘텐츠', '응원 메시지 생성기', '편안한 대화 & 상담'],
    },
    {
      "id": 4,
      "src": "assets/girl4.png",
      "name": "유리",
      "description": "세상을 탐험하는 과학 소녀",
      "features": ['퀴즈 챌린지', '실험 시뮬레이션', '콰학 뉴스 브리핑', '별자리 관찰 가이드'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    switch (_page) {
      case PageState.intro:
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "안녕하세요!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text("맞춤형 챗봇을 선택해봐!", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _page = PageState.select;
                    });
                  },
                  child: const Text("AI 챗봇 선택"),
                ),
              ],
            ),
          ),
        );

      case PageState.select:
        return Scaffold(
          appBar: AppBar(title: const Text("캐릭터 선택")),
          body: CarouselSlider.builder(
            itemCount: slides.length,
            options: CarouselOptions(
              height: 500.0,
              enlargeCenterPage: true,
              viewportFraction: 0.8,
            ),
            itemBuilder: (context, index, realIndex) {
              final slide = slides[index];
              final isSelected = selectedId == slide["id"];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedId = isSelected ? null : slide["id"];
                  });
                },
                child: Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage(slide["src"]),
                          fit: BoxFit.cover,
                          colorFilter:
                              isSelected
                                  ? ColorFilter.mode(
                                    Colors.black.withOpacity(0.5),
                                    BlendMode.darken,
                                  )
                                  : null,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Positioned.fill(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "📖 ${slide["name"]} - ${slide["description"]}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed:
                                        () => setState(() => selectedId = null),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              ...List.generate(slide["features"].length, (i) {
                                return Text(
                                  "• ${slide["features"][i]}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                );
                              }),
                              const SizedBox(height: 10),
                              if (slide["id"] == 1)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _page = PageState.chat;
                                      selectedId = 1;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text("하린과 채팅 시작하기"),
                                ),
                              if (slide["id"] == 2)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _page = PageState.chat;
                                      selectedId = 2;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text("세라와 채팅 시작하기"),
                                ),
                              if (slide["id"] == 4)
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _page = PageState.chat;
                                      selectedId = 4;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text("유리와 채팅 시작하기"),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        );

      case PageState.chat:
        if (selectedId == 1) {
          return HarinChat(
            goBack: () {
              setState(() {
                _page = PageState.select;
              });
            },
          );
        } else if (selectedId == 2) {
          return SeraChat(
            goBack: () {
              setState(() {
                _page = PageState.select;
              });
            },
          );
        } else if (selectedId == 4) {
          return YuriChat(
            goBack: () {
              setState(() {
                _page = PageState.select;
              });
            },
          );
        }
        {}
        return const Scaffold(body: Center(child: Text("캐릭터를 선택해주세요.")));
    }
  }
}
