#!/usr/bin/env python3
"""Ω Autonomous Leadership Kernel.

Builds an auditable pre-execution leadership decision from durable repository
state. It does not expose private chain-of-thought; it records the operational
questions, evidence sources, unresolved constraints and decision gates needed
for safe autonomous execution.
"""
from __future__ import annotations
import json, os, re
from datetime import datetime, timezone
from pathlib import Path

DEFAULT_ROOT = Path(__file__).resolve().parents[2]
ROOT = Path(os.environ.get("OMEGA_ROOT", str(DEFAULT_ROOT))).resolve()
OUT = ROOT / "swarm/autopilot/leadership-decision.json"

CORE_FILES = [
    "AUTONOMY_CONSTITUTION.md", "INTENT.md", "SPEC.md", "STATE.md",
    "DECISIONS.md", "CAPABILITIES.md", "EVIDENCE.md", "RUNBOOK.md",
    "swarm/autopilot/task-queue.json",
]

def text(path: str) -> str:
    p = ROOT / path
    return p.read_text(encoding="utf-8") if p.is_file() else ""

def section(doc: str, heading: str) -> str:
    m = re.search(rf"^##\s+{re.escape(heading)}\s*$", doc, re.M | re.I)
    if not m:
        return ""
    rest = doc[m.end():]
    n = re.search(r"^##\s+", rest, re.M)
    return rest[:n.start()].strip() if n else rest.strip()

def field(doc: str, name: str) -> str:
    m = re.search(rf"^{re.escape(name)}:\s*(.+)$", doc, re.M | re.I)
    return m.group(1).strip() if m else ""

def compact(s: str, limit: int = 700) -> str:
    s = re.sub(r"\s+", " ", s).strip()
    return s[:limit]

missing = [f for f in CORE_FILES if not (ROOT / f).is_file() or (ROOT / f).stat().st_size == 0]
intent = text("INTENT.md")
spec = text("SPEC.md")
state = text("STATE.md")
decisions = text("DECISIONS.md")
caps = text("CAPABILITIES.md")
evidence = text("EVIDENCE.md")
runbook = text("RUNBOOK.md")
constitution = text("AUTONOMY_CONSTITUTION.md")
queue_path = ROOT / "swarm/autopilot/task-queue.json"
queue = json.loads(queue_path.read_text(encoding="utf-8")) if queue_path.is_file() else {"tasks": []}
tasks = queue.get("tasks", [])
done = {t.get("id") for t in tasks if t.get("status") == "completed"}
executable = [t for t in tasks if t.get("status") == "pending" and all(d in done for d in t.get("depends_on", []))]
failed = [t for t in tasks if t.get("status") == "failed"]
human_tasks = [t for t in executable if t.get("requires_human") is True]

intent_body = section(intent, "Intent")
required_outcome = section(intent, "Required outcome")
acceptance = section(spec, "معايير القبول") or section(spec, "Acceptance Criteria")
constraints = section(spec, "غير النطاق") or section(spec, "Out of scope")
state_status = field(state, "STATUS") or "UNKNOWN"
blocker = field(state, "BLOCKER") or "UNDECLARED"
current_task = field(state, "CURRENT_TASK") or "UNDECLARED"
next_action = field(state, "NEXT_ACTION") or "UNDECLARED"

unknown_caps = []
for line in caps.splitlines():
    if re.search(r"UNVERIFIED|TIME-PENDING|NOT YET|AVAILABLE", line, re.I):
        unknown_caps.append(line.strip())

questions: list[dict] = []
def ask(key: str, question: str, answer: str, status: str, source: str, critical: bool = False):
    questions.append({
        "key": key, "question": question, "answer": compact(answer),
        "status": status, "source": source, "critical": critical,
    })

ask("goal", "ما الغاية الحقيقية المطلوب تحقيقها؟", intent_body or "غير محددة", "ANSWERED" if intent_body else "UNRESOLVED", "INTENT.md", True)
ask("final_outcome", "ما النتيجة النهائية المطلوبة لا مجرد الخطوة التالية؟", required_outcome or acceptance or "غير محددة", "ANSWERED" if (required_outcome or acceptance) else "UNRESOLVED", "INTENT.md/SPEC.md", True)
ask("success", "كيف نثبت أن المهمة نجحت فعليًا؟", acceptance or "بوابة النية والدليل والإصدار هي معيار النجاح", "ANSWERED", "SPEC.md/AUTONOMY_CONSTITUTION.md", True)
ask("facts", "ما الحقائق المثبتة التي يمكن البناء عليها؟", f"state={state_status}; completed_tasks={len(done)}; evidence_file={'present' if evidence else 'missing'}", "ANSWERED", "STATE.md/EVIDENCE.md")
ask("unknowns", "ما الذي ما زال مجهولًا أو غير متحقق منه؟", "; ".join(unknown_caps[:8]) or "لا توجد قدرات غير متحققة مسجلة", "ANSWERED", "CAPABILITIES.md")
ask("constraints", "ما القيود وحدود النطاق والسلطة؟", constraints or "العمل ضمن الصلاحيات الحالية؛ لا توسيع صلاحيات ولا تجاوز بوابات الأمن/الإصدار", "ANSWERED", "SPEC.md/AUTONOMY_CONSTITUTION.md", True)
ask("capabilities", "ما القدرات المثبتة المتاحة الآن؟", compact(caps, 900), "ANSWERED" if caps else "UNRESOLVED", "CAPABILITIES.md", True)
ask("bottleneck", "ما الاختناق أو العائق الأعلى أثرًا الآن؟", f"BLOCKER={blocker}; failed_tasks={len(failed)}; current_task={current_task}", "ANSWERED", "STATE.md/task-queue.json")
ask("dependencies", "ما التبعيات التي يجب تحققها قبل التنفيذ؟", f"executable_tasks={len(executable)}; pending_dependencies are enforced by task queue", "ANSWERED", "task-queue.json")
ask("risk", "ما المخاطر الأعلى أثرًا وكيف نحدها؟", "تلف الحالة، النجاح الوهمي، حلقات التكرار، الصلاحيات الزائدة، وفشل المسار؛ تخفف بالـEvidence وRegression وRecovery وRelease Gate", "ANSWERED", "AUTONOMY_CONSTITUTION.md/RUNBOOK.md")
ask("reversibility", "هل الإجراء التالي قابل للعكس؟", "تغييرات المستودع يجب أن تكون commits صغيرة قابلة للرجوع؛ الإجراءات الخارجية غير القابلة للعكس تحتاج تفويضًا صريحًا أو بوابة أمان", "ANSWERED", "RUNBOOK.md/AUTONOMY_CONSTITUTION.md")
ask("evidence_plan", "ما الدليل المطلوب قبل اعتبار النجاح؟", "اختبار فعلي + Evidence + commit ثابت + artifact/تشغيل عند انطباقه؛ لا يكفي وجود الإعداد", "ANSWERED", "EVIDENCE.md/SPEC.md", True)
ask("alternatives", "ما البديل إذا فشل المسار الأساسي؟", "تشخيص ثم إصلاح ثم إعادة اختبار ثم بديل VERIFIED ثم local fallback ثم SAFE_BLOCKED إذا استنفدت البدائل", "ANSWERED", "RUNBOOK.md/DECISIONS.md")
ask("failure", "ماذا نفعل عند الفشل أو timeout؟", "نحفظ الدليل، نطبق retry budget، نستخدم Recovery/Failover، نعيد NBAG ولا ندعي النجاح", "ANSWERED", "AUTONOMY_CONSTITUTION.md")
ask("human", "هل تدخل الإنسان ضروري فعلًا؟", "نعم" if human_tasks else "لا توجد مهمة تنفيذية موسومة requires_human=true", "REQUIRES_HUMAN" if human_tasks else "ANSWERED", "task-queue.json", bool(human_tasks))
ask("next_action", "ما آلية اختيار أفضل إجراء تالٍ؟", "Ω NBAG بعد نجاح بوابة القيادة؛ لا اختيار بحسب ترتيب الطابور فقط", "ANSWERED", "swarm/autopilot/nbag.py", True)
ask("stop", "متى يجب أن نستمر ومتى نتوقف؟", "نستمر حتى INTENT_ACHIEVED/RELEASED بدليل، أو SAFE_BLOCKED حقيقي موثق", "ANSWERED", "AUTONOMY_CONSTITUTION.md", True)

combined = "\n".join([intent, spec]).lower()
def pack(trigger_terms, name, items):
    if any(term in combined for term in trigger_terms):
        for key, q, a in items:
            ask(f"{name}.{key}", q, a, "ANSWERED", f"dynamic:{name}")

pack(("deploy", "release", "نشر", "إصدار", "build"), "delivery", [
    ("target", "ما هدف البناء/النشر وكيف نتحقق من الوصول إليه؟", "يجب تحديده من المشروع/القدرات قبل Release Gate؛ Smoke Test إلزامي عند النشر."),
    ("rollback", "ما خطة الرجوع إذا فشل الإصدار؟", "الرجوع إلى Last Known Good Commit/Artifact ومسار نشر سابق مثبت."),
    ("smoke", "ما اختبار التشغيل النهائي؟", "اختبار وصول/تشغيل حقيقي بعد النشر، وليس نجاح build فقط."),
])
pack(("privacy", "بيانات", "data", "secret", "سر", "auth", "مصادقة", "security", "أمن"), "security", [
    ("sensitivity", "هل توجد بيانات/أسرار حساسة؟", "لا توضع الأسرار في المستودع؛ أقل صلاحية لازمة فقط."),
    ("threat", "ما سطح الهجوم أو إساءة الاستخدام المحتملة؟", "يُفحص قبل اعتماد أي مسار يتعامل مع هوية أو أسرار أو بيانات."),
    ("least_privilege", "هل الصلاحيات هي الحد الأدنى؟", "يجب أن تبقى الصلاحيات محددة ولا يوسعها الوكيل ذاتيًا."),
])
pack(("api", "cloud", "github", "vercel", "external", "خارجية", "سحابي"), "external", [
    ("availability", "هل الخدمة الخارجية متاحة ومثبتة الصلاحية؟", "لا تدخل المسار الحرج قبل Capability Proof."),
    ("limits", "ما حدود الخدمة ومعدلاتها وفشلها المتوقع؟", "تُعامل كقيد ويجب وجود timeout/retry/fallback."),
])
pack(("cost", "budget", "تكلفة", "ميزانية", "دفع"), "cost", [
    ("ceiling", "ما سقف التكلفة؟", "لا ينشئ النظام التزامًا ماليًا غير مصرح به؛ يفضل المسار المجاني/الأقل كلفة عند تكافؤ القيمة."),
])
pack(("delete", "حذف", "migrate", "ترحيل", "overwrite", "استبدال"), "destructive", [
    ("backup", "هل توجد نسخة/نقطة رجوع قبل الإجراء المدمر؟", "Backup/Last Known Good مطلوب قبل التغيير غير القابل للعكس."),
    ("blast_radius", "ما نطاق الضرر المحتمل؟", "يُصغّر الإجراء ويُختبر على نطاق محدود أولًا."),
])
pack(("ui", "واجهة", "web", "android", "mobile", "مستخدم"), "user_experience", [
    ("user", "من المستخدم النهائي وما أهم مهمة له؟", "يُستخرج من النية/المواصفات ويُستخدم في معايير القبول."),
    ("accessibility", "هل الناتج قابل للاستخدام على البيئة المستهدفة؟", "التحقق العملي على بيئة/واجهة الهدف جزء من القبول."),
])

critical_unresolved = [q["key"] for q in questions if q["critical"] and q["status"] == "UNRESOLVED"]
if missing or critical_unresolved:
    decision = "SAFE_BLOCKED"
    reason = "missing_core_state_or_critical_answer"
elif human_tasks:
    decision = "HUMAN_REQUIRED"
    reason = "executable_task_requires_human_authority_or_input"
else:
    decision = "PROCEED"
    reason = "leadership_questions_satisfied_within_current_authority"

record = {
    "schema_version": "1.0",
    "gate": "OMEGA_AUTONOMOUS_LEADERSHIP",
    "decision_time": datetime.now(timezone.utc).isoformat(),
    "decision": decision,
    "reason": reason,
    "rule": "NO_LEADERSHIP_DECISION_NO_NBAG_NO_EXECUTION",
    "source_of_truth": "repository",
    "state_status": state_status,
    "missing_core_files": missing,
    "critical_unresolved": critical_unresolved,
    "human_required_task_ids": [t.get("id") for t in human_tasks],
    "question_count": len(questions),
    "questions": questions,
    "operating_principles": [
        "intent_over_literal_sequence",
        "evidence_over_claims",
        "least_privilege",
        "reversible_safe_assumptions_before_human_burden",
        "blocker_first",
        "repair_before_unrelated_features",
        "verified_capability_before_unverified_dependency",
        "bounded_retry_and_failover",
        "terminal_gate_before_complete",
    ],
    "handoff": {
        "next_gate": "OMEGA_NBAG" if decision == "PROCEED" else None,
        "current_task": current_task,
        "declared_next_action": next_action,
    },
}
OUT.parent.mkdir(parents=True, exist_ok=True)
OUT.write_text(json.dumps(record, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(json.dumps(record, ensure_ascii=False))
