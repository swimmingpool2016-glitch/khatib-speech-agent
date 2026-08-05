export const config = { runtime: 'edge' };

const FORMS = {
  main: 'https://cop202.app.n8n.cloud/form/c8a16cff-7ecf-4a35-b5b6-98ac607b8156',
  topic: 'https://cop202.app.n8n.cloud/form/cb411441-972a-4b5e-b0bb-7d74bebc59bf',
};

export default async function handler(req) {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  const agent = new URL(req.url).searchParams.get('agent') === 'topic' ? 'topic' : 'main';

  try {
    const upstream = await fetch(FORMS[agent], {
      method: 'POST',
      body: req.body,
      headers: { 'content-type': req.headers.get('content-type') || '' },
      duplex: 'half',
    });

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
