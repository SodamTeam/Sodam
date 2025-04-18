"use client";

import { useState } from 'react';
import { BookOpen, PenTool, BookMarked, FileText } from 'lucide-react';
import { Swiper, SwiperSlide } from 'swiper/react';
import 'swiper/css';
import SeraChat from './SeraChat';

export default function Home() {
  const [page, setPage] = useState(1);
  const [selectedId, setSelectedId] = useState(null);

  const slides = [
    {
      id: 1,
      src: '/girl1.png',
      name: '하린',
      description: '감성 문학을 좋아하는 소녀',
      features: [
        '소설 작성 도우미',
        '문학 분석',
        '시 쓰기 놀이',
        '독서 추천 & 기록'
      ]
    },
    {
      id: 2,
      src: '/girl2.png',
      name: '세라',
      description: '기술에 빠진 테크 소녀',
      features: [
        '앱/웹 아이디어 도우미',
        'IT 용어 쉽게 풀기',
        '유용한 앱 소개',
        '코딩 놀이'
      ]
    },
    {
      id: 3,
      src: '/girl3.png',
      name: '미나',
      description: '마음을 어루만지는 힐링 소녀',
      features: [
        '감정일기 작성 도우미',
        '릴렉스 콘텐츠',
        '응원 메시지 생성기',
        '편안한 대화 & 상담'
      ]
    },
    {
      id: 4,
      src: '/girl4.png',
      name: '유리',
      description: '세상을 탐험하는 과학 소녀',
      features: [
        '퀴즈 챌린지',
        '실험 시뮬레이션',
        '콰학 뉴스 브리핑',
        '별자리 관찰 가이드'
      ]
    },
  ];

  if (page === 3) {
    return <SeraChat goBack={() => setPage(2)} />;
  }  

  if (page === 1) {
    return (
      <div className="flex flex-col items-center justify-center h-screen text-center">
        <h1 className="text-3xl font-bold mb-2">안녕하세요!</h1>
        <p className="text-lg mb-8">맞춤형 챗봇을 선택해봐!</p>
        <button
          onClick={() => setPage(2)}
          className="bg-blue-200 hover:bg-blue-300 text-black font-semibold py-2 px-4 rounded-full"
        >
          AI 챗봇 선택
        </button>
      </div>
    );
  }

  if (page === 2) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen pt-10 px-4">
        <Swiper
          spaceBetween={30}
          slidesPerView={1}
          className="w-80 h-[500px]"
        >
          {slides.map((slide) => (
            <SwiperSlide key={slide.id}>
              <div
                className="relative w-full h-full rounded-xl overflow-hidden shadow-lg"
                onClick={() => {
                  if (selectedId === slide.id) {
                    if (slide.id === 2) {
                      setPage(3); // 세라 클릭 → 설명 나왔을 때 한 번 더 클릭 → 채팅 진입
                    }
                  } else {
                    setSelectedId(slide.id); // 첫 클릭 → 상세 정보 노출
                  }
                }}
              >
                <img
                  src={slide.src}
                  alt={slide.name}
                  className="w-full h-full object-cover cursor-pointer"
                />

                <div className="absolute bottom-0 left-0 w-full bg-black bg-opacity-50 text-white p-3">
                  <p className="text-lg font-bold">
                    📖 {slide.name} - {slide.description}
                  </p>
                </div>
                {selectedId === slide.id && (
                  <div className="absolute bottom-0 left-0 w-full text-white p-4 bg-black/70 backdrop-blur-md animate-fade-in-up">
                    <p className="text-base font-semibold mb-2">{slide.name}{slide.name === '하린' ? '과' : '와'} 함께 할 수 있는 것들</p>
                    <ul className="text-sm space-y-1">
                      {slide.features.map((feature, idx) => (
                        <li key={idx} className="flex items-center gap-2">
                          {idx === 0 && <PenTool className="w-4 h-4" />}
                          {idx === 1 && <FileText className="w-4 h-4" />}
                          {idx === 2 && <BookMarked className="w-4 h-4" />}
                          {idx === 3 && <BookOpen className="w-4 h-4" />}
                          {feature}
                        </li>
                      ))}
                    </ul>
                  </div>
                )}
              </div>
            </SwiperSlide>
          ))}
        </Swiper>
      </div>
    );
  }

  return null;
}