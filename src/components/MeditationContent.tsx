'use client';

import { useState } from 'react';
import { ChevronLeft } from 'lucide-react';

interface MeditationContentProps {
  goBack: () => void;
}

export default function MeditationContent({goBack}: MeditationContentProps ) {
  const [sound, setSound] = useState('수면 명상');
  const [bgSound, setBgSound] = useState(false);

  const sources: Record<string, string> = {
    '수면 명상': '/sounds/sleep.mp3',
    '스트레스 해소': '/sounds/stress.mp3',
    '마음 안정': '/sounds/peace.mp3',
  };

  return (
    <div className="min-h-screen bg-indigo-50 p-4">
       {/* 🔙 뒤로가기 버튼 */}
      <button onClick={goBack} className="flex items-center text-indigo-700 text-sm font-medium mb-4">
      <ChevronLeft className="w-5 h-5 mr-1" />
      뒤로가기
      </button>
      <h1 className="text-2xl font-bold text-indigo-600 mb-4">🧘 명상 & 릴렉스</h1>
      <div className="flex gap-2 mb-4">
        {Object.keys(sources).map((label) => (
          <button
            key={label}
            onClick={() => setSound(label)}
            className={`px-4 py-2 rounded-full text-sm font-medium transition ${sound === label ? 'bg-indigo-500 text-white' : 'bg-indigo-100 text-indigo-800'}`}
          >
            {label}
          </button>
        ))}
      </div>

      <div className="bg-white rounded-lg shadow p-4">
        <p className="mb-2 text-gray-600 font-semibold">🎧 {sound} 오디오</p>
        <audio controls className="w-full">
          <source src={sources[sound]} type="audio/mpeg" />
          오디오를 지원하지 않는 브라우저입니다.
        </audio>
        <label className="mt-3 flex items-center gap-2 text-sm">
          <input
            type="checkbox"
            checked={bgSound}
            onChange={() => setBgSound(!bgSound)}
          />
          배경 사운드 (빗소리)
        </label>
      </div>
    </div>
  );
}