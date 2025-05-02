// script.js

const slides = document.querySelectorAll('.slide');
const prevBtn = document.querySelector('.prev');
const nextBtn = document.querySelector('.next');
let currentIndex = 0;




window.onload = () => {
    typeGreeting();
};




window.onload = () => {
    typeGreeting();
};

function showSlide(index) {
    slides.forEach((slide, i) => {
        slide.classList.toggle('active', i === index);
    });
}

prevBtn.addEventListener('click', () => {
    currentIndex = (currentIndex - 1 + slides.length) % slides.length;
    showSlide(currentIndex);
});

nextBtn.addEventListener('click', () => {
    currentIndex = (currentIndex + 1) % slides.length;
    showSlide(currentIndex);
});


slides.forEach(slide => {
    slide.addEventListener('click', () => {
        const link = slide.getAttribute('data-link');
        if (link) {
            window.location.href = link;
        }
    });
});


document.querySelectorAll('.slide').forEach(slide => {
    slide.addEventListener('click', () => {
        const mode = slide.dataset.mode;
        if (mode === 'harin') {
            window.location.href = 'harin.html';
        }
    });
});


document.querySelectorAll('.slide').forEach(slide => {
    slide.addEventListener('click', () => {
        const mode = slide.dataset.mode;
        if (mode === 'harin') {
            window.location.href = 'harin.html';
        }
    });
});
