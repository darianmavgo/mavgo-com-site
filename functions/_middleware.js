// Cloudflare Pages middleware: redirect any request whose path contains
// uppercase characters to its lowercase equivalent, so URLs are case-insensitive.
export async function onRequest(context) {
  const url = new URL(context.request.url);
  const lower = url.pathname.toLowerCase();

  if (url.pathname !== lower) {
    url.pathname = lower;
    return Response.redirect(url.toString(), 301);
  }

  return context.next();
}
