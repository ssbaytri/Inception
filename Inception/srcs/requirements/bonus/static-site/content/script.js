// Simple animations and interactivity

document.addEventListener('DOMContentLoaded', function() {
    // Animate cards on scroll
    const cards = document.querySelectorAll('.card');
    
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };
    
    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.opacity = '1';
                entry.target.style.transform = 'translateY(0)';
            }
        });
    }, observerOptions);
    
    cards.forEach(card => {
        card.style.opacity = '0';
        card.style.transform = 'translateY(20px)';
        card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        observer.observe(card);
    });
    
    // Add click counter to services (just for fun)
    const services = document.querySelectorAll('.service');
    services.forEach(service => {
        let clicks = 0;
        service.addEventListener('click', function() {
            clicks++;
            if (clicks === 5) {
                alert('🎉 You found the easter egg! You clicked this service 5 times!');
                clicks = 0;
            }
        });
    });
    
    console.log('🐳 Inception Project - Static Site loaded successfully!');
    console.log('👋 Hello from the browser console!');
});