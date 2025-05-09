'use client';

import { useState } from 'react';
import { ChevronLeft, Bell } from 'lucide-react';
import Image from 'next/image';

interface SeraChatProps {
  goBack: () => void;
}

/* ➊ 메시지 타입 선언 ─ 선택적(?) 프로퍼티로 표시 */
type ChatMessage = {
  sender: string;
  text:   string;
  type?:  'intro' | 'text' | 'image';
  image?: string;
};

export default function SeraChat({ goBack }: SeraChatProps) {
  /* ➋ 제네릭으로 타입 고정 */
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      sender: '세라',
      type:   'intro',
      text:   '안녕하세요!\n전 세라라고 해요.',
      image:  '/girl2.png',
    },
  ]);

  const [input, setInput] = useState('');

  const handleSend = () => {
    if (!input.trim()) return;

    /* ➌ 새 메시지는 sender·text만 넣어도 OK */
    setMessages(prev => [
      ...prev,
      { sender: '나', text: input, type: 'text' }   // image 없음 → 오류 X
    ]);

    setInput('');
  };

  /* --- 이하 JSX는 그대로 --- */

  return (
    <div className="flex flex-col h-screen bg-white">
      {/* 상단 네비게이션 */}
      <div className="flex items-center justify-between px-4 py-3 border-b">
        <button onClick={goBack}>
          <ChevronLeft />
        </button>
        <h1 className="text-lg font-semibold">캐릭터 챗</h1>
        <div className="flex items-center gap-3">
          <Bell className="w-5 h-5" />
          <Image
            src="/profile.png"
            alt="내 프로필"
            width={24}
            height={24}
            className="rounded-full"
          />
        </div>
      </div>

      {/* 채팅 영역 */}
      <div className="flex-1 overflow-y-auto px-4 py-3 space-y-6 flex flex-col justify-between">
        <div className="space-y-6">
          {messages.map((msg, index) => (
            <div
              key={index}
              className={`flex flex-col ${msg.sender === '세라' ? 'items-start' : 'items-end'}`}
            >
              {/* 세라 프로필 + 이름 */}
              {msg.sender === '세라' && (
                <div className="flex items-center mb-1 gap-2">
                  <Image
                    src="/girl2_icon.png"
                    alt="세라"
                    width={28}
                    height={28}
                    className="rounded-full"
                  />
                  <span className="text-sm text-gray-700 font-medium">세라</span>
                </div>
              )}

              {/* 말풍선 */}
              <div className="max-w-[80%]">
                <div
                  className={`rounded-2xl px-4 py-3 whitespace-pre-line ${
                    msg.sender === '세라'
                      ? 'bg-gray-100 text-black'
                      : 'bg-purple-100 text-black' // 사용자 말풍선 색상
                  }`}
                >
                  {/* 소개 메시지는 이미지 포함 */}
                  {msg.type === 'intro' && msg.image ? (
                    <>
                      <p className="mb-2">{msg.text.split('\n')[0]}</p>
                      <Image
                        src={msg.image}
                        alt="세라"
                        width={180}
                        height={180}
                        className="rounded-lg mx-auto"
                      />
                      <p className="mt-2">{msg.text.split('\n')[1]}</p>
                    </>
                  ) : (
                    msg.text
                  )}
                </div>
              </div>
            </div>
          ))}
        </div>

        {/* 선택지 버튼 */}
        <div className="flex flex-wrap gap-2">
          {["앱/웹 아이디어", "IT 용어 쉽게 풀기", "유용한 앱 소개", "코딩 놀이"].map((text, idx) => (
            <button
              key={idx}
              onClick={() =>
              setMessages((prev) => [...prev, { sender: '나', text }])
              }
              className="px-3 py-1 bg-gray-200 rounded-full text-sm whitespace-nowrap hover:bg-gray-300 transition"
              >
              {text}
            </button>
            ))}
        </div>



      </div>

      {/* 입력창 */}
      <div className="p-4 border-t flex items-center gap-2">
        <input
          type="text"
          placeholder="대화 시작하기"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          className="flex-1 border rounded-full px-4 py-2 focus:outline-none"
        />
        <button
          onClick={handleSend}
          className="bg-violet-600 text-white rounded-full px-4 py-2 font-medium"
        >
          보내기
        </button>
      </div>
    </div>
  );
}
