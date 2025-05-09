import { NextRequest, NextResponse } from 'next/server';
import { callOllama } from '@/lib/ollama';

export async function POST(req: NextRequest) {
  const { prompt } = await req.json();
  const response = await callOllama(`책 추천: ${prompt}`, "llama3");
  return NextResponse.json({ result: response });
}
