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

export default function EmotionDiary({goBack} : EmotionDiaryProps) {
  const [date, setDate] = useState('');
  const [mood, setMood] = useState('');
  const [category, setCategory] = useState('');
  const [content, setContent] = useState('');
  const [entries, setEntries] = useState<DiaryEntry[]>([]);
  const [filtered, setFiltered] = useState<DiaryEntry[]>([]);

  useEffect(() => {
    const stored = localStorage.getItem('emotionDiary');
    if (stored) {
      const parsed = JSON.parse(stored);
      setEntries(parsed);
      setFiltered(parsed);
    }
  }, []);

  const saveEntry = () => {
    const newEntry: DiaryEntry = {
      id: Date.now().toString(),
      date,
      mood,
      category,
      content,
    };
    const updated = [...entries, newEntry];
    setEntries(updated);
    setFiltered(updated);
    localStorage.setItem('emotionDiary', JSON.stringify(updated));
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
    <div className="min-h-screen bg-pink-50 p-4">
      <button
        onClick={goBack}
        className="flex items-center text-pink-700 text-sm font-medium mb-4 self-start"
      >
        <ChevronLeft className="w-5 h-5 mr-1" />
        뒤로가기
      </button>
      <h1 className="text-2xl font-bold text-pink-600 mb-4">📔 감정일기 작성</h1>
      <input
        type="date"
        value={date}
        onChange={(e) => setDate(e.target.value)}
        className="w-full p-2 border rounded mb-2"
      />
      <input
        type="text"
        value={mood}
        onChange={(e) => setMood(e.target.value)}
        placeholder="오늘의 감정 (예: 행복, 우울)"
        className="w-full p-2 border rounded mb-2"
      />
      <input
        type="text"
        value={category}
        onChange={(e) => setCategory(e.target.value)}
        placeholder="카테고리 (예: 가족, 친구, 일)"
        className="w-full p-2 border rounded mb-2"
      />
      <textarea
        value={content}
        onChange={(e) => setContent(e.target.value)}
        placeholder="오늘 있었던 일을 적어보세요..."
        className="w-full p-2 border rounded h-32 mb-2"
      />
      <button onClick={saveEntry} className="bg-pink-500 text-white px-4 py-2 rounded">저장하기</button>

      <div className="mt-6">
        <h2 className="text-lg font-semibold mb-2">🗂 일기 목록 필터</h2>
        <div className="flex gap-2 flex-wrap mb-4">
          <button onClick={() => filterBy('month', '2025-04')} className="bg-gray-100 px-3 py-1 rounded">4월</button>
          <button onClick={() => filterBy('month', '2025-05')} className="bg-gray-100 px-3 py-1 rounded">5월</button>
          <button onClick={() => filterBy('mood', '행복')} className="bg-yellow-100 px-3 py-1 rounded">행복</button>
          <button onClick={() => filterBy('mood', '우울')} className="bg-blue-100 px-3 py-1 rounded">우울</button>
          <button onClick={() => filterBy('category', '가족')} className="bg-green-100 px-3 py-1 rounded">가족</button>
          <button onClick={() => filterBy('category', '일')} className="bg-green-100 px-3 py-1 rounded">일</button>
        </div>
        <ul className="space-y-2">
          {filtered.map((entry) => (
            <li key={entry.id} className="bg-white p-3 rounded shadow">
              <p className="text-sm text-gray-500">{entry.date} • {entry.mood} • {entry.category}</p>
              <p>{entry.content}</p>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
