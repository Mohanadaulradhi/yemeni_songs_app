# وحدة الكاريوكي — التصميم والتحليل (V2)

## 1. تحديات الكاريوكي

| التحدي | الوصف | الحل المقترح |
|--------|-------|-------------|
| **المزامنة الدقيقة** | يجب أن تتزامن الكلمات مع الصوت بدقة millisecond | تنسيق LRC مع Timestamps |
| **التمرير التلقائي** | التمرير يجب أن يتبع الصوت، وليس تفاعل المستخدم | ScrollController + Timer |
| **اتجاه RTL** | اللغة العربية تُكتب من اليمين لليسار | TextDirection.rtl + محاذاة خاصة |
| **تعدد الأصوات** | أغاني يمنية قد تحتوي على مقاطع chorus متكررة | بنية LRC مع أقسام متكررة |
| **إدخال البيانات** | فريق غير تقني يحتاج إضافة كلمات بسهولة | أداة بسيطة لرفع ملفات .lrc |

## 2. تنسيق LRC المقترح

ملف `.lrc` هو تنسيق نصي بسيط مع طوابع زمنية:

```
[00:00.00]يا ليل يا عين
[00:04.50]يا ليل يا عين
[00:08.20]على فرقاك أنا حزين
[00:12.80]واشكي لك همي وحنين
[00:18.00]يا ليل
```

- `[mm:ss.xx]` → دقيقة:ثانية.جزء من الثانية
- سطر واحد لكل عبارة
- ملف الترجمة يوضع في Bucket: `lyrics_files`

## 3. هيكل قاعدة البيانات

### Collection: `lyrics`
| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `songId` | string | ✅ | المفتاح الخارجي للأغنية |
| `content` | string | ✅ | نص LRC الكامل |
| `language` | string | ❌ | اللغة (default: ar) |
| `version` | integer | ❌ | رقم الإصدار (default: 1) |
| `timestampsMs` | string[] | ❌ | [مستقبلي] array من الـ Milliseconds |

## 4. معمارية التشغيل (Player + LRC)

```
┌─────────────────────────────────────────────────┐
│                 KaraokePlayer                   │
├─────────────────────────────────────────────────┤
│  AudioPlayer (just_audio)                       │
│       └── positionStream (كل 100ms)             │
│  LyricsParser (LRC → List<LyricLine>)           │
│       └── parse(String) → List<LyricLine>       │
│  LyricLine { timestampMs, text }               │
│  ScrollController (auto-scroll)                 │
│       └── animateTo(currentLine * lineHeight)   │
└─────────────────────────────────────────────────┘
```

### تدفق التشغيل:

1. المستخدم يفتح أغنية → تحقق من وجود `lyrics` في البيانات
2. إذا وجدت:
   - اسحب ملف LRC من `lyrics_files` Bucket
   - اعرض الكلمات كاملة
3. عند التشغيل:
   - `AudioPlayer.positionStream` يرسل التحديثات كل 100ms
   - `LyricsParser.getCurrentLineIndex(position)` يحدد السطر الحالي
   - Highlight السطر الحالي + تمرير تلقائي

## 5. مكون Flutter المقترح

```dart
// lib/widgets/karaoke_lyrics_widget.dart
class KaraokeLyricsWidget extends StatefulWidget {
  final String lyricsContent;  // نص LRC كامل
  final Stream<Duration> positionStream;

  const KaraokeLyricsWidget({
    required this.lyricsContent,
    required this.positionStream,
  });
}

class _LyricLine {
  final int timestampMs;
  final String text;
  
  _LyricLine(this.timestampMs, this.text);
}
```

### المنطق:
- `lyricsContent` مخزن في `SongModel.lyrics`
- `positionStream` من `just_audio` AudioPlayer
- Highlight للكلمة الحالية بلون ذهبي/أخضر
- تمرير تلقائي إلى السطر التالي

## 6. خطة التنفيذ (V2)

| المرحلة | المدة | المخرجات |
|---------|-------|---------|
| **V2.1** | أسبوع 1 | LRC Parser + عرض نص متزامن |
| **V2.2** | أسبوع 2 | Highlight + Auto-scroll |
| **V2.3** | أسبوع 3 | اختبارات + أداء + RTL fixes |

## 7. ملاحظات تقنية

- **لا تُستخدم `Timer` للمزامنة** — استخدم `positionStream` من just_audio مباشرة
- **الأداء**: LRC files صغيرة (< 10KB)، لا مشكلة أداء
- **التخزين المؤقت**: خزّن LRC في Hive عند أول تحميل للتشغيل الأوفلاين
- **الرجوع للخلف**: عند السحب (seek)، يعاد حساب السطر الحالي من الموقع الجديد
