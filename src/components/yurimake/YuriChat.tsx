// YuriChat.tsx
import React, {
  useState,
  useRef,
  useEffect,
  KeyboardEvent,
  ChangeEvent,
} from 'react'
import Image from 'next/image'

interface YuriChatProps {
  goBack: () => void
}


type Message = {
  text: string
  sender: 'user' | 'bot'
}

const YuriChat: React.FC<YuriChatProps> = ({ goBack }) => {
  const [messages, setMessages] = useState<Message[]>([])
  const [input, setInput] = useState('')
  const textareaRef = useRef<HTMLTextAreaElement>(null)
  const messagesEndRef = useRef<HTMLDivElement>(null)

  const sendMessage = () => {
    const text = input.trim()
    if (!text) return
    setMessages(prev => [...prev, { text, sender: 'user' }])
    setInput('')
  }

  const handleKeyDown = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault()
      sendMessage()
    }
  }

  const handleChange = (e: ChangeEvent<HTMLTextAreaElement>) => {
    setInput(e.target.value)
  }

  // 자동 높이 조절
  useEffect(() => {
    const ta = textareaRef.current
    if (ta) {
      ta.style.height = 'auto'
      ta.style.height = `${ta.scrollHeight}px`
    }
  }, [input])

  // 첫 진입 시 봇 인사
  useEffect(() => {
    const timer = setTimeout(() => {
      setMessages([{ text: '안녕하세요', sender: 'bot' }])
    }, 1000)
    return () => clearTimeout(timer)
  }, [])

  // 자동 스크롤
  useEffect(() => {
    if (messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: 'smooth' })
    }
  }, [messages])

  return (
    <div className="flex justify-center items-center w-screen h-screen bg-gray-100">
      {/* 9:16 컨테이너 */}
      <div className="relative bg-white aspect-[9/16] h-[90vh] max-h-[90vh] w-auto">
        <div className="absolute inset-0 flex flex-col">

          {/* Header */}
          <header className="relative flex items-center h-16 px-4">
            <button
              onClick={goBack}
              className="z-10 cursor-pointer p-1 hover:opacity-90 active:brightness-75 transition"
            >
              <Image
                src="/Yuri_images/Back.png"
                alt="뒤로가기"
                width={32}
                height={32}
              />
            </button>
            <h1 className="absolute left-1/2 top-1/2 transform -translate-x-1/2 -translate-y-1/2 text-xl text-gray-600 pointer-events-none">
              유리
            </h1>
          </header>

          {/* Messages */}
          <main className="flex-1 overflow-auto p-4 relative space-y-4">
            {messages.map((msg, idx) => {
              if (msg.sender === 'bot') {
                return (
                  <div key={idx} className="mb-4">
                    {/* 이름 및 프로필 */}
                    <div className="flex items-center ml-8 space-x-2">
                      <Image
                        src="/Yuri_images/chat_small.png"
                        alt="유리 프로필"
                        width={24}
                        height={24}
                        className="rounded-full"
                      />
                      <span className="text-sm text-gray-500">유리</span>
                    </div>
                    {/* 말풍선: 텍스트 길이에 따라 폭 조정 */}
                    <div className="ml-8 mt-1">
                      <div className="inline-block bg-gray-200 text-black px-4 py-2 rounded-lg max-w-[90%] break-words">
                        {msg.text}
                      </div>
                    </div>
                  </div>
                )
              }
              return (
                <div key={idx} className="flex justify-end mb-4">
                  <div className="inline-block bg-blue-500 text-white px-4 py-2 rounded-lg max-w-[80%] break-words">
                    {msg.text}
                  </div>
                </div>
              )
            })}
            <div ref={messagesEndRef} />
          </main>

          {/* Input Area */}
          <footer className="flex-none px-4 py-2">
            <div className="border border-gray-300 rounded-3xl p-2">
              <textarea
                ref={textareaRef}
                rows={1}
                value={input}
                onChange={handleChange}
                onKeyDown={handleKeyDown}
                placeholder="무엇이든 물어보세요"
                className="w-full resize-none overflow-y-auto max-h-[4.5rem] border-none outline-none placeholder-gray-400 pl-2"
              />
              <div className="flex justify-between mt-1">
                <button className="cursor-pointer p-1 hover:opacity-90 active:brightness-75 transition">
                  <Image
                    src="/Yuri_images/plus.png"
                    alt="첨부"
                    width={30}
                    height={30}
                  />
                </button>
                <button
                  onClick={sendMessage}
                  className="cursor-pointer p-1 hover:opacity-90 active:brightness-75 transition"
                >
                  <Image
                    src="/Yuri_images/Enter.png"
                    alt="전송"
                    width={30}
                    height={30}
                  />
                </button>
              </div>
            </div>
          </footer>
        </div>
      </div>
    </div>
  )
}

export default YuriChat