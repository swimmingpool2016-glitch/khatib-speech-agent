export const config = { runtime: 'edge' };

const ALLOWED_PREFIX = 'https://cop202.app.n8n.cloud/';

export default async function handler(req) {
  const target = new URL(req.url).searchParams.get('url');

  if (!target || !target.startsWith(ALLOWED_PREFIX)) {
    return new Response('Refused: target must be the configured n8n instance.', { status: 400 });
  }

  try {
    const upstream = await fetch(target, { method: 'GET' });
    const text = await upstream.text();

    return new Response(text, {
      status: upstream.status,
      headers: { 'content-type': 'text/plain; charset=utf-8' },
    });
  } catch (err) {
    return new Response(
      JSON.stringify({ proxyError: err.message }),
      { status: 502, headers: { 'content-type': 'application/json; charset=utf-8' } },
    );
  }
}
