-- =====================================================================
-- خطيب — مخطط قاعدة بيانات تقارير تحليل الخطابة (v2)
-- شغّل هذا الملف كاملاً في Supabase: SQL Editor → New query → Run
-- =====================================================================

create table if not exists public.speech_reports (
  id                 uuid primary key default gen_random_uuid(),
  created_at         timestamptz not null default now(),

  -- هوية الجلسة
  speaker_name       text not null,
  speaker_key        text,              -- اسم مُطبَّع (بدون تشكيل/همزات) لربط جلسات نفس المتحدث
  session_number     integer,           -- ترتيب الجلسة لهذا المتحدث
  speech_type        text not null,     -- ارتجالي / معد / مفتوح
  topic              text,
  notes              text,

  -- المدخل
  input_mode         text not null,     -- video / audio
  detected_mime_type text,
  duration_seconds   numeric,
  transcript         text,

  -- التقييم
  overall_score      integer,           -- 0-100
  progress_delta     integer,           -- الفرق عن الجلسة السابقة
  scores             jsonb,             -- الوضوح/البنية/الجذب/اللغة/الإيقاع/الثقة
  metrics            jsonb,             -- مقاييس موضوعية محسوبة برمجياً
  verbal_analysis    jsonb,             -- البنية واللغة والبلاغة والأدلة النصية
  nonverbal_analysis jsonb,             -- تقييم الإيقاع الصوتي وتوفّر التحليل البصري
  coaching_plan      jsonb,             -- خطة التدريب الكاملة
  style_signature    text,
  strengths          text,
  improvements       text,
  full_report        text not null,     -- التقرير المنسّق المعروض للمستخدم
  analysis_version   text default 'v2'
);

-- ترقية جدول موجود مسبقاً من الإصدار الأول
alter table public.speech_reports
  add column if not exists session_number   integer,
  add column if not exists duration_seconds numeric,
  add column if not exists overall_score    integer,
  add column if not exists scores           jsonb,
  add column if not exists metrics          jsonb,
  add column if not exists coaching_plan    jsonb,
  add column if not exists progress_delta   integer,
  add column if not exists speaker_key      text,
  add column if not exists analysis_version text default 'v2';

-- فهارس: تتبّع تطوّر المتحدث عبر الوقت، وترتيب حسب الدرجة
create index if not exists idx_speech_reports_speaker_key
  on public.speech_reports (speaker_key, created_at desc);

create index if not exists idx_speech_reports_overall_score
  on public.speech_reports (overall_score desc nulls last);

-- =====================================================================
-- ⚠️ أمان: Row Level Security غير مفعّل على هذا الجدول.
-- الوركفلو يكتب عبر service_role (لا يتأثر بـ RLS)، لكن إن كان مفتاح anon
-- مستخدماً في أي مكان، فالجدول مقروء ومكتوب للجميع.
--
-- لتفعيل الحماية شغّل الأمرين معاً — وليس الأول وحده، لأن تفعيل RLS
-- بدون سياسة يمنع كل وصول بما فيه الوركفلو:
--
--   alter table public.speech_reports enable row level security;
--   create policy "service_role_full_access" on public.speech_reports
--     for all to service_role using (true) with check (true);
-- =====================================================================
