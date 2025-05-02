    const chat = document.getElementById('chat');
    const input = document.getElementById('userInput');
    const sendBtn = document.getElementById('sendBtn');

    async function fetchGPTReply(userMessage) {
        const response = await fetch("https://api.openai.com/v1/chat/completions", {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
                "Authorization": "Bearer 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"
            },
            body: JSON.stringify({
                model: "gpt-3.5-turbo", // 또는 "gpt-4"
                messages: [
                    { role: "system", content: "당신은 친절한 문학 도우미 하린입니다." },
                    { role: "user", content: userMessage }
                ]
            })
        });

        const data = await response.json();
        return data.choices[0].message.content;
    }

    // 버튼들
    const novelHelperBtn = document.getElementById('novel-helper');
    const literaryAnalysisBtn = document.getElementById('literary-analysis');
    const poetryPlayBtn = document.getElementById('poetry-play');
    const bookRecommendationBtn = document.getElementById('book-recommendation');

    // 기능에 맞는 응답을 위한 변수
    let currentMode = 'default';

    sendBtn.addEventListener('click', sendMessage);
    input.addEventListener('keypress', function (e) {
        if (e.key === 'Enter') sendMessage();
    });

    novelHelperBtn.addEventListener('click', () => changeMode('novel-helper'));
    literaryAnalysisBtn.addEventListener('click', () => changeMode('literary-analysis'));
    poetryPlayBtn.addEventListener('click', () => changeMode('poetry-play'));
    bookRecommendationBtn.addEventListener('click', () => changeMode('book-recommendation'));

    function sendMessage() {
        const message = input.value.trim();
        if (message === "") return;

        addMessage('user', message);
        input.value = '';

        setTimeout(() => {
            const reply = generateHarinReply(message);
            addMessage('harin', reply);
        }, 600);
    }

    function addMessage(sender, text) {
        const msg = document.createElement('div');
        msg.classList.add('message', sender);
        msg.textContent = text;
        chat.appendChild(msg);
        chat.scrollTop = chat.scrollHeight;
    }

    function generateHarinReply(userText) {
        if (currentMode === 'novel-helper') {
            return '소설을 작성하는 데 도움이 필요하군요! 어떤 아이디어를 생각하고 계신가요?';
        }
        if (currentMode === 'literary-analysis') {
            return '문학 분석을 시작해볼까요? 어떤 작품을 분석할까요?';
        }
        if (currentMode === 'poetry-play') {
            return '시를 쓰는 놀이가 시작되었습니다! 어떤 주제로 시를 써볼까요?';
        }
        if (currentMode === 'book-recommendation') {
            return '책을 추천해드릴게요! 어떤 장르의 책을 원하시나요?';
        }
        return '그 이야기도 참 멋지네요. 조금 더 들려주시겠어요? 🌷';
    }

    function changeMode(mode) {
        currentMode = mode;
        chat.innerHTML = ''; // 기존 대화 내용 비우기
        addMessage('harin', `현재 모드는 ${mode}입니다. 이 모드에 대해 이야기해볼까요?`);
    }
