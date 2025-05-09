'use client';
import Slider from './Slider';

  const characters = [
    { id: 1, name: "문학소녀 하린", image: "https://placehold.co/120x140" },
    { id: 2, name: "과학소녀 유리", image: "https://placehold.co/120x140" },
    { id: 3, name: "힐링소녀 미나", image: "https://placehold.co/120x140" },
    { id: 4, name: "테크소녀 세라", image: "https://placehold.co/120x140" },
  ];

  return (
    <div>
      <h1>캐릭터 선택</h1>
      <Slider characters={characters} />
    </div>
  );
