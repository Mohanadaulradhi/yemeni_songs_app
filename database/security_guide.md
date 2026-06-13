# دليل الأمان — تطبيق الأغاني اليمنية

## 1. تخزين المفاتيح السرية (API Keys)

### في Flutter (Client-side):

```
❌ خطأ: كتابة API Keys داخل الكود
const apiKey = 'sk-12345';  // مكشوف في الـ Binary

✅ صحيح: استخدام flutter_dotenv
APPWRITE_ENDPOINT=https://your-server.appwrite.io/v1
APPWRITE_PROJECT_ID=abc123
```

### تنبيه مهم:
- `flutter_dotenv` **لا يُخفي** المفاتيح نهائيًا — أي شخص يمكنه فك APK وقراءة `.env`
- الحل الحقيقي: استخدم **Appwrite Cloud Functions** للعمليات الحساسة
- Appwrite نفسه يدير الـ JWT tokens بدون تعريض API Key للـ Client

### استخدام `--dart-define` (للمفاتيح الحساسة جدًا):
```bash
flutter run --dart-define=APPWRITE_ENDPOINT=...
```

ثم في الكود:
```dart
static String get endpoint =>
    const String.fromEnvironment('APPWRITE_ENDPOINT');
```

## 2. أمان المحتوى المميز (Premium Content)

### القاعدة الذهبية:
```
❌ لا تعتمد على جانب العميل أبدًا
if (user.isPremium) showContent();  // يمكن تزويره

✅ تحقق من الخادم دائمًا
Server: تحقق من تاريخ انتهاء الاشتراك قبل إرسال المحتوى
```

### تدفق التحقق:

```
1. مستخدم يطلب أغنية Premium
2. App sends request مع JWT token
3. Appwrite Function:
   a. تحقق من صحة الـ JWT
   b. ابحث عن user.subscriptionExpiry
   c. إذا expired → ارفض الطلب
   d. إذا صالح → أرسل رابط التحميل
4. التطبيق يشغل المحتوى
```

### للتخزين المحلي (Offline Premium):
- المحتوى المنزل مشفر على الجهاز باستخدام `encrypt` package أو `flutter_secure_storage`
- عند انتهاء الاشتراك → حذف المحتوى المنزل الخاص بالمشتركين

## 3. أمان الدفع (Payment Security)

### المخاطر:
- اعتراض طلب الدفع (Man-in-the-Middle)
- إعادة استخدام Transaction ID
- فشل الـ Callback

### الحلول:

```dart
// 1. HTTPS إجباري
_dio = Dio(BaseOptions(
  baseUrl: dotenv.env['KURAIMI_BASE_URL'],
))..interceptors.add(LogInterceptor());  // للـ Debug فقط

// 2. Unique Transaction ID لكل محاولة
final txId = '${userId}_${DateTime.now().millisecondsSinceEpoch}';

// 3. التحقق من المبلغ قبل التفعيل
if (payment.amount != plan.price) {
  throw Exception('مبلغ غير متطابق');
}

// 4. مهلة زمنية للـ Callback (3 دقائق)
Timer(const Duration(minutes: 3), () {
  if (status == 'pending') {
    markAsFailed(txId);
  }
});
```

## 4. أمان قاعدة البيانات (Appwrite)

### الأذونات (Permissions):

| Collection | Read | Write | Notes |
|------------|------|-------|-------|
| `songs` | أي مستخدم | Admin فقط | المحتوى العام متاح للجميع |
| `users` | المستخدم نفسه | المستخدم + Admin | لا يمكن قراءة بيانات مستخدم آخر |
| `payments` | Admin | Admin | سجل الدفع خاص |
| `subscriptions` | أي مستخدم | Admin | الخطط متاحة للعرض |

### قواعد الأمان في Appwrite:

```json
// مثال: قاعدة أمان للـ songs collection
{
  "read": ["role:all"],
  "write": ["role:admin"],
  "create": ["role:admin"],
  "delete": ["role:admin"]
}

// مثال: قاعدة أمان للـ users collection
{
  "read": ["user:\$id"],
  "write": ["user:\$id", "role:admin"]
}
```

## 5. حماية الـ API

### معدل الطلبات (Rate Limiting):
- Appwrite يدعم Rate Limiting مدمج
- الحد الأقصى: 60 طلب/دقيقة للمستخدم العادي
- 200 طلب/دقيقة للمشتركين

### التحقق من صحة الـ JWT:
- مدة صلاحية الـ JWT: ساعة واحدة
- يتم تجديدها تلقائيًا عند انتهائها
- في حالة logout: إلغاء جميع Sessions

## 6. Check-List الأمان قبل الإطلاق

- [ ] كل طلبات الشبكة → HTTPS فقط
- [ ] `.env` في `.gitignore`
- [ ] إعدادات CORS في Appwrite
- [ ] Rate Limiting مفعل
- [ ] أذونات Appwrite Collections صحيحة
- [ ] التحقق من صحة Premium على الخادم
- [ ] تشفير المحتوى المنزل (اختياري للمرحلة الأولى)
- [ ] مهلة زمنية للدفع (3 دقائق)
- [ ] Logging للأخطاء بدون كشف البيانات الحساسة
- [ ] اختبار اختراق أساسي
