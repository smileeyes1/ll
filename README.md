# Ω Project Autonomy & Assurance System v2.0

نظام تشغيل عام للمشاريع مستقل عن المحادثة، قائم على مصدر حقيقة خارجي، حالة قابلة للاستئناف، أدلة قابلة للتحقق، اختبارات، بدائل، وRelease Gate.

## المبدأ
المحادثة ليست ذاكرة المشروع. المشروع يجب أن يستطيع إعادة بناء سياقه من ملفات SPEC وSTATE وDECISIONS وEVIDENCE وTESTS وRUNBOOK.

## دورة التشغيل
UNDERSTAND → SPEC → CAPABILITY CHECK → PLAN → EXECUTE → CHECKPOINT → TEST → ADVERSARIAL TEST → REPAIR → REGRESSION → VERIFY ARTIFACT → RELEASE GATE → GO/NO-GO → UPDATE STATE.

## قواعد صارمة
- لا يُعتمد أي ادعاء نجاح دون دليل.
- لا تُعتمد أداة قبل اختبار القدرة المطلوبة فعليًا.
- لا تعتمد الاستمرارية على ChatGPT أو أي جلسة واحدة.
- لا تتوقف عند فشل مسار؛ شخّص ثم استخدم البديل أو المسار المحلي.
- لا تُعاد مهمة ثبت نجاحها إلا إذا تغير مدخلها أو ظهرت أدلة تنقض صحتها.
- GO يحتاج نسخة/commit محددًا، اختبارات ناجحة، Regression، artifact، Evidence، وعدم وجود blocker عالي التأثير.

## الملفات الأساسية
- `SPEC.md` — الغاية ومعايير القبول.
- `STATE.md` — آخر حالة قابلة للاستئناف.
- `DECISIONS.md` — القرارات الثابتة وأسبابها.
- `CAPABILITIES.md` — الأدوات والقدرات التي تم التحقق منها.
- `EVIDENCE.md` — سجل الأدلة.
- `RUNBOOK.md` — طريقة الاستئناف والتشغيل.
- `CHANGELOG.md` — تاريخ التغييرات.
- `scripts/health-check.sh` — فحص صحة المشروع.
- `tests/` — اختبارات بنيوية وعدائية.
- `.github/workflows/assurance.yml` — تحقق آلي عند كل تغيير.

## الاستمرارية
الأساس هو Git + GitHub + GitHub Actions، مع تشغيل محلي كمسار بديل. GitHub Actions مجاني على الـ runners القياسية للمستودعات العامة، ويملك GitHub Free حاليًا حصة 2000 دقيقة شهريًا للمستودعات الخاصة؛ لذلك لا يعتمد النظام على خدمة مدفوعة أو runner خاص. 

## حالة الإصدار
INITIALIZED — يحتاج أول تشغيل تحقق آلي قبل إعلان GO.
