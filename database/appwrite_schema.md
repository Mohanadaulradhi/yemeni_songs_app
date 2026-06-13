# مخطط قاعدة بيانات Appwrite - تطبيق الأغاني اليمنية

## الإعدادات المسبقة
- **Database ID**: `default`
- **الموقع**: Self-hosted أو Appwrite Cloud

---

## 1. Collection: `users`
| Attribute | Type | Required | Notes |
|-----------|------|----------|-------|
| `email` | string | ✅ | فريد |
| `name` | string | ✅ | |
| `phone` | string | ❌ | |
| `subscriptionId` | string | ❌ | رابط لخطة الاشتراك |
| `subscriptionExpiry` | datetime | ❌ | تاريخ انتهاء الاشتراك |
| `isAdmin` | boolean | ❌ | default: false |
| `createdAt` | datetime | ✅ | تلقائي |

### Indexes
- `email` (unique)

---

## 2. Collection: `songs`
| Attribute | Type | Required | Notes |
|-----------|------|----------|-------|
| `title` | string | ✅ | |
| `artistId` | string | ✅ | Key: artists collection |
| `artistName` | string | ✅ | Denormalized للسرعة |
| `album` | string | ❌ | |
| `genre` | string | ✅ | enum: صنعاني, عدني, حضرمي, ... |
| `audioUrl` | string | ✅ | رابط ملف الصوت في Storage |
| `videoUrl` | string | ❌ | رابط الفيديو (للمشتركين) |
| `imageUrl` | string | ❌ | صورة الأغنية |
| `lyrics` | string | ❌ | نص الكلمات |
| `durationSeconds` | integer | ❌ | المدة بالثواني |
| `isPremium` | boolean | ❌ | default: false |
| `isVideo` | boolean | ❌ | default: false |
| `playCount` | integer | ❌ | default: 0 |
| `createdAt` | datetime | ✅ | تلقائي |

### Indexes
- `genre` (key)
- `artistId` (key)

---

## 3. Collection: `artists`
| Attribute | Type | Required | Notes |
|-----------|------|----------|-------|
| `name` | string | ✅ | |
| `bio` | string | ❌ | نبذة عن الفنان |
| `imageUrl` | string | ❌ | صورة الفنان |
| `genre` | string | ❌ | تخصص الفنان |
| `songCount` | integer | ❌ | عدد الأغاني (يجدد تلقائيًا) |
| `createdAt` | datetime | ✅ | تلقائي |

---

## 4. Collection: `subscriptions` (خطط الاشتراك)
| Attribute | Type | Required | Notes |
|-----------|------|----------|-------|
| `name` | string | ✅ | مجاني, أساسي, مميز |
| `description` | string | ❌ | |
| `price` | double | ✅ | بالريال اليمني |
| `durationDays` | integer | ✅ | 0 = مجاني, 30 = شهري |
| `tier` | string | ✅ | free, basic, premium |
| `features` | string[] | ❌ | قائمة الميزات |
| `isActive` | boolean | ❌ | default: true |
| `currency` | string | ❌ | default: YER |

---

## 5. Collection: `payments`
| Attribute | Type | Required | Notes |
|-----------|------|----------|-------|
| `userId` | string | ✅ | Key: users |
| `subscriptionPlanId` | string | ✅ | Key: subscriptions |
| `amount` | double | ✅ | |
| `currency` | string | ❌ | default: YER |
| `gateway` | string | ✅ | kuraimi, jib, jawali, hasab |
| `status` | string | ✅ | pending, processing, completed, failed |
| `transactionId` | string | ❌ | من البوابة |
| `gatewayReference` | string | ❌ | مرجع البوابة |
| `paidAt` | datetime | ❌ | |
| `createdAt` | datetime | ✅ | تلقائي |

### Indexes
- `userId` (key)
- `status` (key)

---

## 6. Collection: `lyrics` (للإصدار المستقبلي - كاريوكي)
| Attribute | Type | Required | Notes |
|-----------|------|----------|-------|
| `songId` | string | ✅ | Key: songs |
| `content` | string | ✅ | نص بتنسيق LRC [mm:ss.xx]كلمات |
| `language` | string | ❌ | default: ar |
| `version` | integer | ❌ | default: 1 |

---

## 7. Storage Buckets

### Bucket: `media`
- معرف الـ Bucket: `media`
- الملفات المسموحة: `mp3, wav, ogg, mp4, jpg, png, webp, lrc, txt, json`
- الحد الأقصى: 100MB
- الصلاحيات: قراءة عامة (Public Read) وكتابة عامة (Public Write) لإتاحة الرفع من لوحة التحكم.

---

## ملاحظات معمارية مهمة

1. **Denormalization متعمد**: نكرر `artistName` داخل كل أغنية لتجنب JOINs المكلفة
2. **لا توجد علاقات (Relationships)**: Appwrite لا يدعم العلاقات المباشرة. نستخدم Keys مبدئيًا
3. **الترقية**: عندما يكبر المشروع، ننتقل إلى Node.js + PostgreSQL مع Appwrite للـ Auth فقط
4. **الأوفلاين**: بيانات الأوفلاين مخزنة في Hive (JSON)، وليس في Appwrite
5. **الأمان**: كل الوصول للمحتوى المميز (Premium) يتم التحقق منه عبر Appwrite Functions
