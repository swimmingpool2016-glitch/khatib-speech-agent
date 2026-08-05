export const config = { runtime: 'edge' };

const CHAT_WEBHOOK =
  'https://cop202.app.n8n.cloud/webhook/912a0464-5915-45b4-9e50-3731e3f231c1/chat';

export default async function handler(req) {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  try {
    const body = await req.text();

    const upstream = await fetch(CHAT_WEBHOOK, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body,
    });

    const text = await upstream.text();

    return new Response(text, {
      status: upstream.status,
      headers: { 'content-type': 'application/json; charset=utf-8' },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ proxyError: err.message }),
      { status: 502, headers: { 'content-type': 'application/json; charset=utf-8' } },
    );
  }
}
