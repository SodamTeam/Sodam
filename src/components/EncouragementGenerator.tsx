'use client';

import { useState } from 'react';
import { ChevronLeft } from 'lucide-react';

interface EncouragementGeneratorProps {
  goBack: () => void;
}

export default function EncouragementGenerator({ goBack }: EncouragementGeneratorProps) {
  const messages = [
    '너의 존재만으로도 소중해 🌷',
    '오늘 하루도 잘 버틴 너, 정말 대단해 💪',
    '조금 쉬어가도 괜찮아. 항상 응원해! 💖',
    '괜찮아. 넌 할 수 있어. 🌈',
  ];
  const [message, setMessage] = useState(messages[0]);

  const generateMessage = () => {
    const random = Math.floor(Math.random() * messages.length);
    setMessage(messages[random]);
  };

  return (
    <div className="min-h-screen flex flex-col items-center bg-pink-50 p-6">
      {/* 🔙 뒤로가기 버튼 */}
      <button
        onClick={goBack}
        className="flex items-center text-pink-700 text-sm font-medium mb-4 self-start"
      >
        <ChevronLeft className="w-5 h-5 mr-1" />
        뒤로가기
      </button>

      <h2 className="text-2xl font-bold text-pink-600 mb-4">💌 응원 메시지 생성기</h2>

      <div className="relative mb-4">
        <div className="bg-white border border-pink-200 shadow p-4 rounded max-w-md text-center">
          {message}
        </div>
        <div className="absolute -top-6 left-1/2 transform -translate-x-1/2 bg-pink-300 text-white px-3 py-1 rounded-full">
          힐링소녀
        </div>
      </div>

      <button
        onClick={generateMessage}
        className="bg-pink-400 text-white px-6 py-2 rounded hover:bg-pink-500"
      >
        오늘의 한마디 받기
      </button>
    </div>
  );
}
