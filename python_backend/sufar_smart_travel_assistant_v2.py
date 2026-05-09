
"""
Sufar Smart Travel Assistant - Improved Version
Features:
- Loads intents from intents (2).json
- Loads rich data from citiesDataset.json & destination.json
- Intent matching using TF-IDF + cosine similarity
- City recommendation using cosine similarity
- Hotel recommendation using KNN
- Full itinerary with NO empty days
- Arabic / English / both output
- Better Windows Arabic terminal support

Run:
    pip install numpy scikit-learn arabic-reshaper python-bidi
    python sufar_smart_travel_assistant_v2.py

Keep this file in the same folder as:
    intents (2).json
    citiesDataset.json
    destination.json
"""

from __future__ import annotations
import json
import random
import os
import sys
import re
from pathlib import Path

import numpy as np
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.neighbors import NearestNeighbors

try:
    import arabic_reshaper
    from bidi.algorithm import get_display
    HAS_ARABIC_SUPPORT = True
except ImportError:
    HAS_ARABIC_SUPPORT = False


# ============================================================
# WINDOWS TERMINAL UTF-8 FIX & ARABIC TEXT SHAPING
# ============================================================

def fix_arabic_text(text):
    """Reshape Arabic text and fix right-to-left display for terminal while preserving English formatting."""
    if not HAS_ARABIC_SUPPORT:
        return text
    
    # Regex to find Arabic words and phrases
    arabic_pattern = re.compile(r'[\u0600-\u06FF]+(?:[\s]+[\u0600-\u06FF]+)*')
    
    fixed_lines = []
    for line in text.split('\n'):
        if any('\u0600' <= ch <= '\u06FF' for ch in line):
            def replace_arabic(match):
                arabic_part = match.group(0)
                reshaped = arabic_reshaper.reshape(arabic_part)
                return get_display(reshaped)
                
            fixed_line = arabic_pattern.sub(replace_arabic, line)
            fixed_lines.append(fixed_line)
        else:
            fixed_lines.append(line)
    return '\n'.join(fixed_lines)


def setup_console():
    try:
        os.system("chcp 65001 > nul")
    except Exception:
        pass

    try:
        sys.stdout.reconfigure(encoding="utf-8")
        sys.stdin.reconfigure(encoding="utf-8")
    except Exception:
        pass


# ============================================================
# FILE LOADING
# ============================================================

def load_intents(file_name="intents (2).json"):
    file_path = Path(__file__).with_name(file_name)
    if not file_path.exists():
        raise FileNotFoundError(f"Missing file: {file_path}")
    with open(file_path, "r", encoding="utf-8") as f:
        return json.load(f)


def load_json_file(file_name):
    """Load a JSON file from the same directory as this script. Returns [] on failure."""
    file_path = Path(__file__).with_name(file_name)
    if not file_path.exists():
        return []
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            return json.load(f)
    except Exception:
        return []


# Loaded once at module level for reuse
_cities_dataset = load_json_file("citiesDataset.json")   # list of city objects with hotels
_destination_data = load_json_file("destination.json")    # list of city objects with activities


# ============================================================
# DATA
# ============================================================

budget_map = {"low": 1, "medium": 2, "high": 3}

all_activities = [
    "religious", "shopping", "luxury", "family", "business",
    "beach", "sea_view", "relaxation", "honeymoon", "pool",
    "spa", "historical", "culture", "city_walks", "nightlife",
    "food", "romantic", "water_villa", "nature", "wellness"
]

cities = [
    {"name_en": "Jeddah", "name_ar": "جدة", "activities": ["sea_view", "shopping", "luxury", "city_walks", "food", "honeymoon"], "budget_level": "medium", "best_duration": [2, 3, 4, 5]},
    {"name_en": "Makkah", "name_ar": "مكة", "activities": ["religious", "family", "city_walks"], "budget_level": "high", "best_duration": [2, 3, 4, 5, 6]},
    {"name_en": "Madinah", "name_ar": "المدينة المنورة", "activities": ["religious", "family", "relaxation", "city_walks"], "budget_level": "medium", "best_duration": [2, 3, 4, 5]},
    {"name_en": "Riyadh", "name_ar": "الرياض", "activities": ["business", "luxury", "shopping", "city_walks", "food"], "budget_level": "high", "best_duration": [2, 3, 4]},
    {"name_en": "Cairo", "name_ar": "القاهرة", "activities": ["historical", "culture", "shopping", "city_walks", "nightlife", "food"], "budget_level": "medium", "best_duration": [2, 3, 4, 5]},
    {"name_en": "Alexandria", "name_ar": "الإسكندرية", "activities": ["sea_view", "historical", "culture", "city_walks", "food", "romantic"], "budget_level": "medium", "best_duration": [2, 3, 4]},
    {"name_en": "Sharm El Sheikh", "name_ar": "شرم الشيخ", "activities": ["beach", "sea_view", "relaxation", "honeymoon", "pool", "spa", "family"], "budget_level": "high", "best_duration": [3, 4, 5, 6]},
    {"name_en": "Hurghada", "name_ar": "الغردقة", "activities": ["beach", "sea_view", "family", "pool", "spa", "relaxation"], "budget_level": "medium", "best_duration": [3, 4, 5]},
    {"name_en": "Aswan", "name_ar": "أسوان", "activities": ["historical", "culture", "relaxation", "romantic", "city_walks", "nature"], "budget_level": "high", "best_duration": [2, 3, 4, 5, 6, 7]},
    {"name_en": "Paris", "name_ar": "باريس", "activities": ["romantic", "luxury", "shopping", "culture", "historical", "honeymoon"], "budget_level": "high", "best_duration": [3, 4, 5, 6]},
    {"name_en": "Istanbul", "name_ar": "إسطنبول", "activities": ["historical", "culture", "shopping", "food", "city_walks", "romantic"], "budget_level": "medium", "best_duration": [3, 4, 5]},
    {"name_en": "Maldives", "name_ar": "المالديف", "activities": ["water_villa", "beach", "sea_view", "honeymoon", "luxury", "relaxation", "spa", "wellness"], "budget_level": "high", "best_duration": [4, 5, 6, 7]},
    {"name_en": "London", "name_ar": "لندن", "activities": ["business", "shopping", "city_walks", "historical", "culture", "food"], "budget_level": "high", "best_duration": [3, 4, 5]},
    {"name_en": "Dubai", "name_ar": "دبي", "activities": ["luxury", "shopping", "city_walks", "business", "family", "romantic"], "budget_level": "high", "best_duration": [3, 4, 5]},
    {"name_en": "Bali", "name_ar": "بالي", "activities": ["nature", "wellness", "beach", "relaxation", "honeymoon", "spa"], "budget_level": "medium", "best_duration": [4, 5, 6]},
    {"name_en": "Marrakech", "name_ar": "مراكش", "activities": ["culture", "historical", "shopping", "food", "city_walks"], "budget_level": "medium", "best_duration": [3, 4]},
    {"name_en": "Santorini", "name_ar": "سانتوريني", "activities": ["romantic", "sea_view", "honeymoon", "relaxation", "luxury"], "budget_level": "high", "best_duration": [3, 4, 5]}
]

# ============================================================
# DYNAMIC CITY INJECTION FROM ALL JSON SOURCES
# ============================================================

INTENT_CITIES_MAP = {
    'jeddah': ('Jeddah', 'جدة'),
    'makkah': ('Makkah', 'مكة'),
    'luxor': ('Luxor', 'الأقصر'),
    'abudhabi': ('Abu Dhabi', 'أبو ظبي'),
    'doha': ('Doha', 'الدوحة'),
    'amman': ('Amman', 'عمان'),
    'beirut': ('Beirut', 'بيروت'),
    'rome': ('Rome', 'روما'),
    'barcelona': ('Barcelona', 'برشلونة'),
    'newyork': ('New York', 'نيويورك'),
    'losangeles': ('Los Angeles', 'لوس أنجلوس'),
    'tokyo': ('Tokyo', 'طوكيو'),
}

# Name aliases so find_city_by_destination can match JSON spelling variants
_CITY_NAME_ALIASES = {
    "al madinah": "madinah",
    "المدينة": "المدينة المنورة",
    "roma": "rome",
    "mecca": "makkah",
    "مكه": "مكة",
    "جده": "جدة",
    "sharm": "sharm el sheikh",
    "alex": "alexandria",
    "الاقصر": "الأقصر",
    "أبوظبي": "أبو ظبي",
}


def _price_to_budget(price):
    """Convert a per-night price (USD) to a budget level."""
    try:
        price = float(price)
    except (TypeError, ValueError):
        return "medium"
    if price <= 120:
        return "low"
    elif price <= 300:
        return "medium"
    else:
        return "high"


def _stars_to_budget(stars):
    """Convert hotel stars to a budget level."""
    try:
        stars = int(stars)
    except (TypeError, ValueError):
        return "medium"
    if stars <= 3:
        return "low"
    elif stars == 4:
        return "medium"
    else:
        return "high"


def _infer_activities_from_facilities(facilities, location_type=""):
    """Guess activity tags from hotel facilities/location."""
    acts = []
    fac_lower = [f.lower() for f in (facilities or [])]
    loc = (location_type or "").lower()

    mapping = {
        "pool": "pool", "swimming": "pool",
        "spa": "spa", "wellness": "wellness", "sauna": "spa",
        "gym": "city_walks", "fitness": "city_walks",
        "beach": "beach", "private beach": "beach",
        "restaurant": "food", "dining": "food",
        "sea view": "sea_view", "nile view": "sea_view",
        "garden": "nature", "panoramic": "sea_view",
        "historic": "historical", "palace": "luxury",
    }
    for fac in fac_lower:
        for key, act in mapping.items():
            if key in fac and act not in acts:
                acts.append(act)
    if loc == "beach" and "beach" not in acts:
        acts.append("beach")
    if not acts:
        acts = ["city_walks", "culture"]
    return acts


# ---- Arabic translation tables for JSON-sourced data ----

_ACTIVITY_AR = {
    # Cairo
    "pyramids of giza & sphinx": "أهرامات الجيزة وأبو الهول",
    "grand egyptian museum": "المتحف المصري الكبير",
    "khan el-khalili bazaar": "سوق خان الخليلي",
    "nile dinner cruise": "رحلة عشاء على النيل",
    # Alexandria
    "bibliotheca alexandrina": "مكتبة الإسكندرية",
    "qaitbay citadel": "قلعة قايتباي",
    "alexandria corniche": "كورنيش الإسكندرية",
    "roman amphitheatre": "المدرج الروماني",
    # Hurghada
    "diving & snorkeling": "الغوص والسنوركل",
    "yacht trips": "رحلات اليخوت",
    "red sea safari": "سفاري البحر الأحمر",
    "water sports": "الرياضات المائية",
    # Sharm
    "ras mohamed diving": "غوص رأس محمد",
    "coral reef garden": "حديقة الشعاب المرجانية",
    "mount sinai trek": "تسلق جبل سيناء",
    "dolphin trip": "رحلة الدلافين",
    # Luxor
    "karnak temple": "معبد الكرنك",
    "valley of the kings": "وادي الملوك",
    "hot air balloon ride": "رحلة بالون الهواء الساخن",
    "luxor temple by night": "معبد الأقصر ليلاً",
    # Aswan
    "abu simbel temple": "معبد أبو سمبل",
    "philae temple": "معبد فيلة",
    "felucca sailing": "الإبحار بالفلوكة",
    "nubian market": "السوق النوبية",
    # Riyadh
    "masmak fortress": "قصر المصمك",
    "kingdom tower": "برج المملكة",
    "diriyah heritage village": "الدرعية التراثية",
    "riyadh season": "موسم الرياض",
    # Jeddah
    "jeddah corniche": "كورنيش جدة",
    "al-balad historic district": "حي البلد التاريخي",
    "king fahd fountain": "نافورة الملك فهد",
    "red sea diving": "غوص البحر الأحمر",
    # Makkah
    "al-masjid al-haram": "المسجد الحرام",
    "kaaba": "الكعبة المشرفة",
    "jabal al-noor": "جبل النور",
    "jabal thawr": "جبل ثور",
    # Madinah
    "al-masjid an-nabawi": "المسجد النبوي",
    "mount uhud": "جبل أحد",
    "islamic museum": "المتحف الإسلامي",
    "green gardens": "الحدائق الخضراء",
    # Dubai
    "burj khalifa": "برج خليفة",
    "dubai mall": "دبي مول",
    "desert safari": "سفاري الصحراء",
    "jumeirah beach": "شاطئ جميرا",
    # Abu Dhabi
    "sheikh zayed mosque": "مسجد الشيخ زايد",
    "louvre abu dhabi": "متحف اللوفر أبوظبي",
    "yas island": "جزيرة ياس",
    "corniche walk": "نزهة الكورنيش",
    # Doha
    "museum of islamic art": "متحف الفن الإسلامي",
    "souq waqif": "سوق واقف",
    "lusail city": "مدينة لوسيل",
    "katara village": "القرية الثقافية كتارا",
    # Amman
    "citadel hill": "جبل القلعة",
    "jordan museum": "متحف الأردن",
    "downtown food tour": "جولة طعام وسط البلد",
    # Beirut
    "downtown beirut": "وسط بيروت",
    "gemmayzeh district": "حي الجميزة",
    "national museum": "المتحف الوطني",
    # Paris
    "eiffel tower": "برج إيفل",
    "louvre museum": "متحف اللوفر",
    "seine river cruise": "رحلة نهر السين",
    "montmartre": "مونمارتر",
    # Rome
    "colosseum": "الكولوسيوم",
    "vatican city": "مدينة الفاتيكان",
    "trevi fountain": "نافورة تريفي",
    "roman forum": "المنتدى الروماني",
    # Barcelona
    "sagrada familia": "كنيسة ساغرادا فاميليا",
    "park güell": "حديقة غويل",
    "las ramblas": "شارع لاس رامبلاس",
    "barcelona beach": "شاطئ برشلونة",
    # London
    "london eye": "عين لندن",
    "tower bridge": "جسر البرج",
    "british museum": "المتحف البريطاني",
    "hyde park": "حديقة هايد بارك",
    # New York
    "statue of liberty": "تمثال الحرية",
    "central park": "سنترال بارك",
    "times square": "تايمز سكوير",
    "brooklyn bridge": "جسر بروكلين",
    # Los Angeles
    "hollywood walk of fame": "ممشى المشاهير بهوليوود",
    "santa monica beach": "شاطئ سانتا مونيكا",
    "universal studios": "يونيفرسال ستوديوز",
    "beverly hills": "بيفرلي هيلز",
    # Istanbul
    "hagia sophia": "آيا صوفيا",
    "blue mosque": "المسجد الأزرق",
    "grand bazaar": "الجراند بازار",
    "bosphorus cruise": "رحلة البوسفور",
    # Tokyo
    "shibuya crossing": "تقاطع شيبويا",
    "tokyo tower": "برج طوكيو",
    "akihabara": "أكيهابارا",
    "senso-ji temple": "معبد سنسوجي",
    # Maldives
    "coral diving": "غوص الشعاب المرجانية",
    "overwater villas": "فيلات فوق الماء",
    "dolphin watching": "مشاهدة الدلافين",
    "sunset cruise": "رحلة الغروب",
}


_HOTEL_AR = {
    "hyatt regency cairo west": "حياة ريجنسي القاهرة غرب",
    "pyramisa suites hotel cairo": "بيراميزا سويتس القاهرة",
    "steigenberger hotel el tahrir cairo": "شتايجنبرجر التحرير القاهرة",
    "hilton cairo grand nile": "هيلتون القاهرة جراند نايل",
    "safir hotel cairo": "فندق سفير القاهرة",
    "le metropole luxury heritage hotel": "لو ميتروبول فندق تراثي فاخر",
    "steigenberger cecil hotel alexandria": "شتايجنبرجر سيسيل الإسكندرية",
    "nubian village by the sea": "القرية النوبية على البحر",
    "windsor palace hotel": "فندق قصر وندسور",
    "downtown sea view suites": "أجنحة داون تاون بإطلالة بحرية",
    "coral tower hotel": "فندق كورال تاور",
    "doubletree by hilton amman": "دبل تري باي هيلتون عمان",
    "boho boutique hotel amman": "بوهو بوتيك هوتيل عمان",
    "radisson blu hotel amman galleria mall": "راديسون بلو عمان جاليريا مول",
    "movenpick resort aswan": "موفنبيك ريزورت أسوان",
    "sofitel legend old cataract": "سوفيتيل ليجند أولد كتاراكت",
    "tolip aswan hotel": "فندق تيوليب أسوان",
    "pyramisa island resort aswan": "بيراميزا آيلاند ريزورت أسوان",
    "basma hotel aswan": "فندق بسمة أسوان",
    "pickalbatros laguna club resort": "بيك ألباتروس لاجونا كلوب ريزورت",
    "cleopatra luxury resort sharm": "كليوباترا لاكشري ريزورت شرم",
    "white hills resort": "وايت هيلز ريزورت",
    "sunrise montemare resort": "صنرايز مونتيماري ريزورت",
    "xperience kiroseiz parkland": "إكسبيرينس كيروسيز باركلاند",
    "steigenberger aldau beach hotel": "شتايجنبرجر الداو بيتش هوتيل",
    "sunrise garden beach resort": "صنرايز جاردن بيتش ريزورت",
    "pickalbatros alf leila wa leila": "بيك ألباتروس ألف ليلة وليلة",
    "the makadi spa hotel": "فندق المكادي سبا",
    "the oberoi beach resort": "ذا أوبروي بيتش ريزورت",
    "crowne plaza beirut by ihg": "كراون بلازا بيروت",
    "radisson blu martinez beirut": "راديسون بلو مارتينيز بيروت",
    "the smallville hotel": "ذا سمولفيل هوتيل",
    "eden hotel": "فندق إيدن",
    "ramada by wyndham downtown beirut": "رمادا باي ويندام وسط بيروت",
    "radisson hotel riyadh airport": "راديسون مطار الرياض",
    "sofitel riyadh hotel and convention centre": "سوفيتيل الرياض",
    "aw hotel riyadh": "فندق إيه دبليو الرياض",
    "radisson blu hotel riyadh convention and exhibition center": "راديسون بلو الرياض",
    "modrest hotel riyadh": "فندق مودريست الرياض",
    "hyatt regency london - the churchill": "حياة ريجنسي لندن ذا تشرشل",
    "st. james' court, a taj hotel, london": "سانت جيمس كورت تاج لندن",
    "chapter ealing in north acton": "تشابتر إيلينج نورث أكتون",
    "park plaza london waterloo": "بارك بلازا لندن ووترلو",
    "the prince akatoki london": "ذا برنس أكاتوكي لندن",
    "emirates palace mandarin oriental": "قصر الإمارات ماندارين أورينتال",
    "the st. regis abu dhabi": "سانت ريجيس أبوظبي",
    "hilton abu dhabi corniche": "هيلتون أبوظبي كورنيش",
    "yas island rotana": "ياس آيلاند روتانا",
    "citymax boutique": "سيتي ماكس بوتيك",
    "burj al arab jumeirah": "برج العرب جميرا",
    "atlantis the palm": "أتلانتس النخلة",
    "marriott harbour city": "ماريوت هاربور سيتي",
    "ibis styles dubai jumeirah": "إيبيس ستايلز دبي جميرا",
    "eurostars prima dubai": "يوروستارز بريما دبي",
    "four seasons hotel doha": "فور سيزونز الدوحة",
    "sheraton grand doha resort": "شيراتون جراند الدوحة",
    "crowne plaza doha": "كراون بلازا الدوحة",
    "citizenm doha": "سيتيزن إم الدوحة",
    "liwan hotel apartments": "شقق ليوان الفندقية",
    "hotel el palace barcelona": "هوتيل إل بالاس برشلونة",
    "renaissance barcelona hotel": "رينيسانس برشلونة",
    "novotel barcelona city": "نوفوتيل برشلونة سيتي",
    "barceló raval": "بارسيلو رافال",
    "astoria hotel": "فندق أستوريا",
    "hôtel du collectionneur": "هوتيل دو كوليكشونور",
    "hotel sax paris, lxr hotels & resorts": "هوتيل ساكس باريس",
    "pullman paris eiffel tower": "بولمان باريس إيفل تاور",
    "rochester champs elysees": "روتشستر الشانزليزيه",
    "hôtel eden opéra": "هوتيل إيدن أوبرا",
    "hotel palazzo manfredi": "هوتيل بالازو مانفريدي",
    "singer palace hotel roma": "سينجر بالاس هوتيل روما",
    "hotel dei barbieri": "هوتيل دي باربيري",
    "fh55 grand hotel palatino": "جراند هوتيل بالاتينو",
    "hotel alessandrino": "هوتيل أليساندرينو",
    "intercontinental - los angeles downtown": "إنتركونتيننتال لوس أنجلوس",
    "level hollywood": "ليفل هوليوود",
    "the line hotel la": "ذا لاين هوتيل لوس أنجلوس",
    "the biltmore los angeles": "ذا بيلتمور لوس أنجلوس",
    "olyver hotel": "فندق أوليفر",
    "new york marriott marquis": "ماريوت ماركيز نيويورك",
    "iroquois new york times square": "إيروكوا نيويورك تايمز سكوير",
    "hilton new york times square": "هيلتون نيويورك تايمز سكوير",
    "element times square west": "إليمنت تايمز سكوير ويست",
    "four points by sheraton new york downtown": "فور بوينتس شيراتون نيويورك",
    "ramada by wyndham istanbul pera taksim": "رمادا إسطنبول تقسيم",
    "days inn & suites by wyndham istanbul esenyurt": "دايز إن إسطنبول",
    "pisa hotel": "فندق بيزا",
    "la wisteria boutique hotel istanbul": "لا ويستيريا بوتيك إسطنبول",
    "the prenses hotel yenikapi istanbul": "ذا برنسس هوتيل يني كابي إسطنبول",
    "grand prince hotel shin takanawa": "جراند برنس هوتيل شين تاكاناوا",
    "grand nikko tokyo daiba": "جراند نيكو طوكيو دايبا",
    "hotel yaenomidori tokyo": "هوتيل يائينوميدوري طوكيو",
    "ueno rose": "أوينو روز",
    "sakura hotel nippori": "ساكورا هوتيل نيبوري",
    "constance moofushi maldives - all inclusive": "كونستانس موفوشي المالديف",
    "heritance aarah - premium all inclusive": "هيريتانس آراه المالديف",
    "sevinex inn": "سيفينكس إن",
    "park inn by radisson makkah aziziyah": "بارك إن راديسون مكة العزيزية",
    "doubletree by hilton makkah aziziyah": "دبل تري هيلتون مكة العزيزية",
    "le meridien towers makkah": "لو ميريديان تاورز مكة",
    "al kiram hotel al azizia": "فندق الكرام العزيزية",
    "al kiswah towers hotel": "فندق أبراج الكسوة",
    "joudyan red sea mall jeddah": "جوديان ردسي مول جدة",
    "best western plus jeddah hotel madinah road": "بست ويسترن بلاس جدة طريق المدينة",
    "hayat al rose hotel appartment": "شقق حياة الروز الفندقية",
    "crown town hotel": "كراون تاون هوتيل",
    "novotel jeddah tahlia": "نوفوتيل جدة طاليا",
    "sofitel shahd al madinah": "سوفيتيل شهد المدينة",
    "millennium taiba hotel": "ميلينيوم طيبة هوتيل",
    "tulip inn al daar rawafid": "توليب إن الدار روافد",
    "al ansar palace golden tulip hotel": "فندق الأنصار بالاس جولدن توليب",
    "al madina golden hotel": "المدينة جولدن هوتيل",
}


def _translate_activity(title):
    """Return Arabic name for an activity title, or the English title as fallback."""
    return _ACTIVITY_AR.get(title.lower(), title)


def _translate_hotel(name):
    """Return Arabic name for a hotel, or the English name as fallback."""
    return _HOTEL_AR.get(name.lower(), name)


def _infer_activity_type(title):
    """Guess an activity_type tag from an attraction/activity title."""
    t = title.lower()
    if any(w in t for w in ["temple", "mosque", "church", "cathedral", "museum", "fort", "citadel",
                            "palace", "roman", "pharaoh", "tomb", "valley", "ruins", "ancient",
                            "colosseum", "forum", "karnak", "abu simbel"]):
        return "historical"
    if any(w in t for w in ["beach", "diving", "snorkeling", "coral", "yacht", "water sport",
                            "dolphin", "sea", "surf", "parasail"]):
        return "beach"
    if any(w in t for w in ["market", "bazaar", "mall", "shopping", "souk", "souq"]):
        return "shopping"
    if any(w in t for w in ["park", "garden", "nature", "safari", "botanical", "mountain", "trek",
                            "balloon", "cruise"]):
        return "nature"
    if any(w in t for w in ["food", "cuisine", "dinner", "restaurant", "tapas"]):
        return "food"
    if any(w in t for w in ["walk", "stroll", "corniche", "promenade", "district", "downtown",
                            "ramblas", "crossing", "bridge", "tower", "eye", "square"]):
        return "city_walks"
    if any(w in t for w in ["villa", "overwater", "luxury", "spa"]):
        return "luxury"
    if any(w in t for w in ["religious", "haram", "kaaba", "mosque", "hira", "thawr",
                            "masjid", "uhud"]):
        return "religious"
    return "culture"


def enrich_cities_from_intents():
    """Reads intents file and dynamically adds new cities to the database."""
    try:
        data = load_intents()
        existing_en = {c["name_en"].lower() for c in cities}
        intent_cities = set()
        
        for intent in data.get("intents", []):
            tag = intent.get("tag", "")
            if tag.startswith("activities_"):
                intent_cities.add(tag.replace("activities_", "").lower())
            elif tag.startswith("ask_hotel_in_"):
                intent_cities.add(tag.replace("ask_hotel_in_", "").lower())
                
        for key in intent_cities:
            if key in INTENT_CITIES_MAP:
                name_en, name_ar = INTENT_CITIES_MAP[key]
                if name_en.lower() not in existing_en:
                    cities.append({
                        "name_en": name_en,
                        "name_ar": name_ar,
                        "activities": ["culture", "city_walks", "historical", "shopping", "food"],
                        "budget_level": "medium",
                        "best_duration": [3, 4, 5]
                    })
    except Exception:
        pass


def enrich_from_cities_dataset():
    """Reads citiesDataset.json and adds new cities + hotels to the in-memory database."""
    existing_cities_en = {c["name_en"].lower() for c in cities}
    existing_hotels_en = {h["name_en"].lower() for h in hotels}

    for city_obj in _cities_dataset:
        city_name = city_obj.get("city", "")
        city_name_ar = city_obj.get("city_ar", city_name)
        if not city_name:
            continue

        # Normalise name for matching ("Al Madinah" -> match with "Madinah")
        normalised = city_name.lower()
        # Check if this city already exists in our cities list
        if normalised not in existing_cities_en:
            # Also check partial match
            matched = False
            for existing in existing_cities_en:
                if existing in normalised or normalised in existing:
                    matched = True
                    break
            if not matched:
                # Infer activities from the hotels in this city
                all_facilities = []
                for h in city_obj.get("hotels", []):
                    all_facilities.extend(h.get("facilities", []))
                inferred_acts = _infer_activities_from_facilities(all_facilities)
                if len(inferred_acts) < 3:
                    inferred_acts = list(dict.fromkeys(inferred_acts + ["culture", "city_walks", "shopping", "food"]))

                cities.append({
                    "name_en": city_name,
                    "name_ar": city_name_ar,
                    "activities": inferred_acts[:6],
                    "budget_level": "medium",
                    "best_duration": [3, 4, 5]
                })
                existing_cities_en.add(normalised)

        # Add hotels from this city
        for h in city_obj.get("hotels", []):
            h_name = h.get("name", "")
            if not h_name or h_name.lower() in existing_hotels_en:
                continue

            # Determine budget from startingFrom price or stars
            starting = h.get("startingFrom", 0)
            budget = _price_to_budget(starting) if starting else _stars_to_budget(h.get("stars", 4))
            rating = h.get("rating", 4.0)
            facilities = h.get("facilities", [])
            loc_type = h.get("locationType", "")
            acts = _infer_activities_from_facilities(facilities, loc_type)

            # Find matching city_en in our cities list
            city_en_match = city_name
            for c in cities:
                if c["name_en"].lower() == city_name.lower():
                    city_en_match = c["name_en"]
                    break
                if city_name.lower() in c["name_en"].lower() or c["name_en"].lower() in city_name.lower():
                    city_en_match = c["name_en"]
                    break

            hotels.append({
                "name_en": h_name,
                "name_ar": _translate_hotel(h_name),
                "city_en": city_en_match,
                "budget_level": budget,
                "rating": rating,
                "duration_fit": 3,
                "activities": acts
            })
            existing_hotels_en.add(h_name.lower())


def enrich_from_destination():
    """Reads destination.json and adds new cities + attractions to the in-memory database."""
    existing_cities_en = {c["name_en"].lower() for c in cities}
    existing_attractions = {(a["city_en"].lower(), a["name_en"].lower()) for a in attractions}

    for dest in _destination_data:
        dest_name = dest.get("name", "")
        if not dest_name:
            continue

        # Find matching city_en in our cities list
        city_en_match = None
        for c in cities:
            if c["name_en"].lower() == dest_name.lower():
                city_en_match = c["name_en"]
                break
            if dest_name.lower() in c["name_en"].lower() or c["name_en"].lower() in dest_name.lower():
                city_en_match = c["name_en"]
                break

        if city_en_match is None:
            # City doesn't exist yet – add it
            name_ar = dest.get("name_ar", dest_name)
            cities.append({
                "name_en": dest_name,
                "name_ar": name_ar,
                "activities": ["culture", "city_walks", "historical", "shopping", "food"],
                "budget_level": "medium",
                "best_duration": [3, 4, 5]
            })
            city_en_match = dest_name
            existing_cities_en.add(dest_name.lower())

        # Add activities as attractions
        for act in dest.get("activities", []):
            title = act.get("title", "")
            if not title:
                continue
            key = (city_en_match.lower(), title.lower())
            if key in existing_attractions:
                continue

            activity_type = _infer_activity_type(title)
            attractions.append({
                "city_en": city_en_match,
                "activity_type": activity_type,
                "name_en": title,
                "name_ar": _translate_activity(title),
                "price_level": "medium"
            })
            existing_attractions.add(key)

# Run cities-only enrichment first (others need hotels/attractions defined)
enrich_cities_from_intents()

hotels = [
    {"name_en": "Novotel Jeddah Tahlia", "name_ar": "نوفوتيل جدة طاليا", "city_en": "Jeddah", "budget_level": "high", "rating": 4.7, "duration_fit": 3, "activities": ["luxury", "pool", "spa", "city_walks"]},
    {"name_en": "Best Western Plus Jeddah", "name_ar": "بست ويسترن بلاس جدة", "city_en": "Jeddah", "budget_level": "medium", "rating": 4.3, "duration_fit": 2, "activities": ["business", "city_walks", "shopping"]},
    {"name_en": "Elaf Jeddah Hotel", "name_ar": "إيلاف جدة هوتيل", "city_en": "Jeddah", "budget_level": "high", "rating": 4.5, "duration_fit": 3, "activities": ["shopping", "sea_view", "luxury", "honeymoon"]},
    {"name_en": "Crown Town Hotel", "name_ar": "كراون تاون هوتيل", "city_en": "Jeddah", "budget_level": "low", "rating": 4.0, "duration_fit": 2, "activities": ["family", "city_walks"]},

    {"name_en": "Abraj Al-Bait Towers Hotels", "name_ar": "فنادق أبراج البيت", "city_en": "Makkah", "budget_level": "high", "rating": 4.8, "duration_fit": 4, "activities": ["religious", "family", "luxury"]},

    {"name_en": "Al Ansar Palace Hotel", "name_ar": "فندق الأنصار بالاس", "city_en": "Madinah", "budget_level": "medium", "rating": 4.3, "duration_fit": 3, "activities": ["religious", "family", "city_walks"]},
    {"name_en": "Al Madina Golden Hotel", "name_ar": "المدينة جولدن هوتيل", "city_en": "Madinah", "budget_level": "low", "rating": 4.1, "duration_fit": 3, "activities": ["religious", "family"]},

    {"name_en": "Radisson Riyadh Airport", "name_ar": "راديسون مطار الرياض", "city_en": "Riyadh", "budget_level": "high", "rating": 4.5, "duration_fit": 2, "activities": ["business", "luxury"]},
    {"name_en": "Hilton Riyadh Hotel & Residences", "name_ar": "هيلتون الرياض", "city_en": "Riyadh", "budget_level": "high", "rating": 4.7, "duration_fit": 3, "activities": ["business", "luxury", "shopping"]},

    {"name_en": "Steigenberger Hotel El Tahrir Cairo", "name_ar": "شتايجنبرجر التحرير القاهرة", "city_en": "Cairo", "budget_level": "medium", "rating": 4.5, "duration_fit": 3, "activities": ["historical", "culture", "city_walks"]},
    {"name_en": "Pyramisa Suites Hotel Cairo", "name_ar": "بيراميزا سويتس القاهرة", "city_en": "Cairo", "budget_level": "medium", "rating": 4.1, "duration_fit": 3, "activities": ["historical", "shopping", "city_walks"]},
    {"name_en": "Hilton Cairo Grand Nile Tower", "name_ar": "هيلتون القاهرة جراند نايل تاور", "city_en": "Cairo", "budget_level": "high", "rating": 4.6, "duration_fit": 3, "activities": ["luxury", "nightlife", "city_walks"]},
    {"name_en": "Marriott Mena House", "name_ar": "ماريوت مينا هاوس", "city_en": "Cairo", "budget_level": "high", "rating": 4.8, "duration_fit": 3, "activities": ["historical", "luxury", "romantic"]},

    {"name_en": "Steigenberger Cecil Alexandria", "name_ar": "شتايجنبرجر سيسيل الإسكندرية", "city_en": "Alexandria", "budget_level": "high", "rating": 4.6, "duration_fit": 2, "activities": ["sea_view", "historical", "romantic"]},
    {"name_en": "Windsor Palace Hotel", "name_ar": "ويندسور بالاس هوتيل", "city_en": "Alexandria", "budget_level": "medium", "rating": 4.3, "duration_fit": 2, "activities": ["sea_view", "city_walks", "romantic"]},
    {"name_en": "Le Metropole Hotel", "name_ar": "لو متروبول", "city_en": "Alexandria", "budget_level": "medium", "rating": 4.2, "duration_fit": 2, "activities": ["historical", "sea_view", "culture"]},

    {"name_en": "Sharm 5-Star Beach Resort", "name_ar": "ريزورت شرم 5 نجوم على البحر", "city_en": "Sharm El Sheikh", "budget_level": "high", "rating": 4.8, "duration_fit": 4, "activities": ["beach", "honeymoon", "pool", "spa"]},
    {"name_en": "Sharm Romantic Sea View Suites", "name_ar": "سويتات شرم الرومانسية بإطلالة البحر", "city_en": "Sharm El Sheikh", "budget_level": "high", "rating": 4.7, "duration_fit": 4, "activities": ["honeymoon", "romantic", "sea_view", "spa"]},

    {"name_en": "ALDAU Beach Hotel", "name_ar": "ألداو بيتش هوتيل", "city_en": "Hurghada", "budget_level": "medium", "rating": 4.6, "duration_fit": 4, "activities": ["beach", "family", "pool", "spa"]},
    {"name_en": "Steigenberger Al Dau Beach", "name_ar": "شتايجنبرجر ألداو بيتش", "city_en": "Hurghada", "budget_level": "high", "rating": 4.8, "duration_fit": 4, "activities": ["beach", "family", "pool", "luxury"]},

    {"name_en": "Mövenpick Resort Aswan", "name_ar": "موفنبيك ريزورت أسوان", "city_en": "Aswan", "budget_level": "high", "rating": 4.7, "duration_fit": 3, "activities": ["relaxation", "romantic", "nature"]},
    {"name_en": "Sofitel Legend Old Cataract", "name_ar": "سوفيتيل ليجند أولد كاتاراكت", "city_en": "Aswan", "budget_level": "high", "rating": 4.9, "duration_fit": 3, "activities": ["luxury", "historical", "romantic"]},

    {"name_en": "Hôtel Plaza Athénée", "name_ar": "هوتيل بلازا أثيني", "city_en": "Paris", "budget_level": "high", "rating": 4.9, "duration_fit": 4, "activities": ["romantic", "luxury", "honeymoon"]},
    {"name_en": "Le Meurice", "name_ar": "لو موريس", "city_en": "Paris", "budget_level": "high", "rating": 4.8, "duration_fit": 4, "activities": ["luxury", "culture", "romantic"]},
    {"name_en": "Hôtel de Crillon", "name_ar": "هوتيل دو كريون", "city_en": "Paris", "budget_level": "high", "rating": 4.8, "duration_fit": 4, "activities": ["luxury", "shopping", "romantic"]},
    {"name_en": "Hôtel Shangri-La Paris", "name_ar": "هوتيل شانغريلا باريس", "city_en": "Paris", "budget_level": "high", "rating": 4.9, "duration_fit": 4, "activities": ["luxury", "romantic", "honeymoon"]},
    {"name_en": "Hôtel Pullman Eiffel Tower", "name_ar": "هوتيل بولمان برج إيفل", "city_en": "Paris", "budget_level": "medium", "rating": 4.5, "duration_fit": 3, "activities": ["city_walks", "romantic", "culture"]},

    {"name_en": "Days Inn by Wyndham Istanbul", "name_ar": "دايز إن باي ويندهام إسطنبول", "city_en": "Istanbul", "budget_level": "medium", "rating": 4.2, "duration_fit": 3, "activities": ["shopping", "historical", "city_walks"]},
    {"name_en": "Sultanahmet Area Hotel", "name_ar": "فندق منطقة السلطان أحمد", "city_en": "Istanbul", "budget_level": "medium", "rating": 4.4, "duration_fit": 3, "activities": ["historical", "culture", "romantic"]},

    {"name_en": "Constance Moofushi", "name_ar": "كونستانس موفوشي", "city_en": "Maldives", "budget_level": "high", "rating": 4.9, "duration_fit": 5, "activities": ["water_villa", "honeymoon", "luxury", "spa"]},
    {"name_en": "Heritance Aarah", "name_ar": "هيريتانس آراه", "city_en": "Maldives", "budget_level": "high", "rating": 4.8, "duration_fit": 5, "activities": ["luxury", "beach", "wellness", "spa"]},
    {"name_en": "Conrad Maldives Rangali Island", "name_ar": "كونراد مالديف رانغالي آيلاند", "city_en": "Maldives", "budget_level": "high", "rating": 5.0, "duration_fit": 5, "activities": ["water_villa", "luxury", "honeymoon", "romantic"]},

    {"name_en": "London City Center Hotel", "name_ar": "فندق لندن سنتر", "city_en": "London", "budget_level": "high", "rating": 4.5, "duration_fit": 3, "activities": ["business", "shopping", "city_walks"]},

    {"name_en": "Dubai Luxury City Hotel", "name_ar": "فندق دبي الفاخر", "city_en": "Dubai", "budget_level": "high", "rating": 4.7, "duration_fit": 4, "activities": ["luxury", "shopping", "family"]}
]

# Added more attractions, especially for Aswan and other longer stays
attractions = [
    {"city_en": "Jeddah", "activity_type": "sea_view", "name_en": "Jeddah Corniche", "name_ar": "كورنيش جدة", "price_level": "low"},
    {"city_en": "Jeddah", "activity_type": "shopping", "name_en": "Red Sea Mall", "name_ar": "رد سي مول", "price_level": "medium"},
    {"city_en": "Jeddah", "activity_type": "food", "name_en": "Jeddah Waterfront Dining", "name_ar": "مطاعم واجهة جدة البحرية", "price_level": "medium"},
    {"city_en": "Jeddah", "activity_type": "city_walks", "name_en": "Historic Jeddah Walk", "name_ar": "جولة في جدة التاريخية", "price_level": "low"},

    {"city_en": "Makkah", "activity_type": "religious", "name_en": "Al Haram Visit", "name_ar": "زيارة الحرم", "price_level": "low"},
    {"city_en": "Makkah", "activity_type": "city_walks", "name_en": "Abraj Al-Bait Area Walk", "name_ar": "جولة في منطقة أبراج البيت", "price_level": "low"},
    {"city_en": "Makkah", "activity_type": "family", "name_en": "Calm Evening Around the Haram", "name_ar": "أمسية هادئة حول الحرم", "price_level": "low"},

    {"city_en": "Madinah", "activity_type": "religious", "name_en": "Prophet's Mosque Visit", "name_ar": "زيارة المسجد النبوي", "price_level": "low"},
    {"city_en": "Madinah", "activity_type": "city_walks", "name_en": "Quba Area Walk", "name_ar": "جولة في منطقة قباء", "price_level": "low"},
    {"city_en": "Madinah", "activity_type": "relaxation", "name_en": "Quiet Evening Reflection", "name_ar": "أمسية هادئة للتأمل", "price_level": "low"},

    {"city_en": "Riyadh", "activity_type": "business", "name_en": "Business District Visit", "name_ar": "زيارة منطقة الأعمال", "price_level": "medium"},
    {"city_en": "Riyadh", "activity_type": "shopping", "name_en": "Riyadh Shopping Mall", "name_ar": "مولات الرياض", "price_level": "medium"},
    {"city_en": "Riyadh", "activity_type": "food", "name_en": "Modern Riyadh Dining", "name_ar": "تجربة مطاعم الرياض الحديثة", "price_level": "medium"},

    {"city_en": "Cairo", "activity_type": "historical", "name_en": "Giza Pyramids", "name_ar": "أهرامات الجيزة", "price_level": "medium"},
    {"city_en": "Cairo", "activity_type": "culture", "name_en": "Al Moez Street", "name_ar": "شارع المعز", "price_level": "low"},
    {"city_en": "Cairo", "activity_type": "shopping", "name_en": "Khan El Khalili", "name_ar": "خان الخليلي", "price_level": "low"},
    {"city_en": "Cairo", "activity_type": "nightlife", "name_en": "Nile Evening Walk", "name_ar": "نزهة مسائية على النيل", "price_level": "low"},
    {"city_en": "Cairo", "activity_type": "food", "name_en": "Traditional Egyptian Dinner", "name_ar": "عشاء مصري تقليدي", "price_level": "medium"},

    {"city_en": "Alexandria", "activity_type": "sea_view", "name_en": "Alexandria Corniche", "name_ar": "كورنيش الإسكندرية", "price_level": "low"},
    {"city_en": "Alexandria", "activity_type": "historical", "name_en": "Qaitbay Citadel", "name_ar": "قلعة قايتباي", "price_level": "medium"},
    {"city_en": "Alexandria", "activity_type": "culture", "name_en": "Bibliotheca Alexandrina", "name_ar": "مكتبة الإسكندرية", "price_level": "medium"},
    {"city_en": "Alexandria", "activity_type": "food", "name_en": "Seafood Dinner", "name_ar": "عشاء مأكولات بحرية", "price_level": "medium"},

    {"city_en": "Sharm El Sheikh", "activity_type": "beach", "name_en": "Private Beach Day", "name_ar": "يوم شاطئ خاص", "price_level": "medium"},
    {"city_en": "Sharm El Sheikh", "activity_type": "spa", "name_en": "Resort Spa Session", "name_ar": "جلسة سبا في الريزورت", "price_level": "high"},
    {"city_en": "Sharm El Sheikh", "activity_type": "honeymoon", "name_en": "Romantic Sea Dinner", "name_ar": "عشاء رومانسي على البحر", "price_level": "high"},
    {"city_en": "Sharm El Sheikh", "activity_type": "pool", "name_en": "Pool Relaxation Time", "name_ar": "وقت استرخاء في المسبح", "price_level": "low"},
    {"city_en": "Sharm El Sheikh", "activity_type": "relaxation", "name_en": "Free Resort Relaxation", "name_ar": "استرخاء حر داخل الريزورت", "price_level": "low"},

    {"city_en": "Hurghada", "activity_type": "beach", "name_en": "Red Sea Beach Day", "name_ar": "يوم على شاطئ البحر الأحمر", "price_level": "medium"},
    {"city_en": "Hurghada", "activity_type": "family", "name_en": "Family Pool Time", "name_ar": "وقت عائلي في المسبح", "price_level": "low"},
    {"city_en": "Hurghada", "activity_type": "spa", "name_en": "Wellness Spa", "name_ar": "سبا واسترخاء", "price_level": "medium"},
    {"city_en": "Hurghada", "activity_type": "relaxation", "name_en": "Sea Sunset Relaxation", "name_ar": "استرخاء وقت الغروب على البحر", "price_level": "low"},

    # Aswan - expanded
    {"city_en": "Aswan", "activity_type": "relaxation", "name_en": "Nile Boat Relaxation", "name_ar": "استرخاء في رحلة نيلية", "price_level": "medium"},
    {"city_en": "Aswan", "activity_type": "historical", "name_en": "Old Cataract Visit", "name_ar": "زيارة أولد كاتاراكت", "price_level": "medium"},
    {"city_en": "Aswan", "activity_type": "historical", "name_en": "Philae Temple", "name_ar": "معبد فيلة", "price_level": "medium"},
    {"city_en": "Aswan", "activity_type": "nature", "name_en": "Nubian Village", "name_ar": "القرية النوبية", "price_level": "low"},
    {"city_en": "Aswan", "activity_type": "historical", "name_en": "Abu Simbel Day Trip", "name_ar": "رحلة أبو سمبل", "price_level": "high"},
    {"city_en": "Aswan", "activity_type": "city_walks", "name_en": "Aswan Market Walk", "name_ar": "جولة في سوق أسوان", "price_level": "low"},
    {"city_en": "Aswan", "activity_type": "relaxation", "name_en": "Felucca Ride", "name_ar": "ركوب فلوكة", "price_level": "medium"},
    {"city_en": "Aswan", "activity_type": "nature", "name_en": "Botanical Garden", "name_ar": "الحديقة النباتية", "price_level": "medium"},
    {"city_en": "Aswan", "activity_type": "romantic", "name_en": "Sunset by the Nile", "name_ar": "غروب الشمس على النيل", "price_level": "low"},
    {"city_en": "Aswan", "activity_type": "culture", "name_en": "Nubian Cultural Evening", "name_ar": "أمسية ثقافية نوبية", "price_level": "medium"},

    {"city_en": "Paris", "activity_type": "romantic", "name_en": "Seine River Evening", "name_ar": "أمسية على نهر السين", "price_level": "medium"},
    {"city_en": "Paris", "activity_type": "culture", "name_en": "Louvre Museum", "name_ar": "متحف اللوفر", "price_level": "medium"},
    {"city_en": "Paris", "activity_type": "shopping", "name_en": "Champs-Élysées Walk", "name_ar": "جولة في الشانزليزيه", "price_level": "medium"},
    {"city_en": "Paris", "activity_type": "historical", "name_en": "Historic Paris Walk", "name_ar": "جولة باريس التاريخية", "price_level": "medium"},

    {"city_en": "Istanbul", "activity_type": "historical", "name_en": "Sultanahmet Tour", "name_ar": "جولة السلطان أحمد", "price_level": "medium"},
    {"city_en": "Istanbul", "activity_type": "shopping", "name_en": "Grand Bazaar", "name_ar": "الجراند بازار", "price_level": "low"},
    {"city_en": "Istanbul", "activity_type": "food", "name_en": "Turkish Food Evening", "name_ar": "أمسية المأكولات التركية", "price_level": "medium"},
    {"city_en": "Istanbul", "activity_type": "culture", "name_en": "Bosphorus View Walk", "name_ar": "نزهة بإطلالة البوسفور", "price_level": "low"},

    {"city_en": "Maldives", "activity_type": "water_villa", "name_en": "Water Villa Stay Experience", "name_ar": "تجربة الإقامة في فيلا مائية", "price_level": "high"},
    {"city_en": "Maldives", "activity_type": "spa", "name_en": "Overwater Spa", "name_ar": "سبا فوق الماء", "price_level": "high"},
    {"city_en": "Maldives", "activity_type": "honeymoon", "name_en": "Private Beach Dinner", "name_ar": "عشاء خاص على الشاطئ", "price_level": "high"},
    {"city_en": "Maldives", "activity_type": "relaxation", "name_en": "Ocean Relaxation Day", "name_ar": "يوم استرخاء على البحر", "price_level": "medium"},
    {"city_en": "Maldives", "activity_type": "wellness", "name_en": "Wellness Morning Session", "name_ar": "جلسة صباحية للعافية", "price_level": "medium"},

    {"city_en": "London", "activity_type": "city_walks", "name_en": "London City Center Walk", "name_ar": "جولة في وسط لندن", "price_level": "medium"},
    {"city_en": "London", "activity_type": "shopping", "name_en": "Oxford Street", "name_ar": "أوكسفورد ستريت", "price_level": "medium"},
    {"city_en": "London", "activity_type": "historical", "name_en": "Historic London Tour", "name_ar": "جولة لندن التاريخية", "price_level": "medium"},
    {"city_en": "London", "activity_type": "food", "name_en": "London Food Stop", "name_ar": "تجربة طعام في لندن", "price_level": "medium"},

    {"city_en": "Dubai", "activity_type": "luxury", "name_en": "Luxury Downtown Dubai", "name_ar": "جولة فاخرة في وسط دبي", "price_level": "high"},
    {"city_en": "Dubai", "activity_type": "shopping", "name_en": "Dubai Mall", "name_ar": "دبي مول", "price_level": "medium"},
    {"city_en": "Dubai", "activity_type": "family", "name_en": "Family Fun Day", "name_ar": "يوم عائلي ترفيهي", "price_level": "medium"},
    {"city_en": "Dubai", "activity_type": "city_walks", "name_en": "Dubai Marina Walk", "name_ar": "نزهة في دبي مارينا", "price_level": "medium"},
]

# Now that hotels + attractions are defined, enrich from JSON files
enrich_from_cities_dataset()
enrich_from_destination()

# ============================================================
# INTENT MATCHER
# ============================================================

class IntentMatcher:
    def __init__(self, intents_data):
        self.intents = intents_data.get("intents", [])
        self.pattern_texts = []
        self.pattern_tags = []

        for intent in self.intents:
            for pattern in intent.get("patterns", []):
                self.pattern_texts.append(pattern.lower())
                self.pattern_tags.append(intent["tag"])

        self.vectorizer = TfidfVectorizer(analyzer="char_wb", ngram_range=(2, 4))
        self.pattern_vectors = self.vectorizer.fit_transform(self.pattern_texts)

    def predict_intent(self, text, threshold=0.20):
        query_vec = self.vectorizer.transform([text.lower()])
        scores = cosine_similarity(query_vec, self.pattern_vectors)[0]
        best_idx = int(np.argmax(scores))
        best_score = float(scores[best_idx])

        if best_score < threshold:
            return None, best_score
        return self.pattern_tags[best_idx], best_score

    def get_response(self, tag, language_mode="both"):
        for intent in self.intents:
            if intent["tag"] == tag:
                responses = intent.get("responses", [])
                english_responses = [r for r in responses if any("a" <= ch.lower() <= "z" for ch in r)]
                arabic_responses = [r for r in responses if any("\u0600" <= ch <= "\u06FF" for ch in r)]

                if language_mode == "en":
                    return random.choice(english_responses or responses)
                if language_mode == "ar":
                    return random.choice(arabic_responses or responses)

                en_text = random.choice(english_responses or responses)
                ar_text = random.choice(arabic_responses or responses)
                return f"Arabic:\n{ar_text}\n\nEnglish:\n{en_text}"

        return "No response available."


# ============================================================
# RECOMMENDATION FUNCTIONS
# ============================================================

def activities_to_vector(selected, universe):
    return [1 if item in selected else 0 for item in universe]


def recommend_city(user_activities, user_budget, user_duration):
    user_vector = np.array([activities_to_vector(user_activities, all_activities)])
    city_vectors = np.array([activities_to_vector(city["activities"], all_activities) for city in cities])

    similarity_scores = cosine_similarity(user_vector, city_vectors)[0]
    scored = []

    for i, city in enumerate(cities):
        score = float(similarity_scores[i])

        if user_duration in city["best_duration"]:
            score += 0.10

        if city["budget_level"] == user_budget:
            score += 0.10
        elif user_budget == "high":
            score += 0.05
        elif user_budget == "medium" and city["budget_level"] in ["low", "medium"]:
            score += 0.05
        elif user_budget == "low" and city["budget_level"] == "low":
            score += 0.05

        scored.append((city, score))

    scored.sort(key=lambda x: x[1], reverse=True)
    # Return both the best city and the raw score
    return scored[0][0], scored[0][1]


def hotel_feature_vector(hotel, user_activities):
    activity_match = len(set(user_activities) & set(hotel["activities"]))
    return [
        budget_map[hotel["budget_level"]],
        hotel["duration_fit"],
        hotel["rating"],
        activity_match
    ]


def recommend_hotels(city_en, user_activities, user_budget, user_duration, top_k=3):
    city_hotels = [h for h in hotels if h["city_en"] == city_en]
    if not city_hotels:
        return []

    X = [hotel_feature_vector(h, user_activities) for h in city_hotels]
    y = np.array([[budget_map[user_budget], user_duration, 5.0, len(user_activities)]])

    model = NearestNeighbors(n_neighbors=min(top_k, len(city_hotels)), metric="euclidean")
    model.fit(X)
    _, indices = model.kneighbors(y)
    return [city_hotels[i] for i in indices[0]]


def budget_allows(user_budget, place_budget):
    if user_budget == "high":
        return True
    if user_budget == "medium":
        return place_budget in ["low", "medium"]
    return place_budget == "low"


def get_city_fallback_pool(city_en):
    fallback = {
        "Aswan": [
            ("Free relaxation at hotel", "استرخاء حر في الفندق"),
            ("Nile sunset walk", "نزهة وقت الغروب على النيل"),
            ("Photo stop by the river", "وقفة تصوير بجانب النيل"),
            ("Local café break", "استراحة في مقهى محلي"),
            ("Free exploration near hotel", "استكشاف حر بالقرب من الفندق"),
        ],
        "Sharm El Sheikh": [
            ("Relax by hotel pool", "استرخاء بجانب مسبح الفندق"),
            ("Free beach time", "وقت حر على الشاطئ"),
            ("Sunset by the sea", "مشاهدة الغروب على البحر"),
            ("Light evening walk", "نزهة مسائية خفيفة"),
            ("Snorkeling at nearby reef", "غوص سطحي في الشعاب القريبة"),
            ("Explore local markets", "استكشاف الأسواق المحلية"),
        ],
        "Hurghada": [
            ("Relax by the sea", "استرخاء على البحر"),
            ("Hotel pool time", "وقت في مسبح الفندق"),
            ("Free evening walk", "نزهة مسائية حرة"),
            ("Seafood dinner by the marina", "عشاء بحري بجوار المارينا"),
            ("Souvenir shopping", "تسوق الهدايا التذكارية"),
        ],
        "Cairo": [
            ("Free time in downtown", "وقت حر في وسط البلد"),
            ("Coffee break with city view", "استراحة قهوة بإطلالة على المدينة"),
            ("Shopping free time", "وقت حر للتسوق"),
            ("Walk along the Nile Corniche", "تمشية على كورنيش النيل"),
            ("Try traditional Egyptian street food", "تجربة أكل الشارع المصري التقليدي"),
        ],
        "Dubai": [
            ("Luxury shopping time", "وقت للتسوق الفاخر"),
            ("Relax at beach club", "استرخاء في نادي شاطئي"),
            ("Evening walk in Dubai Marina", "نزهة مسائية في دبي مارينا"),
            ("Fine dining experience", "تجربة عشاء فاخرة"),
            ("Visit a local cafe", "زيارة مقهى محلي"),
        ],
        "London": [
            ("Walk in a Royal Park", "نزهة في حديقة ملكية"),
            ("Afternoon tea experience", "تجربة شاي بعد الظهيرة"),
            ("Explore local neighborhood", "استكشاف الحي المحلي"),
            ("Pub dinner", "عشاء في حانة تقليدية"),
            ("West End stroll", "جولة في منطقة ويست إند"),
        ],
        "Paris": [
            ("Relax at a Parisian café", "استرخاء في مقهى باريسي"),
            ("Walk along the Seine", "تمشية على طول نهر السين"),
            ("Explore a local bakery", "استكشاف مخبز محلي"),
            ("Boutique shopping", "تسوق في المتاجر الصغيرة"),
            ("Evening wine and cheese tasting", "تذوق النبيذ والجبن مساءً"),
        ],
        "Rome": [
            ("Gelato tasting walk", "جولة تذوق الجيلاتي"),
            ("Piazza people-watching", "الجلوس في الساحة لمراقبة الناس"),
            ("Try authentic pasta dinner", "تجربة عشاء مكرونة أصلي"),
            ("Explore cobblestone streets", "استكشاف الشوارع المرصوفة بالحصى"),
            ("Espresso break", "استراحة إسبريسو"),
        ],
        "Istanbul": [
            ("Turkish tea break", "استراحة شاي تركي"),
            ("Walk along the Bosphorus", "نزهة على طول البوسفور"),
            ("Try Turkish delight sweets", "تجربة حلويات الحلقوم التركية"),
            ("Explore local spice shops", "استكشاف متاجر التوابل المحلية"),
            ("Traditional dinner", "عشاء تقليدي"),
        ],
        "Maldives": [
            ("Relax on the private beach", "استرخاء على الشاطئ الخاص"),
            ("Snorkeling around the villa", "غوص سطحي حول الفيلا"),
            ("Sunset cocktail hour", "ساعة كوكتيل وقت الغروب"),
            ("Spa and wellness time", "وقت للسبا والعافية"),
            ("Romantic beach walk", "نزهة رومانسية على الشاطئ"),
        ],
        "Riyadh": [
            ("Visit a luxury mall", "زيارة مول فاخر"),
            ("Try authentic Saudi coffee", "تجربة القهوة السعودية الأصيلة"),
            ("Evening walk in Boulevard", "نزهة مسائية في البوليفارد"),
            ("Fine dining with city view", "عشاء فاخر مع إطلالة على المدينة"),
            ("Relax at hotel lounge", "استرخاء في صالة الفندق"),
        ],
        "Jeddah": [
            ("Walk on Jeddah Corniche", "تمشية على كورنيش جدة"),
            ("Seafood dinner by the Red Sea", "عشاء مأكولات بحرية على البحر الأحمر"),
            ("Explore historic cafes", "استكشاف المقاهي التاريخية"),
            ("Shopping at Red Sea Mall", "التسوق في ردسي مول"),
            ("Relax with sea breeze", "استرخاء مع نسيم البحر"),
        ],
        "default": [
            ("Free exploration day", "يوم استكشاف حر"),
            ("Relax at hotel", "استرخاء في الفندق"),
            ("Light local walk", "نزهة محلية خفيفة"),
            ("Coffee and rest", "استراحة للقهوة"),
            ("Try local street food", "تجربة أكل الشارع المحلي"),
            ("Explore local markets", "استكشاف الأسواق المحلية"),
            ("Evening city stroll", "جولة مسائية في المدينة"),
            ("Photography walk", "جولة للتصوير الفوتوغرافي"),
            ("Visit a popular local café", "زيارة مقهى محلي شهير"),
            ("Relax in a nearby park", "استرخاء في حديقة قريبة"),
        ]
    }
    return fallback.get(city_en, fallback["default"])


def generate_itinerary(city_en, user_activities, user_budget, user_duration):
    city_places = [p for p in attractions if p["city_en"] == city_en]

    preferred = [p for p in city_places if p["activity_type"] in user_activities and budget_allows(user_budget, p["price_level"])]
    extra = [p for p in city_places if p not in preferred and budget_allows(user_budget, p["price_level"])]
    ordered = preferred + extra

    fallback_pool = get_city_fallback_pool(city_en)
    fallback_index = 0
    real_place_index = 0

    itinerary = []

    for day in range(1, user_duration + 1):
        plan = {"day": day, "ar": [], "en": []}

        if day == 1:
            plan["ar"].append("تسجيل الدخول في الفندق والراحة")
            plan["en"].append("Check-in at hotel and rest")

        # Add up to 3 real attractions per day
        added_today = 0
        while real_place_index < len(ordered) and added_today < 3:
            place = ordered[real_place_index]
            plan["ar"].append(place["name_ar"])
            plan["en"].append(place["name_en"])
            real_place_index += 1
            added_today += 1

        # Determine minimum items based on the day
        if day == 1:
            minimum_items_needed = 4  # Check-in counts as 1, so 3 activities
        elif day == user_duration:
            minimum_items_needed = 3  # Lighter schedule for departure day
        else:
            minimum_items_needed = 5  # Full days get 5 activities

        current_non_meta_count = len(plan["ar"])

        while current_non_meta_count < minimum_items_needed:
            en_text, ar_text = fallback_pool[fallback_index % len(fallback_pool)]
            plan["en"].append(en_text)
            plan["ar"].append(ar_text)
            fallback_index += 1
            current_non_meta_count += 1

        if day == user_duration:
            plan["ar"].append("تسجيل الخروج والاستعداد للمغادرة")
            plan["en"].append("Check-out and prepare for departure")

        itinerary.append(plan)

    return itinerary


# ============================================================
# FORMATTERS
# ============================================================

def format_hotels(hotel_list, lang):
    if lang == "ar":
        lines = ["الفنادق المقترحة:"]
        for h in hotel_list:
            lines.append(f"- {h['name_ar']} | التقييم: {h['rating']} | الميزانية: {h['budget_level']}")
        return "\n".join(lines)

    lines = ["Recommended Hotels:"]
    for h in hotel_list:
        lines.append(f"- {h['name_en']} | Rating: {h['rating']} | Budget: {h['budget_level']}")
    return "\n".join(lines)


def format_itinerary(itinerary, lang):
    title = "خطة الرحلة:" if lang == "ar" else "Trip Plan:"
    lines = [title]

    for day in itinerary:
        day_title = f"\nاليوم {day['day']}:" if lang == "ar" else f"\nDay {day['day']}:"
        lines.append(day_title)
        items = day["ar"] if lang == "ar" else day["en"]
        for item in items:
            lines.append(f"- {item}")

    return "\n".join(lines)


def build_recommendation_response(best_city, hotel_list, itinerary, language_mode, match_score=None, user_selected=False):
    if user_selected:
        city_title_ar = "المدينة التي اخترتها"
        city_title_en = "Selected City"
        score_ar = ""
        score_en = ""
    else:
        city_title_ar = "المدينة المقترحة من الذكاء الاصطناعي"
        city_title_en = "AI Recommended City"
        score_ar = f"دقة المطابقة لاختياراتك: {match_score:.1f}%\n" if match_score else ""
        score_en = f"Match Accuracy: {match_score:.1f}%\n" if match_score else ""

    ar_text = (
        f"{city_title_ar}: {best_city['name_ar']}\n"
        f"اسم المدينة بالإنجليزية: {best_city['name_en']}\n"
        f"{score_ar}\n"
        f"{format_hotels(hotel_list, 'ar')}\n\n"
        f"{format_itinerary(itinerary, 'ar')}"
    )

    en_text = (
        f"{city_title_en}: {best_city['name_en']}\n"
        f"Arabic Name: {best_city['name_ar']}\n"
        f"{score_en}\n"
        f"{format_hotels(hotel_list, 'en')}\n\n"
        f"{format_itinerary(itinerary, 'en')}"
    )

    if language_mode == "ar":
        return ar_text
    if language_mode == "en":
        return en_text

    return f"Arabic:\n{ar_text}\n\n{'='*50}\n\nEnglish:\n{en_text}"


# ============================================================
# USER FLOW
# ============================================================

def budget_usd_to_level(budget_usd):
    try:
        budget_usd = float(budget_usd)
        if budget_usd <= 700:
            return "low"
        elif budget_usd <= 1800:
            return "medium"
        else:
            return "high"
    except ValueError:
        return "medium"

interest_map = {
    "Beach & Relaxation": ["beach", "relaxation", "sea_view"],
    "Adventure & Sports": ["nature", "beach", "city_walks"],
    "Culture & History": ["culture", "historical"],
    "Food & Cuisine": ["food", "culture"],
    "Nature & Wildlife": ["nature", "relaxation"],
    "Shopping": ["shopping"],
    "Nightlife": ["nightlife"],
    "Photography": ["city_walks", "sea_view", "nature", "historical"],
}

def convert_interests_to_activities(selected_interests):
    activities = []
    for interest in selected_interests:
        interest_clean = interest.strip().lower()
        for key, mapped in interest_map.items():
            if interest_clean == key.lower():
                activities.extend(mapped)
    
    activities = list(dict.fromkeys(activities))
    if not activities:
        activities = ["culture", "city_walks"]
    return activities

def find_city_by_destination(destination):
    if not destination:
        return None
    destination = destination.strip().lower()
    
    # Handle common aliases and spelling variations
    destination = _CITY_NAME_ALIASES.get(destination, destination)
    
    # 1. Exact match first
    for city in cities:
        city_en = city["name_en"].lower()
        city_ar = city["name_ar"].lower()
        if destination == city_en or destination == city_ar:
            return city
    
    # 2. Partial match
    for city in cities:
        city_en = city["name_en"].lower()
        city_ar = city["name_ar"].lower()
        if destination in city_en or destination in city_ar:
            return city
        if city_en in destination or city_ar in destination:
            return city
    
    # 3. Search in citiesDataset.json names (handles spelling differences)
    for city_obj in _cities_dataset:
        cd_name = city_obj.get("city", "").lower()
        cd_name_ar = city_obj.get("city_ar", "").lower()
        cd_slug = city_obj.get("slug", "").lower()
        if destination in cd_name or destination in cd_name_ar or destination == cd_slug:
            # Find in our enriched cities list
            for city in cities:
                cn = city["name_en"].lower()
                if cn == cd_name or cd_name in cn or cn in cd_name:
                    return city
    
    # 4. Search in destination.json names
    for dest_obj in _destination_data:
        d_name = dest_obj.get("name", "").lower()
        d_name_ar = dest_obj.get("name_ar", "").lower()
        if destination in d_name or destination in d_name_ar or d_name in destination:
            for city in cities:
                cn = city["name_en"].lower()
                if cn == d_name or d_name in cn or cn in d_name:
                    return city
    
    return None

def generate_plan_from_form(destination, budget_usd, duration_days, selected_interests, language_mode="both"):
    user_budget_level = budget_usd_to_level(budget_usd)
    user_activities = convert_interests_to_activities(selected_interests)
    
    try:
        user_duration = int(duration_days)
    except ValueError:
        user_duration = 3
        
    selected_city = find_city_by_destination(destination)
    match_score = None
    user_selected = False
    
    if selected_city is None:
        if destination.strip():
            error_ar = f"عذراً، الوجهة '{destination}' غير متوفرة في قاعدة بياناتنا حالياً. يرجى ترك الخانة فارغة ليقترح الذكاء الاصطناعي وجهة بديلة، أو اختر مدينة أخرى."
            error_en = f"Sorry, the destination '{destination}' is not available in our database. Please leave the field empty for an AI recommendation, or choose another city."
            final_text = error_ar if language_mode == "ar" else error_en
            return {
                "destination_entered": destination,
                "ai_selected_city_en": "",
                "ai_selected_city_ar": "",
                "budget_level": user_budget_level,
                "activities_used_by_ai": user_activities,
                "recommended_hotels": [],
                "itinerary": "",
                "final_text": final_text,
            }
        
        selected_city, raw_score = recommend_city(user_activities, user_budget_level, user_duration)
        # Normalize score (max possible raw score is ~1.2)
        match_score = min(100.0, (raw_score / 1.2) * 100)
    else:
        user_selected = True
        
    hotel_list = recommend_hotels(selected_city["name_en"], user_activities, user_budget_level, user_duration)
    itinerary = generate_itinerary(selected_city["name_en"], user_activities, user_budget_level, user_duration)
    
    final_text = build_recommendation_response(selected_city, hotel_list, itinerary, language_mode, match_score, user_selected)
    
    return {
        "destination_entered": destination if destination else None,
        "ai_selected_city_en": selected_city["name_en"],
        "ai_selected_city_ar": selected_city["name_ar"],
        "budget_level": user_budget_level,
        "activities_used_by_ai": user_activities,
        "recommended_hotels": hotel_list,
        "itinerary": itinerary,
        "final_text": final_text,
    }


def recommendation_flow(language_mode):
    print("\n--- AI Travel Planner Form ---")
    print("Leave destination empty if you want the AI to recommend one.")
    destination = input("Country / Destination: ").strip()
    budget_usd = input("Budget (USD): ").strip()
    duration_days = input("Duration (days): ").strip()
    
    print("\nAvailable Interests:")
    for key in interest_map.keys():
        print(f"  - {key}")
    print("\nExample: Beach & Relaxation, Shopping")
    interests_text = input("Interests: ").strip()
    
    selected_interests = [x.strip() for x in interests_text.split(",") if x.strip()]
    
    user_budget_level = budget_usd_to_level(budget_usd)
    user_activities = convert_interests_to_activities(selected_interests)
    
    try:
        user_duration = int(duration_days)
    except ValueError:
        user_duration = 3
        
    selected_city = find_city_by_destination(destination)
    match_score = None
    user_selected = False
    
    if selected_city is None:
        if destination.strip():
            error_ar = f"عذراً، الوجهة '{destination}' غير متوفرة في قاعدة بياناتنا حالياً. يرجى ترك الخانة فارغة ليقترح الذكاء الاصطناعي وجهة بديلة، أو اختر مدينة أخرى."
            error_en = f"Sorry, the destination '{destination}' is not available in our database. Please leave the field empty for an AI recommendation, or choose another city."
            return error_ar if language_mode == "ar" else error_en
            
        selected_city, raw_score = recommend_city(user_activities, user_budget_level, user_duration)
        match_score = min(100.0, (raw_score / 1.2) * 100)
    else:
        user_selected = True
        
    hotel_list = recommend_hotels(selected_city["name_en"], user_activities, user_budget_level, user_duration)
    itinerary = generate_itinerary(selected_city["name_en"], user_activities, user_budget_level, user_duration)
    
    return build_recommendation_response(selected_city, hotel_list, itinerary, language_mode, match_score, user_selected)


def main():
    setup_console()
    intents_data = load_intents()
    matcher = IntentMatcher(intents_data)

    print("=" * 60)
    print("Sufar Smart Travel Assistant - Improved")
    print("=" * 60)

    print("\nType:")
    print("- recommend / توصية  -> full city + hotel + itinerary recommendation")
    print("- any normal message from your intents file")
    print("- quit / خروج       -> exit\n")

    # You can change this threshold to make the AI stricter or more lenient (e.g. 0.30 for 30%)
    ACCURACY_THRESHOLD = 0.20

    while True:
        user_text = input("You: ").strip()

        if user_text.lower() in {"quit", "exit", "خروج"}:
            print("Bye 👋")
            break

        # Auto-detect language: if it contains Arabic characters, reply in Arabic
        if any('\u0600' <= ch <= '\u06FF' for ch in user_text):
            language_mode = "ar"
        else:
            language_mode = "en"

        if user_text.lower() in {"recommend", "توصية"}:
            response = recommendation_flow(language_mode)
            print("\n" + fix_arabic_text(response) + "\n")
            continue

        tag, score = matcher.predict_intent(user_text, threshold=ACCURACY_THRESHOLD)
        
        # Display Accuracy as percentage
        accuracy_percent = score * 100
        
        if tag is None:
            fallback = {
                "ar": f"لم أفهم الطلب بالكامل (الدقة: {accuracy_percent:.1f}%). اكتب 'توصية' لو تريد اقتراح رحلة كاملة.",
                "en": f"I did not fully understand the request (Accuracy: {accuracy_percent:.1f}%). Type 'recommend' for a full trip recommendation."
            }
            print("\n" + fix_arabic_text(fallback.get(language_mode, fallback["en"])) + "\n")
            continue

        print(f"\nIntent: {tag} | Accuracy: {accuracy_percent:.1f}%\n")
        print(fix_arabic_text(matcher.get_response(tag, language_mode)))
        print()


if __name__ == "__main__":
    main()
