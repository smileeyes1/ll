# RUNBOOK — تشغيل واستئناف

## تشغيل محلي
```bash
bash scripts/health-check.sh
bash tests/test-structure.sh
bash tests/test-adversarial.sh
```

## الاستئناف بعد انقطاع المحادثة
1. افتح المستودع.
2. اقرأ `SPEC.md` ثم `STATE.md` ثم `DECISIONS.md` ثم `CAPABILITIES.md` ثم `EVIDENCE.md`.
3. افحص آخر commit.
4. شغّل Health Check محليًا إن أمكن.
5. افحص آخر GitHub Actions Run.
6. لا تعِد ما هو VERIFIED.
7. نفّذ `NEXT_ACTION`.
8. حدّث STATE وEVIDENCE في نفس التغيير.

## عند فشل أداة
DIAGNOSE → PRESERVE EVIDENCE → IDENTIFY LAST KNOWN GOOD → TRY SAFE RETRY → SWITCH TO VERIFIED ALTERNATIVE → LOCAL FALLBACK → RECORD STATE.

## عند فشل الاختبار
لا تحذف الدليل. حدّد سبب الفشل، أصلح أصغر جزء ممكن، أعد الاختبار، ثم Regression.

## Checkpoint policy
كل تغيير منطقي يجب أن ينتهي بcommit صغير قابل للرجوع.

## Release Gate
GO = health + normal tests + adversarial tests + regression + artifact + evidence + fixed commit + no high-impact blocker.
CONDITIONAL GO = كل ما سبق مع استثناء موثق ومخاطر مقبولة صراحة.
NO-GO = أي شرط جوهري مفقود.

## استمرارية خارج المحادثة
GitHub repository هو المصدر الخارجي. GitHub Actions يشغل التحقق تلقائيًا عند push وpull request وبشكل مجدول. التشغيل المحلي يبقى fallback.
