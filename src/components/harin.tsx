import { useState, useRef, useEffect } from 'react'
import Head from 'next/head'
import '../styles/harin.css'

export default function HarinPage() {
  const [messages, setMessages] = useState<{ sender: 'user' | 'harin', text: string }[]>([
    { sender: 'harin', text: '안녕하세요, 저는 문학 소녀 하린이에요 🌸\n오늘은 어떤 이야기를 나눠볼까요?' },
  ])
  const [input, setInput] = useState('')
  const [mode, setMode] = useState<'default' | 'novel-helper' | 'literary-analysis' | 'poetry-play' | 'book-recommendation'>('default')
  const chatRef = useRef<HTMLDivElement>(null)

  const handleSend = () => {
    if (!input.trim()) return
    const newMessages = [...messages, { sender: 'user', text: input }]
    setMessages(newMessages)
    setInput('')

    setTimeout(() => {
      const reply = generateHarinReply(input, mode)
      setMessages([...newMessages, { sender: 'user', text: input }, { sender: 'harin', text: reply }])
    }, 600)
  }

  useEffect(() => {
    if (chatRef.current) {
      chatRef.current.scrollTop = chatRef.current.scrollHeight
    }
  }, [messages])

  const generateHarinReply = (userText: string, currentMode: typeof mode) => {
    switch (currentMode) {
      case 'novel-helper':
        return '소설을 작성하는 데 도움이 필요하군요! 어떤 아이디어를 생각하고 계신가요?'
      case 'literary-analysis':
        return '문학 분석을 시작해볼까요? 어떤 작품을 분석할까요?'
      case 'poetry-play':
        return '시를 쓰는 놀이가 시작되었습니다! 어떤 주제로 시를 써볼까요?'
      case 'book-recommendation':
        return '책을 추천해드릴게요! 어떤 장르의 책을 원하시나요?'
      default:
        return '그 이야기도 참 멋지네요. 조금 더 들려주시겠어요? 🌷'
    }
  }

  const handleModeChange = (newMode: typeof mode) => {
    setMode(newMode)
    setMessages([{ sender: 'harin', text: `현재 모드는 ${newMode}입니다. 이 모드에 대해 이야기해볼까요?` }])
  }

  return (
    <>
      <Head>
        <title>문학 소녀 하린과의 대화</title>
      </Head>
      <div className="iphone-frame">
        <div className="app-header">
          <img src="https://img.icons8.com/ios-filled/50/menu--v1.png" alt="메뉴" className="icon-left" />
          <span className="app-title">하린</span>
          <div className="icon-right">
            <img src="https://img.icons8.com/ios-glyphs/30/appointment-reminders.png" alt="알림" className="icon" />
            <img src="https://randomuser.me/api/portraits/women/44.jpg" alt="프로필" className="profile" />
          </div>
        </div>

        <div className="chat-container">
          <div className="chat-header-harin">
            <img src="/harin chat.jpg" alt="하린 프로필" className="harin-circle-profile" />
            <span className="harin-label-name">하린</span>
          </div>

          <div className="chat-messages" ref={chatRef}>
            {messages.map((msg, idx) => (
              <div key={idx} className={`message ${msg.sender}`}>
                {msg.text.split('\n').map((line, i) => (
                  <span key={i}>
                    {line}
                    <br />
                  </span>
                ))}
              </div>
            ))}
          </div>

          <div className="function-buttons">
            <button className="function-btn" onClick={() => handleModeChange('novel-helper')}>📝 소설 작성 도우미</button>
            <button className="function-btn" onClick={() => handleModeChange('literary-analysis')}>📘 문학 분석</button>
            <button className="function-btn" onClick={() => handleModeChange('poetry-play')}>📄 시 쓰기 놀이</button>
            <button className="function-btn" onClick={() => handleModeChange('book-recommendation')}>📚 독서 추천 & 기록</button>
          </div>

          <div className="chat-input">
            <input
              type="text"
              value={input}
              placeholder="메시지를 입력하세요..."
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSend()}
            />
            <button onClick={handleSend}>전송</button>
          </div>
        </div>

        <div className="navbar">
          <div className="nav-item"><img src="https://img.icons8.com/ios/50/home.png" alt="홈" />홈</div>
          <div className="nav-item"><img src="https://img.icons8.com/ios/50/artificial-intelligence.png" alt="AI" />AI</div>
          <div className="nav-item"><img src="https://img.icons8.com/ios/50/search--v1.png" alt="탐색" />탐색</div>
          <div className="nav-item"><img src="https://img.icons8.com/ios/50/settings.png" alt="설정" />설정</div>
          <div className="nav-item"><img src="https://img.icons8.com/ios/50/user.png" alt="프로필" />나</div>
        </div>
      </div>
    </>
  )
}
