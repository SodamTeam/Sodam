const express = require('express');
const mysql   = require('mysql2/promise');
const cors    = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// 포트 설정 (기본값: 8001)
const PORT = process.env.PORT || 8001;

// MySQL 연결 설정
const dbConfig = {
  host: 'localhost',
  user: 'root',
  password: 'MySecret123!',
  database: 'chatdb'
};

// 세션 생성
app.post('/api/chat/start', async (req, res) => {
  const { userId } = req.body;
  const sessionId = require('crypto').randomUUID();
  const conn = await mysql.createConnection(dbConfig);
  await conn.execute(
    'INSERT INTO chat_sessions(session_id,user_id) VALUES(?,?)',
    [sessionId, userId]
  );
  await conn.end();
  res.json({ sessionId });
});

// 메시지 저장
app.post('/api/chat/message', async (req, res) => {
  const { sessionId, sender, content } = req.body;
  const conn = await mysql.createConnection(dbConfig);
  await conn.execute(
    'INSERT INTO chat_messages(session_id,sender,content) VALUES(?,?,?)',
    [sessionId, sender, content]
  );
  await conn.end();
  res.sendStatus(201);
});

// 히스토리 조회
app.get('/api/chat/history/:sessionId', async (req, res) => {
  const { sessionId } = req.params;
  const conn = await mysql.createConnection(dbConfig);
  const [rows] = await conn.execute(
    'SELECT sender, content, sent_at FROM chat_messages WHERE session_id=? ORDER BY sent_at',
    [sessionId]
  );
  await conn.end();
  res.json(rows);
});

app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
