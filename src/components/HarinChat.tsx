'use client';
import { useState } from 'react';
import Image from 'next/image';
import '../app/harin.css';

interface HarinChatProps {
  goBack: () => void;
}

export default function HarinChat({ goBack }: HarinChatProps) {
  const [messages, setMessages] = useState([
    { sender: 'harin', text: '안녕하세요, 저는 문학 소녀 하린이에요 🌸 오늘은 어떤 이야기를 나눠볼까요?', showProfile: true}
  ]);
  const [input, setInput] = useState('');
  const [mode, setMode] = useState('default');

  const handleSend = async () => {
    if (!input.trim()) return;

    const userMessage = input.trim();
    setMessages([...messages, { sender: 'user', text: userMessage }]);
    setInput('');

    let harinReply = '';

    try {
      if (mode === 'novel-helper') {
        const res = await fetch('/api/gpt-novel', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ prompt: userMessage }),
        });
        const data = await res.json();
        harinReply = data.result;
      } else if (mode === 'literary-analysis') {
        const res = await fetch('/api/gpt-analysis', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ prompt: userMessage }),
        });
        const data = await res.json();
        harinReply = data.result;
      } else if (mode === 'poetry-play') {
        const res = await fetch('/api/gpt-poetry', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ prompt: userMessage }),
        });
        const data = await res.json();
        harinReply = data.result;
      } else if (mode === 'book-recommendation') {
        const res = await fetch('/api/book-recommend', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ keyword: userMessage }),
        });
        const data = await res.json();
        harinReply = data.result;
      } else {
        const res = await fetch('/api/chat', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ message: userMessage }),
        });
        const data = await res.json();
        harinReply = data.result;
      }
    } catch (error) {
      harinReply = '오류가 발생했어요. 다시 시도해 주세요.';
    }

    setMessages((prev) => [...prev, { sender: 'harin', text: harinReply, showProfile: false }]);
  };

  return (
    <div className="iphone-frame">
      <header className="app-header">
        <button onClick={goBack} className="mr-2 text-sm text-blue-500 hover:underline">← 뒤로</button>
        <span className="app-title">하린</span>
        <Image src="/girl1.png" alt="하린" width={28} height={28} className="profile" />
      </header>

      <div className="chat-container">
        <div className="intro-message">
          <div className="intro-header">
            <Image src="/harin chat.jpg" alt="하린" width={36} height={36} className="profile-small-intro" />
            <span className="intro-name">하린</span>
          </div>
        </div>
        <div className="chat-messages">
          {messages.map((m, idx) => (
            <div key={idx} className={`message ${m.sender} animate-slide-up-fade`}>
              {m.sender === 'harin' && m.showProfile && (
                <span className="message-profile">
                  <Image src="/harin chat.jpg" alt="하린" width={24} height={24} className="profile-small" />
                </span>
              )}
              {m.text}
            </div>
          ))}
        </div>

        <div className="functions">
          <button onClick={() => setMode('novel-helper')} className="function-btn">📝 소설 작성 도우미</button>
          <button onClick={() => setMode('literary-analysis')} className="function-btn">📘 문학 분석</button>
          <button onClick={() => setMode('poetry-play')} className="function-btn">📄 시 쓰기 놀이</button>
          <button onClick={() => setMode('book-recommendation')} className="function-btn">📚 독서 추천</button>
        </div>

        <div className="chat-input">
          <input
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
            placeholder="메시지를 입력하세요..."
            className="input-field"
          />
          <button onClick={handleSend} className="send-btn">전송</button>
        </div>
      </div>
    </div>
  );
}
