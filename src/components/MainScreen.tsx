"use client";

import { useState, useRef } from 'react';
import { BookOpen, PenTool, BookMarked, FileText, X } from 'lucide-react';
import { Swiper, SwiperSlide } from 'swiper/react';
import type { Swiper as SwiperType } from 'swiper';
import 'swiper/css';
import '../app/animations.css';
import SeraChat from './SeraChat';
import HarinChat from './HarinChat';
import YuriChat from './yurimake/YuriChat';

export default function Home() {
  const [page, setPage] = useState(1);
  const [selectedId, setSelectedId] = useState<number | null>(null);
  const swiperRef = useRef<SwiperType | null>(null);

  const slides = [
    { id: 1, src: '/girl1.png', name: '하린', description: '상상을 현실로 그리는 아티스트', features: ['그림 그리기', '스토리텔링', '아이디어 스케치', '디자인 리뷰'] },
    { id: 2, src: '/girl2.png', name: '세라', description: '기술에 빠진 테크 소녀', features: ['앱/웹 아이디어 도우미', 'IT 용어 쉽게 풀기', '유용한 앱 소개', '코딩 놀이'] },
    { id: 3, src: '/girl3.png', name: '미나', description: '마음을 어루만지는 힐링 소녀', features: ['감정일기 작성 도우미', '릴렉스 콘텐츠', '응원 메시지 생성기', '편안한 대화 & 상담'] },
    { id: 4, src: '/girl4.png', name: '유리', description: '세상을 탐험하는 과학 소녀', features: ['실험 아이디어', '과학 원리 설명', '데이터 분석 도우미', '흥미로운 퀴즈'] },
  ];

  if (page === 3) return <SeraChat goBack={() => setPage(2)} />;
  if (page === 4) return <HarinChat goBack={() => setPage(2)} />;
  if (page === 5) return <YuriChat goBack={() => setPage(2)} />;

  if (page === 1) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-white p-4">
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
          onSwiper={swiper => { swiperRef.current = swiper; }}
        >
          {slides.map(slide => (
            <SwiperSlide key={slide.id}>
              <div className="relative w-full h-full rounded-xl overflow-hidden shadow-lg">
                <div
                  className="absolute inset-0 z-10 cursor-pointer"
                  onClick={() => setSelectedId(slide.id === selectedId ? null : slide.id)}
                />

                <img
                  src={slide.src}
                  alt={slide.name}
                  className="w-full h-full object-cover"
                />

                <div className="absolute bottom-0 left-0 w-full bg-black bg-opacity-50 text-white p-3 z-20">
                  <p className="text-lg font-bold">📖 {slide.name} - {slide.description}</p>
                </div>

                {selectedId === slide.id && (
                  <div className="absolute inset-0 flex flex-col bg-black/60 p-6 text-white backdrop-blur-sm rounded-xl animate-slide-up-fade z-30">
                    <button
                      onClick={() => setSelectedId(null)}
                      className="absolute top-3 right-3 p-1 rounded-full bg-white/20 hover:bg-white/30 z-40"
                      aria-label="닫기"
                    >
                      <X className="w-5 h-5" />
                    </button>

                    <p className="text-base font-semibold mb-3">
                      {slide.name}{slide.name === '하린' ? '과' : '와'} 함께 할 수 있는 것들
                    </p>

                    {(slide.id === 1 || slide.id === 2 || slide.id === 4) && (
                      <button
                        onClick={() => setPage(slide.id === 1 ? 4 : slide.id === 2 ? 3 : 5)}
                        className="mb-4 bg-white text-black font-medium py-2 px-4 rounded-full hover:bg-gray-200 self-center z-40"
                      >
                        {slide.name}와 채팅 시작하기
                      </button>
                    )}

                    <div className="flex-1 overflow-y-auto w-full space-y-2">
                      {slide.features.map((feature, idx) => (
                        <div key={idx} className="flex items-center gap-2 px-2">
                          {idx === 0 && <PenTool className="w-4 h-4" />}
                          {idx === 1 && <FileText className="w-4 h-4" />}
                          {idx === 2 && <BookMarked className="w-4 h-4" />}
                          {idx === 3 && <BookOpen className="w-4 h-4" />}
                          <span className="text-sm">{feature}</span>
                        </div>
                      ))}
                    </div>
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
