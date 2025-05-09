// src/lib/ollama.ts
export async function callOllama(prompt: string, model = "llama3") {
    const res = await fetch("http://localhost:11434/api/generate", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model,
        prompt,
        stream: false
      }),
    });
  
    if (!res.ok) {
      throw new Error("Ollama 응답 실패");
    }
  
    const data = await res.json();
    return data.response;
  }
  