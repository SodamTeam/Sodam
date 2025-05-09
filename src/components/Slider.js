import React, { useState } from 'react';

export default function Slider({ characters }) {
  const [currentSlide, setCurrentSlide] = useState(0);

  const nextSlide = () => {
    setCurrentSlide((prev) => (prev === characters.length - 1 ? 0 : prev + 1));
  };

  const prevSlide = () => {
    setCurrentSlide((prev) => (prev === 0 ? characters.length - 1 : prev - 1));
  };

  return (
    <div className="slider-container">
      <button onClick={prevSlide}>◀</button>
      <div className="slider">
        {characters.map((character, index) => (
          <div
            key={character.id}
            style={{
              display: index === currentSlide ? 'block' : 'none',
            }}
          >
            <img src={character.image} alt={character.name} />
            <p>{character.name}</p>
          </div>
        ))}
      </div>
      <button onClick={nextSlide}>▶</button>
    </div>
  );
}
