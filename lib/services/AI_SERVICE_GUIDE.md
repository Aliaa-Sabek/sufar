# AI Service Integration Guide

خدمة الذكاء الاصطناعي لتطبيق Sufar الآن متصلة بـ `https://sufar-production.up.railway.app`

## ✅ ما تم إعداده

### 1. **AppConfig** (`lib/config/app_config.dart`)
- تم إضافة `aiServiceUrl` property
- يدعم البيئات المختلفة (محلي، إنتاجي)
- يدعم `--dart-define=AI_SERVICE_URL=...` للتخصيص

### 2. **AIService** (`lib/services/ai_service.dart`)
خدمة متخصصة توفر:
- ✅ `getRecommendation()` - توصيات السفر
- ✅ `chat()` - محادثة مع مساعد السفر
- ✅ `getVisaInfo()` - معلومات التأشيرات
- ✅ `isAvailable()` - فحص توفر الخدمة

### 3. **AI Planner Screen** (`lib/ai_planner/ai_planner_screen.dart`)
تم تحديثها لاستخدام `AIService` بدلاً من الاتصالات المباشرة

## 🚀 الاستخدام

### في أي شاشة:
```dart
import '../services/ai_service.dart';

// الحصول على توصيات السفر
try {
  final recommendation = await AIService.getRecommendation(
    destination: 'Cairo',
    budget: '1500',
    duration: '5',
    interests: ['Culture', 'Food'],
    language: 'en',
  );
  
  print(recommendation['ai_selected_city_en']);
  print(recommendation['recommended_hotels']);
  print(recommendation['itinerary']);
} catch (e) {
  print('Error: $e');
}
```

### التحدث مع مساعد السفر:
```dart
final chatResponse = await AIService.chat(
  message: 'What are the best hotels in Cairo?',
  language: 'en',
);

print(chatResponse['reply']);
```

### الحصول على معلومات التأشيرات:
```dart
final visaInfo = await AIService.getVisaInfo(
  destination: 'France',
  nationality: 'Egypt',
  language: 'ar',
);

print(visaInfo['requirements']);
```

### فحص توفر الخدمة:
```dart
final isAvailable = await AIService.isAvailable();
if (isAvailable) {
  print('AI Service is online ✅');
} else {
  print('AI Service is offline ❌');
}
```

## 🔧 التخصيص

### تعديل URL الخدمة:

**1. محليًا (للتطوير):**
```bash
flutter run \
  --dart-define=AI_SERVICE_URL=http://localhost:5000
```

**2. للإنتاج:**
```bash
flutter run \
  --dart-define=AI_SERVICE_URL=https://sufar-production.up.railway.app
```

**3. للأجهزة الحقيقية على نفس الشبكة:**
```bash
flutter run \
  --dart-define=AI_SERVICE_URL=http://192.168.1.100:5000
```

## 📡 نقاط النهاية (Endpoints)

| النقطة | الطريقة | الوصف |
|------|--------|-------|
| `/api/recommend` | POST | الحصول على توصيات السفر |
| `/api/chat` | POST | محادثة مع المساعد |
| `/api/visa` | POST | معلومات التأشيرات |
| `/health` | GET | فحص حالة الخدمة |

## 🐛 استكشاف الأخطاء

### خطأ الاتصال:
```
Connection error: Failed host lookup
```
✅ **الحل:** تحقق من:
- اتصال الإنترنت
- صحة عنوان URL
- حالة الخادم

### Timeout:
```
Error: Connection timed out
```
✅ **الحل:** 
- زيادة timeout إذا كانت الشبكة بطيئة
- التحقق من سرعة الخادم

### خطأ 500:
```
AI Service error (500): Internal Server Error
```
✅ **الحل:** راجع سجلات الخادم

## 📋 المتطلبات

- HTTP package: `http: ^1.1.0` (موجود بالفعل)
- AppConfig configuration صحيح

## ✨ الميزات الإضافية

- ✅ معالجة الأخطاء التلقائية
- ✅ دعم اللغات (إنجليزي/عربي)
- ✅ Timeout protection
- ✅ بنية الكود نظيفة وقابلة للتوسع

---

**للمزيد من المساعدة:** تواصل مع فريق التطوير
