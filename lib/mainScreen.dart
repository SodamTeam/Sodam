// Sodam/lib/mainScreen.dart

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'sera_chat.dart';
import 'harin_chat.dart';
import 'Yuri_chat.dart';
import 'Mina_chat.dart';
import 'auth_services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

enum PageState { intro, select, chat }

class _HomePageState extends State<HomePage> {
  PageState _page = PageState.intro;
  int selectedId = 1;
  bool isSelected = false;

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

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
      "features": ['감정일기 작성 도우미', '릴렉스 콘텐츠', '응원 메시지 생성기'],
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
          appBar: AppBar(
            title: const Text(
              "소담",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                fontFamily: 'Pretendard',
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.black87),
                onPressed: _logout,
              ),
            ],
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF3E8FF), // soft lavender
                  Color(0xFFFFFBF0), // warm ivory
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B4B8A).withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/introicon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "소담에 오신 걸 환영해요 🌸",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF5B4B8A),
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "맞춤형 챗봇을 선택해봐!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF8F7BA3),
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "일상에 스며드는 AI 친구, 소담",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFFB8AFC9),
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: 220,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFFFCEEF3),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _page = PageState.select;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: const Color(0xFF5B4B8A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.favorite_outline),
                          SizedBox(width: 8),
                          Text(
                            "소담 친구 만나기",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      case PageState.select:
        return Scaffold(
          appBar: AppBar(
            title: const Text("캐릭터 선택"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CarouselSlider.builder(
                  itemCount: slides.length,
                  options: CarouselOptions(
                    height: 500.0,
                    enlargeCenterPage: true,
                    viewportFraction: 0.8,
                    onPageChanged: (index, reason) {
                      final id = slides[index]["id"];
                      if (id != null) {
                        setState(() {
                          selectedId = id;
                        });
                      }
                    },
                  ),
                  itemBuilder: (context, index, realIndex) {
                    final slide = slides[index];
                    isSelected = selectedId == slide["id"];
                    return Stack(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 5.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: AssetImage(slide["src"]),
                              fit: BoxFit.cover,
                              colorFilter: isSelected
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
                                        onPressed: () => setState(() {
                                          selectedId = 0;
                                          isSelected = false;
                                        }),
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
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _page = PageState.chat;
                                        selectedId = slide["id"];
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                    ),
                                    child: Text("${slide["name"]}와 채팅 시작하기"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        );

      case PageState.chat:
        switch (selectedId) {
          case 1:
            return HarinChat(
              goBack: () {
                setState(() {
                  _page = PageState.select;
                });
              },
            );
          case 2:
            return SeraChat(
              goBack: () {
                setState(() {
                  _page = PageState.select;
                });
              },
            );
          case 3:
            return MinaChat(
              goBack: () {
                setState(() {
                  _page = PageState.select;
                });
              },
            );
          case 4:
            return YuriChat(
              goBack: () {
                setState(() {
                  _page = PageState.select;
                });
              },
            );
          default:
            return const Scaffold(
              body: Center(child: Text("캐릭터를 선택해주세요.")),
            );
        }
    }
  }
}
