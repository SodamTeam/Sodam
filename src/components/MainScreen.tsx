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
  return (
    <div className="w-96 h-[812px] relative bg-white overflow-hidden">
    <div className="w-96 h-11 left-0 top-0 absolute overflow-hidden">
        <div className="w-5 h-3 left-[336px] top-[17.33px] absolute opacity-30 rounded-sm border border-black" />
        <div className="w-[1.33px] h-1 left-[359px] top-[21px] absolute opacity-40 bg-black" />
        <div className="w-4 h-2 left-[338px] top-[19.33px] absolute bg-black rounded-sm" />
        <div className="w-14 h-5 left-[21px] top-[12px] absolute rounded-[32px]">
            <div className="w-7 h-3 left-[12.45px] top-[5.17px] absolute bg-black" />
        </div>
    </div>
    <div className="w-96 h-14 left-0 top-[44px] absolute">
        <img className="w-6 h-6 left-[335px] top-[16px] absolute rounded-full" src="https://placehold.co/24x24" />
        <div className="left-[151px] top-[14px] absolute text-center justify-start text-black text-xl font-semibold font-['Inter'] leading-7">Sodam</div>
        <div className="w-6 h-6 left-[16px] top-[16px] absolute">
            <div className="w-4 h-0.5 left-[3.10px] top-[5.10px] absolute bg-black" />
            <div className="w-3.5 h-0.5 left-[3.10px] top-[11.10px] absolute bg-black" />
            <div className="w-4 h-0.5 left-[3.10px] top-[17.10px] absolute bg-black" />
        </div>
        <div className="w-4 h-5 left-[308px] top-[19px] absolute outline outline-2 outline-offset-[-1px] outline-Main-bulma" />
    </div>
    <div className="left-[99px] top-[133px] absolute justify-start text-black text-4xl font-semibold font-['Inter']">안녕하세요!</div>
    <div className="left-[67px] top-[192px] absolute justify-start text-black text-2xl font-medium font-['Inter']">맞춤형 챗봇을 선택해봐!</div>
    <div className="w-80 left-[19px] top-[738px] absolute inline-flex flex-col justify-start items-start gap-2">
        <div className="self-stretch pl-3 pr-4 py-3 bg-Main-gohan rounded-lg outline outline-1 outline-offset-[-1px] outline-Main-beerus inline-flex justify-start items-center gap-2">
            <div className="w-6 h-6 relative">
                <div className="w-3.5 h-3.5 left-[5.25px] top-[5.25px] absolute outline outline-[0.75px] outline-offset-[-0.38px] outline-Main-bulma" />
            </div>
            <div className="flex-1 justify-center text-Main-trunks text-base font-normal font-['DM_Sans'] leading-normal">무엇을 도와드릴까요?</div>
            <div className="justify-center text-Main-trunks text-sm font-normal font-['DM_Sans'] leading-tight">지우기</div>
        </div>
    </div>
    <div className="w-36 h-14 left-[114px] top-[233px] absolute bg-blue-200 rounded-3xl">
        <div className="w-36 h-36 left-[13.64px] top-[40.04px] absolute rounded-[10px]" />
        <div className="left-[35.16px] top-[20.21px] absolute justify-start text-black text-base font-bold font-['Inter']">AI 챗봇 선택</div>
    </div>
    <div className="w-96 h-96 left-[7px] top-[304px] absolute bg-Grays-Gray-3 rounded-[34.42px] border border-green-500 overflow-hidden">
  {/* 캐릭터 이미지 및 텍스트 */}
  <div className="relative w-full h-full p-4">
    {/* 캐릭터 이미지 */}
    <div className="absolute left-4 top-16">
      <img 
        src="https://placehold.co/120x140" 
        alt="문학소녀 하린" 
        className="w-30 h-36 rounded-full"
      />
    </div>
    
    {/* 캐릭터 이름 및 설명 */}
    <div className="absolute right-10 top-10 bg-blue-200 rounded-3xl shadow-[0px_4px_4px_0px_rgba(0,0,0,0.25)]">
      <div className="w-32 h-6 left-2 top-4 absolute justify-start">
        <span className="text-black text-[10px] font-bold font-['Inter']">📖</span>
        <span className="text-black text-[8px] font-bold font-['Inter']}"> - 문학소녀 미소녀 하린</span>
      </div>
    </div>
  </div>
</div>
    <div className="w-80 h-12 left-[19px] top-[314px] absolute bg-Grays-Gray-3">
        <div className="w-28 h-14 left-[65.05px] top-[3.01px] absolute bg-blue-200 rounded-3xl shadow-[0px_4px_4px_0px_rgba(0,0,0,0.25)]" />
        <div className="w-10 h-9 left-[9px] top-[8px] absolute rounded-full">
            <img className="w-12 h-14 left-0 top-0 absolute rounded-full" src="https://placehold.co/50x53" />
        </div>
        <div className="w-32 h-6 left-[75px] top-[26px] absolute justify-start"><span className="text-black text-[10px] font-bold font-['Inter']">📖</span><span className="text-black text-[8px] font-bold font-['Inter']"> - 문학소녀 미소녀 하린</span></div>
    </div>
    <div className="w-16 h-1.5 left-[156px] top-[646px] absolute bg-Grays-Gray-3 inline-flex justify-start items-start gap-1.5">
        <div className="w-8 h-1.5 bg-white rounded-lg" />
        <div className="w-2 h-1.5 bg-white/50 rounded-lg" />
        <div className="w-2 h-1.5 bg-white/50 rounded-lg" />
        <div className="w-2 h-1.5 bg-white/50 rounded-lg" />
    </div>
</div>
  )
}
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
