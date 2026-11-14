/* PWA familiale : installation sans stockage local des informations privées.
   Toutes les pages et appels API restent servis depuis le réseau. */
self.addEventListener('install',()=>self.skipWaiting());
self.addEventListener('activate',event=>event.waitUntil(self.clients.claim()));
self.addEventListener('fetch',event=>{
  if(event.request.method!=='GET'||event.request.mode!=='navigate')return;
  event.respondWith(fetch(event.request));
});
