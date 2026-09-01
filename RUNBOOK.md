# RUNBOOK — تشغيل واستئناف القيادة الذاتية

## دورة التشغيل
1. اقرأ `AUTONOMY_CONSTITUTION.md`, `INTENT.md`, `SPEC.md`, `STATE.md`, `DECISIONS.md`, `CAPABILITIES.md`, `EVIDENCE.md`.
2. شغّل `swarm/autopilot/leadership-core.py` وأنشئ قرار القيادة.
3. إذا القرار `PROCEED`: حوّل فجوات النية إلى Tasks ثم شغّل NBAG.
4. نفّذ مهمة واحدة محددة فقط، ثم تحقق مستقلًا واختبر Regression/Adversarial.
5. عند الفشل: Evidence → Diagnose → bounded retry → repair → fallback/failover → re-evaluate.
6. شغّل Continuation Controller.
7. إذا `CONTINUE`: Commit checkpoint ثم أطلق Autopilot التالي فورًا.
8. إذا `TERMINAL_CANDIDATE`: شغّل بوابات النهاية والإصدار ولا تخترع مهمة جديدة.
9. إذا `SAFE_BLOCKED`: احفظ الدليل والسبب ولا تدّع الإنجاز.

## أسئلة القيادة الإلزامية
الغاية؛ النتيجة النهائية؛ معيار النجاح؛ الحقائق؛ المجهولات؛ القيود؛ الصلاحيات؛ القدرات؛ الاختناق؛ المخاطر؛ التبعيات؛ قابلية الرجوع؛ خطة الدليل؛ البدائل؛ التعامل مع الفشل؛ ضرورة الإنسان؛ وآلية التوقف. تُضاف أسئلة تخصصية تلقائيًا حسب نوع المهمة.

## تشغيل محلي
```bash
python3 swarm/autopilot/leadership-core.py
python3 swarm/autopilot/intent-compiler.py
python3 swarm/autopilot/nbag.py
bash scripts/health-check.sh
bash tests/test-structure.sh
bash tests/test-leadership.sh
bash tests/test-intent-gate.sh
bash tests/test-nbag.sh
bash tests/test-continuation.sh
bash tests/test-adversarial.sh
```

## الاستئناف بعد انقطاع المحادثة أو الهاتف
GitHub هو مصدر الحقيقة. لا تعتمد على ذاكرة المحادثة. ابدأ من آخر commit وحالة `STATE.md` وملفات القرار في `ops/`، ثم أعد Leadership Gate. لا تعِد عملًا VERIFIED إلا إذا تغيرت المدخلات أو ظهرت أدلة مناقضة.

## عند فشل أداة
DIAGNOSE → PRESERVE EVIDENCE → IDENTIFY LAST KNOWN GOOD → SAFE RETRY → VERIFIED ALTERNATIVE → LOCAL FALLBACK → FAILOVER → RECORD STATE → RE-EVALUATE LEADERSHIP/NBAG.

## عند فشل الاختبار
لا تحذف الدليل ولا تعطل الاختبار. أصلح أصغر جزء ممكن، أعد الاختبار، ثم Regression. إذا استنفدت الميزانية يصبح SAFE_BLOCKED بدل حلقة لا نهائية.

## سياسة تدخل الإنسان
لا سؤال إذا أمكن الاستنتاج الآمن أو افتراض قابل للعكس. `HUMAN_REQUIRED` فقط لسلطة لازمة، سر/اعتماد غير متاح، تفضيل جوهري لا يمكن استنتاجه، أو فعل عالي الأثر غير قابل للعكس بلا تفويض.

## Checkpoint policy
كل تغيير منطقي ينتهي بcommit صغير قابل للرجوع، مع قرار القيادة وNBAG ونتيجة التنفيذ/الاختبارات قدر الإمكان.

## Release Gate
GO = leadership + health + normal tests + adversarial + regression + artifact/evidence عند انطباقه + fixed commit + no high-impact blocker + smoke test عند النشر.
CONDITIONAL GO = استثناء موثق لا يمس شرط قبول أو أمان جوهري.
NO-GO = أي شرط جوهري مفقود.

## الاستمرارية
Autopilot يستخدم self-chain المباشر عند وجود عمل قابل للتنفيذ، والجدول/Watchdog شبكة أمان فقط. لا يتوقف المسار الطبيعي بين المهام منتظرًا المحادثة.
