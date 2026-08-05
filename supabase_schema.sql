-- =====================================================================
-- جدول تقارير تحليل الخطابة — نظام الوكيل الذكي لتحليل الخطاب
-- شغّل هذا الملف كامل في Supabase: SQL Editor > New query > Run
-- =====================================================================

create table if not exists public.speech_reports (
  id                 uuid primary key default gen_random_uuid(),
  created_at         timestamptz not null default now(),

  speaker_name       text not null,
  speech_type        text not null,        -- ارتجالي / معد / مفتوح
  topic              text,                 -- موضوع الخطاب (إن وجد)
  input_mode         text not null,        -- video / audio
  detected_mime_type text,

  transcript         text,                 -- النص المفرّغ من الخطاب

  verbal_analysis    jsonb,                -- تحليل الرسالة اللفظية (تلكؤات، تدقيق لغوي، بنية...)
  nonverbal_analysis jsonb,                -- تحليل الرسالة غير اللفظية (لغة جسد، صوت، تواصل بصري...)

  style_signature    text,                 -- البصمة الأسلوبية الوصفية للخطيب
  strengths          text,                 -- نقاط التميز
  improvements       text,                 -- خطة التحسين والتطوير
  full_report        text not null,        -- التقرير الكامل المنسّق المعروض للمستخدم

  notes              text                  -- ملاحظات إضافية من المتحدث
);

-- فهرس للبحث السريع حسب اسم المتحدث والتاريخ (لتتبع تطور كل متحدث عبر الوقت)
create index if not exists idx_speech_reports_speaker on public.speech_reports (speaker_name, created_at desc);

-- ملاحظة أمان: فعّل Row Level Security وأضف policy مناسبة لحالتك قبل الإنتاج الفعلي،
-- أو استخدم الـ service_role key في بيانات اعتماد n8n (وقتها RLS لا يُطبَّق عليه).
-- مثال لو حبيت تفعّل RLS مع سماح كامل عبر service_role فقط:
-- alter table public.speech_reports enable row level security;
