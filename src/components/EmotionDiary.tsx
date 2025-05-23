'use client';

import { useState, useEffect } from 'react';
import { ChevronLeft } from 'lucide-react';

interface EmotionDiaryProps {
  goBack: () => void;
}

interface DiaryEntry {
  id: string;
  date: string;
  mood: string;
  category: string;
  content: string;
}

export default function EmotionDiary({ goBack }: EmotionDiaryProps) {
  const [date, setDate] = useState('');
  const [mood, setMood] = useState('');
  const [category, setCategory] = useState('');
  const [content, setContent] = useState('');
  const [entries, setEntries] = useState<DiaryEntry[]>([]);
  const [filtered, setFiltered] = useState<DiaryEntry[]>([]);

  useEffect(() => {
    const fetchEntries = async () => {
      const res = await fetch('/api/diary'); // ✅ 백엔드 API 호출
      const data = await res.json();
      setEntries(data);
      setFiltered(data);
    };
    fetchEntries();
  }, []);

  const saveEntry = async () => {
    const newEntry: Omit<DiaryEntry, 'id'> = { date, mood, category, content };
    const res = await fetch('/api/diary', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(newEntry)
    });
    const saved = await res.json();
    const updated = [...entries, saved];
    setEntries(updated);
    setFiltered(updated);
    setMood('');
    setCategory('');
    setContent('');
  };

  const filterBy = (key: 'mood' | 'category' | 'month', value: string) => {
    const filtered = entries.filter(e =>
      key === 'month' ? e.date.startsWith(value) : e[key] === value
    );
    setFiltered(filtered);
  };

  return (
    <div className="min-h-screen bg-pink-50 p-6">
      <button
        onClick={goBack}
        className="flex items-center text-pink-700 text-sm font-medium mb-4"
      >
        <ChevronLeft className="w-5 h-5 mr-2" />
        돌아가기
      </button>

      <h1 className="text-2xl font-bold text-pink-600 mb-6">📔 감정일기 작성</h1>

      <div className="bg-white rounded-lg shadow-md p-6 space-y-4">
        <input
          type="date"
          value={date}
          onChange={(e) => setDate(e.target.value)}
          className="w-full border border-gray-300 rounded px-3 py-2 text-sm"
        />
        <input
          type="text"
          value={mood}
          onChange={(e) => setMood(e.target.value)}
          placeholder="오늘의 감정 (예: 행복, 우울)"
          className="w-full border border-gray-300 rounded px-3 py-2 text-sm"
        />
        <input
          type="text"
          value={category}
          onChange={(e) => setCategory(e.target.value)}
          placeholder="카테고리 (예: 가족, 친구, 일)"
          className="w-full border border-gray-300 rounded px-3 py-2 text-sm"
        />
        <textarea
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="오늘의 감정을 적어보세요..."
          className="w-full border border-gray-300 rounded px-3 py-2 text-sm h-32 resize-none"
        />
        <button
          onClick={saveEntry}
          className="w-full bg-pink-500 text-white py-2 rounded font-semibold hover:bg-pink-600 transition"
        >
          저장하기
        </button>
      </div>

      <div className="mt-8">
        <h2 className="text-lg font-bold text-pink-600 mb-2">🗂 일기 목록 필터</h2>
        <div className="flex flex-wrap gap-2 mb-4">
          <button onClick={() => filterBy('month', '2025-04')} className="bg-gray-100 text-sm px-3 py-1 rounded">4월</button>
          <button onClick={() => filterBy('month', '2025-05')} className="bg-gray-100 text-sm px-3 py-1 rounded">5월</button>
          <button onClick={() => filterBy('mood', '행복')} className="bg-yellow-100 text-sm px-3 py-1 rounded">행복</button>
          <button onClick={() => filterBy('mood', '우울')} className="bg-blue-100 text-sm px-3 py-1 rounded">우울</button>
          <button onClick={() => filterBy('category', '가족')} className="bg-green-100 text-sm px-3 py-1 rounded">가족</button>
          <button onClick={() => filterBy('category', '일')} className="bg-green-100 text-sm px-3 py-1 rounded">일</button>
        </div>

        <ul className="space-y-2">
          {filtered.map((entry) => (
            <li key={entry.id} className="bg-white p-4 rounded shadow">
              <p className="text-sm text-gray-500">{entry.date} • {entry.mood} • {entry.category}</p>
              <p className="mt-1">{entry.content}</p>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
