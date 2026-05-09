// ──────────────────────────────
// Interest badges toggle
// ──────────────────────────────
document.querySelectorAll('.interest-badge').forEach(btn => {
    btn.addEventListener('click', () => {
        btn.classList.toggle('selected');
    });
});

// ──────────────────────────────
// City → Unsplash image mapping (needs internet for images only)
// ──────────────────────────────
const cityImages = {
    "Jeddah": "https://images.unsplash.com/photo-1597045566677-8cf032ed6634?w=900&auto=format&fit=crop",
    "Makkah": "https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?w=900&auto=format&fit=crop",
    "Madinah": "https://images.unsplash.com/photo-1584551246679-0daf3d275d0f?w=900&auto=format&fit=crop",
    "Riyadh": "https://images.unsplash.com/photo-1586724237569-f3d0c1dee8c6?w=900&auto=format&fit=crop",
    "Cairo": "https://images.unsplash.com/photo-1572252009286-268acec5ca0a?w=900&auto=format&fit=crop",
    "Alexandria": "https://images.unsplash.com/photo-1523544933-a2edc04d9656?w=900&auto=format&fit=crop",
    "Sharm El Sheikh": "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=900&auto=format&fit=crop",
    "Hurghada": "https://images.unsplash.com/photo-1600493572822-d58c5a3aa5ef?w=900&auto=format&fit=crop",
    "Aswan": "https://images.unsplash.com/photo-1566935118971-2b45e26efcd2?w=900&auto=format&fit=crop",
    "Paris": "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=900&auto=format&fit=crop",
    "Istanbul": "https://images.unsplash.com/photo-1534430480872-3498386e7856?w=900&auto=format&fit=crop",
    "Maldives": "https://images.unsplash.com/photo-1602002418082-a4443e081dd1?w=900&auto=format&fit=crop",
    "London": "https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=900&auto=format&fit=crop",
    "Dubai": "https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=900&auto=format&fit=crop",
    "Bali": "https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=900&auto=format&fit=crop",
    "Marrakech": "https://images.unsplash.com/photo-1597212618440-806262de4f6b?w=900&auto=format&fit=crop",
    "Santorini": "https://images.unsplash.com/photo-1570077188670-e3a8d69ac5ff?w=900&auto=format&fit=crop",
};

// Offline fallback: gradient colors per city
const cityColors = {
    "Jeddah": "#1a5276", "Makkah": "#6e2f1a", "Madinah": "#1a3c5e",
    "Riyadh": "#784212", "Cairo": "#7d6608", "Alexandria": "#1a5276",
    "Sharm El Sheikh": "#117a65", "Hurghada": "#1a5276", "Aswan": "#6e2f1a",
    "Paris": "#4a235a", "Istanbul": "#1a5276", "Maldives": "#0e6655",
    "London": "#2e4057", "Dubai": "#784212", "Bali": "#1e8449",
    "Marrakech": "#784212", "Santorini": "#1a5276",
};

function getCityImage(cityEn) {
    return cityImages[cityEn] || "https://images.unsplash.com/photo-1507608616759-54f48f0af0ee?w=900&auto=format&fit=crop";
}

function getCityColor(cityEn) {
    return cityColors[cityEn] || "#1a6bff";
}

// ──────────────────────────────
// Activity → Emoji mapping (no internet needed)
// ──────────────────────────────
function getActivityEmoji(activityText) {
    const t = activityText.toLowerCase();
    if (t.includes('check-in') || t.includes('تسجيل الدخول')) return '🏨';
    if (t.includes('check-out') || t.includes('تسجيل الخروج') || t.includes('مغادرة')) return '✈️';
    if (t.includes('beach') || t.includes('شاطئ')) return '🏖️';
    if (t.includes('spa') || t.includes('سبا')) return '💆';
    if (t.includes('wellness')) return '🧘';
    if (t.includes('food') || t.includes('dinner') || t.includes('dining') ||
        t.includes('طعام') || t.includes('عشاء') || t.includes('مطعم')) return '🍽️';
    if (t.includes('museum') || t.includes('متحف')) return '🏛️';
    if (t.includes('pyramid') || t.includes('أهرام')) return '🔺';
    if (t.includes('temple') || t.includes('معبد')) return '🏺';
    if (t.includes('walk') || t.includes('نزهة') || t.includes('جولة') || t.includes('tour')) return '🚶';
    if (t.includes('pool') || t.includes('مسبح')) return '🏊';
    if (t.includes('mosque') || t.includes('مسجد') || t.includes('haram') || t.includes('حرم')) return '🕌';
    if (t.includes('market') || t.includes('سوق') || t.includes('shopping') ||
        t.includes('mall') || t.includes('بازار') || t.includes('تسوق')) return '🛍️';
    if (t.includes('relax') || t.includes('راحة')) return '😌';
    if (t.includes('استرخاء')) return '😌';
    if (t.includes('boat') || t.includes('felucca') ||
        t.includes('نيلية') || t.includes('فلوكة') || t.includes('cruise')) return '⛵';
    if (t.includes('garden') || t.includes('حديقة')) return '🌿';
    if (t.includes('nubian') || t.includes('نوبية')) return '🌍';
    if (t.includes('nature')) return '🌿';
    if (t.includes('sunset') || t.includes('غروب')) return '🌅';
    if (t.includes('photo') || t.includes('تصوير')) return '📷';
    if (t.includes('historical') || t.includes('تاريخ')) return '🏺';
    if (t.includes('culture') || t.includes('ثقافة')) return '🎭';
    if (t.includes('city') || t.includes('مدينة')) return '🏙️';
    if (t.includes('romantic') || t.includes('رومانسي')) return '❤️';
    return '📍';
}

// ──────────────────────────────
// Render stars
// ──────────────────────────────
function renderStars(rating) {
    const full = Math.floor(rating);
    const half = rating - full >= 0.5;
    let s = '';
    for (let i = 0; i < full; i++) s += '★';
    if (half) s += '½';
    return s;
}

// ──────────────────────────────
// Budget level → label (bilingual)
// ──────────────────────────────
const budgetLabels = {
    en: { low: 'Economy', medium: 'Mid-Range', high: 'Luxury' },
    ar: { low: 'اقتصادي', medium: 'متوسط', high: 'فاخر' }
};

// ──────────────────────────────
// Render Featured Stay
// ──────────────────────────────
function renderFeaturedStay(result, lang) {
    const city = result.ai_selected_city_en || result.destination_entered || 'Travel';
    const cityAr = result.ai_selected_city_ar || '';
    const hotels = result.recommended_hotels || [];
    const hotel = hotels[0];
    const img = getCityImage(city);
    const color = getCityColor(city);

    const matchScore = result.final_text && result.final_text.match(/(\d+\.\d+)%/);
    const matchLabel = lang === 'ar' ? 'تطابق الذكاء الاصطناعي' : 'AI Match';
    const matchHtml = matchScore && !result.destination_entered
        ? `<span class="match-score">✦ ${matchLabel}: ${matchScore[1]}%</span>` : '';

    const startsFrom = lang === 'ar' ? 'يبدأ من' : 'Starts From';
    const perNight = lang === 'ar' ? 'في الليلة' : 'per night';
    const featuredPick = lang === 'ar' ? 'الاختيار المميز' : 'Featured Pick';

    let hotelHtml = '';
    if (hotel) {
        const hotelName = lang === 'ar' ? hotel.name_ar : hotel.name_en;
        const budgetLabel = (budgetLabels[lang] || budgetLabels.en)[hotel.budget_level] || hotel.budget_level;
        const priceEst = hotel.budget_level === 'high' ? '350+' : hotel.budget_level === 'medium' ? '150–350' : '50–150';
        const displayCity = lang === 'ar' ? (cityAr || city) : city;
        const secondCity = lang === 'ar' ? city : (cityAr || '');

        hotelHtml = `
            <div class="stay-top">
                <div>
                    <div class="stay-name">${hotelName}</div>
                    <div class="stay-rating">
                        <span class="stars">${renderStars(hotel.rating)}</span>
                        <span>${hotel.rating} (${featuredPick})</span>
                    </div>
                    <span class="city-tag">📍 ${displayCity}${secondCity ? ' · ' + secondCity : ''}</span>
                    ${matchHtml}
                </div>
                <div class="stay-price">
                    <div class="price-label">${startsFrom}</div>
                    <div class="price-value">$${priceEst}</div>
                    <div style="font-size:12px;color:#6b7a99;">${perNight} · ${budgetLabel}</div>
                </div>
            </div>`;
    } else {
        const displayCity = lang === 'ar' ? (cityAr || city) : city;
        hotelHtml = `
            <div class="stay-top">
                <div>
                    <div class="stay-name">${displayCity}</div>
                    ${matchHtml}
                </div>
            </div>`;
    }

    const badgeLabel = lang === 'ar' ? '✦ الإقامة المميزة' : '✦ Featured Stay';

    // Offline fallback: if image fails show colored gradient
    return `
        <div class="featured-stay-card">
            <div class="stay-image" style="background: linear-gradient(135deg, ${color}, #1a2234);">
                <img src="${img}" alt="${city}"
                     onerror="this.style.display='none'; this.onerror=null;">
                <span class="stay-badge">${badgeLabel}</span>
            </div>
            <div class="stay-info" ${lang === 'ar' ? 'dir="rtl" style="text-align:right"' : ''}>
                ${hotelHtml}
            </div>
        </div>`;
}

// ──────────────────────────────
// Render Itinerary
// ──────────────────────────────
const DAY_THEMES = {
    en: ["Arrival & First Impressions", "Culture & Heritage", "Exploration Day",
        "Leisure & Relaxation", "Local Life", "Adventure Day", "Farewell Day"],
    ar: ["الوصول والانطباعات الأولى", "الثقافة والتراث", "يوم الاستكشاف",
        "الترفيه والراحة", "الحياة المحلية", "يوم المغامرة", "يوم الوداع"]
};

function renderItinerary(itinerary, lang) {
    if (!itinerary || itinerary.length === 0) return '';

    const themes = DAY_THEMES[lang] || DAY_THEMES.en;
    const titleLabel = lang === 'ar' ? 'خطة الرحلة يوماً بيوم' : 'Day-by-Day Itinerary';
    const dayWord = lang === 'ar' ? 'اليوم' : 'Day';
    const isRtl = lang === 'ar';

    let html = `<div class="itinerary-title">🗺️ ${titleLabel}</div>`;

    itinerary.forEach((day, idx) => {
        const dayNum = day.day;
        const items = (lang === 'ar' ? day.ar : day.en) || [];
        const theme = themes[Math.min(idx, themes.length - 1)];

        let activitiesHtml = items.map((item, i) => {
            const isFirst = i === 0;
            const isLast = i === items.length - 1;
            const isSpecial = (isFirst && (item.includes('تسجيل الدخول') || item.toLowerCase().includes('check-in')))
                || (isLast && (item.includes('تسجيل الخروج') || item.toLowerCase().includes('check-out')));
            const cls = isSpecial ? 'activity-item special' : 'activity-item';
            const emoji = getActivityEmoji(item);
            return `<div class="${cls}">${emoji} ${item}</div>`;
        }).join('');

        html += `
            <div class="day-card" ${isRtl ? 'dir="rtl"' : ''}>
                <div class="day-header">
                    <div class="day-number">${dayNum}</div>
                    <div class="day-label">${dayWord} ${dayNum}: ${theme}</div>
                </div>
                <div class="activities-grid">
                    ${activitiesHtml}
                </div>
            </div>`;
    });

    return html;
}

// ──────────────────────────────
// Generate Button Handler
// ──────────────────────────────
document.getElementById('generate-btn').addEventListener('click', async () => {
    const destination = document.getElementById('destination').value.trim();
    const budget = document.getElementById('budget').value.trim();
    const duration = document.getElementById('duration').value.trim();
    const selectedBadges = [...document.querySelectorAll('.interest-badge.selected')].map(b => b.dataset.value);

    if (!budget || !duration) {
        alert('Please fill in at least Budget and Duration.');
        return;
    }

    const overlay = document.getElementById('loading-overlay');
    overlay.classList.add('visible');

    try {
        const response = await fetch('/api/recommend', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ destination, budget, duration, interests: selectedBadges })
        });

        const result = await response.json();

        // Language decided entirely by Python backend
        const lang = result.language_mode || 'en';

        const previewSection = document.getElementById('preview-section');
        const featuredContainer = document.getElementById('featured-stay-container');
        const itineraryContainer = document.getElementById('itinerary-container');

        const isError = result.final_text && (
            result.final_text.toLowerCase().includes("sorry") ||
            result.final_text.includes("عذراً") ||
            result.final_text.includes("غير متوفرة")
        );

        if (isError) {
            featuredContainer.innerHTML = `
                <div class="error-card" ${lang === 'ar' ? 'dir="rtl"' : ''}>
                    ⚠️ <span>${result.final_text}</span>
                </div>`;
            itineraryContainer.innerHTML = '';
        } else {
            featuredContainer.innerHTML = renderFeaturedStay(result, lang);
            itineraryContainer.innerHTML = renderItinerary(result.itinerary, lang);
        }

        previewSection.style.display = 'block';
        previewSection.scrollIntoView({ behavior: 'smooth', block: 'start' });

    } catch (err) {
        console.error(err);
        alert('Something went wrong. Make sure the server is running (start_server.bat).');
    } finally {
        overlay.classList.remove('visible');
    }
});
