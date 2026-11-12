// Replaces the service worker of the earlier web builds, which served the game
// from its cache and kept an old version on screen. Browsers check this file at
// each visit: this one clears the cache, removes itself and reloads the open
// pages, which then load the current build from the network.
self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (event) => {
	event.waitUntil((async () => {
		const names = await caches.keys();
		await Promise.all(names.filter((name) => name.startsWith('Overclock-sw-cache-')).map((name) => caches.delete(name)));
		await self.registration.unregister();
		const pages = await self.clients.matchAll({ type: 'window' });
		pages.forEach((page) => page.navigate(page.url));
	})());
});
