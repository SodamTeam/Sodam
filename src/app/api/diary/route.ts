// app/api/diary-service/diary/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

export async function GET(_req: NextRequest) {
  try {
    const [rows] = await db.query('SELECT * FROM diary_entries ORDER BY date DESC');
    return NextResponse.json(rows);
  } catch (error) {
    console.error('[GET error]', error);
    return NextResponse.json({ message: '조회 실패' }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const { date, mood, category, content } = await req.json();

    if (!date || !content) {
      return NextResponse.json({ message: '날짜와 내용은 필수입니다.' }, { status: 400 });
    }

    const [result] = await db.query(
      'INSERT INTO diary_entries (date, mood, category, content) VALUES (?, ?, ?, ?)',
      [date, mood, category, content]
    );

    return NextResponse.json({
      id: (result as any).insertId,
      date,
      mood,
      category,
      content,
    });
  } catch (error) {
    console.error('[POST error]', error);
    return NextResponse.json({ message: '저장 실패' }, { status: 500 });
  }
}
