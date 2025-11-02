'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "ac76702ae7d014c362c7fdbe8388353d",
"assets/AssetManifest.bin.json": "f49292afe6ad9261f06dd6196470a544",
"assets/AssetManifest.json": "6477f536f47df160bdfa58ef9d192f4d",
"assets/assets/cards/B0.png": "9b2522bbd12443c2d0d1bb1e3082f0b3",
"assets/assets/cards/B1.png": "7446ecd73e9cc5779bc67925d7cac2bb",
"assets/assets/cards/B2.png": "ca8dd76d632a3eb8a88a85872fa7b10a",
"assets/assets/cards/B3.png": "1c9ea5af3988e795336eb19ad9b6d53b",
"assets/assets/cards/B4.png": "a4e4c65ae424f9f0924d323efc032366",
"assets/assets/cards/B5.png": "15ee0708cb855526ba9f9654be153a99",
"assets/assets/cards/B6.png": "5e7f61736fcf96db82c353092655a3a8",
"assets/assets/cards/B7.png": "d1a8d513759b1ed9185f2bdd6619db90",
"assets/assets/cards/B8.png": "3a165fd20eac03500814c624f60c0c2d",
"assets/assets/cards/B9.png": "b4f083953a2e19e7b60177abd36f7058",
"assets/assets/cards/BACK.png": "e860b861c0f4b04e9ce5479ddd03e715",
"assets/assets/cards/BR.png": "29c8934c8535c520b19109905c30b54d",
"assets/assets/cards/BS.png": "bf4e18290c9c4d3f8f285010815ef223",
"assets/assets/cards/B_PLUS2.png": "56d232405bbde2c30829bdee7fd4c3df",
"assets/assets/cards/G0.png": "12d1250058921877be594b822c21353b",
"assets/assets/cards/G1.png": "87ed2ca8cbc0bc93446dc9f93158be0e",
"assets/assets/cards/G2.png": "106a693ded319267907f9904c35a34bd",
"assets/assets/cards/G3.png": "4fa7847a176de3749e7ff7b08362aae7",
"assets/assets/cards/G4.png": "9bbaa750a5bb9e9b24c59fbd71511d34",
"assets/assets/cards/G5.png": "a21bb4d2b1a85613cc677bf22070951c",
"assets/assets/cards/G6.png": "36ed6b07d031f46df5f84a9930480ef7",
"assets/assets/cards/G7.png": "b3be6a59d55b515cef3b0d324cc77d69",
"assets/assets/cards/G8.png": "45b26124b3d55e46ba29287c04d41546",
"assets/assets/cards/G9.png": "a99cfa7a3044fd14a6890c9eb1e5f4e3",
"assets/assets/cards/GR.png": "b60312ce2f787f57ec5bce15fd16a9d5",
"assets/assets/cards/GS.png": "b71ea6dd3752d73e4e0c3b4087c1a763",
"assets/assets/cards/G_PLUS2.png": "ed65866b1408b7914c56ed3aee3b9682",
"assets/assets/cards/R0.png": "67c631dfe7deac471479b4284f2846fc",
"assets/assets/cards/R1.png": "a63728a2ab1820091560dd0a4e2af334",
"assets/assets/cards/R2.png": "dae5f8c247ba14d08993b96d018b6fcf",
"assets/assets/cards/R3.png": "82c53d818319b76a524379bf97574f4a",
"assets/assets/cards/R4.png": "24e2edef7b371ff05af1f37c5478bc42",
"assets/assets/cards/R5.png": "cfc51d9ff8a608562f7844fbbd0987d3",
"assets/assets/cards/R6.png": "e20563b667bd5d711cc5d7a98febb18c",
"assets/assets/cards/R7.png": "e9d98b464281be3da17d0e0bd68a8b36",
"assets/assets/cards/R8.png": "31c5e5e11a31fce7b5bf639daba0f0a1",
"assets/assets/cards/R9.png": "e723fc43344b1aa8a565351ea4578afe",
"assets/assets/cards/RR.png": "67ed6df8b1723f482a5b7f3a4cf052b3",
"assets/assets/cards/RS.png": "6d02b4235eb8d296f461d55a01bb83f9",
"assets/assets/cards/R_PLUS2.png": "3561842a7f1198a2ed8b3f60d8a761bc",
"assets/assets/cards/W.png": "122dff65f6a61e892ba3ea321219adbe",
"assets/assets/cards/W_PLUS4.png": "1f6f759ce5ec72c1b24cc1df47b6be2a",
"assets/assets/cards/Y0.png": "61bc6725aa1439b9376b567866ba353d",
"assets/assets/cards/Y1.png": "eced49f48a50afc0d7e757dc2d971761",
"assets/assets/cards/Y2.png": "e51381fc9de04ef53ecd86e822cafccb",
"assets/assets/cards/Y3.png": "3be54095237a72395b82cfeef557b56d",
"assets/assets/cards/Y4.png": "d6ec883fbad64f6469fad61d03b8b670",
"assets/assets/cards/Y5.png": "32123f37930615bfe0c776095d8269ee",
"assets/assets/cards/Y6.png": "0e7e78deaf46abd98f800e96a47826dd",
"assets/assets/cards/Y7.png": "3d3148ecc459d8d1e8a160d167346b3f",
"assets/assets/cards/Y8.png": "ad20765853c8a6373167b81054022bac",
"assets/assets/cards/Y9.png": "63246c9832878adc771cfe5156d2f1eb",
"assets/assets/cards/YR.png": "18e67a6e1a10da5c51608509c7f4f91d",
"assets/assets/cards/YS.png": "1c233cae67acf09d95d767b4b6bdec72",
"assets/assets/cards/Y_PLUS2.png": "6169bcd98231f4e4574ef20f0e1df0ff",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/fonts/MaterialIcons-Regular.otf": "529c05b7fdb8a97a070ea1efbfa967b6",
"assets/NOTICES": "e12d3cc3486f46d1886bd92dad12dda8",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "728b2d477d9b8c14593d4f9b82b484f3",
"canvaskit/canvaskit.js.symbols": "bdcd3835edf8586b6d6edfce8749fb77",
"canvaskit/canvaskit.wasm": "7a3f4ae7d65fc1de6a6e7ddd3224bc93",
"canvaskit/chromium/canvaskit.js": "8191e843020c832c9cf8852a4b909d4c",
"canvaskit/chromium/canvaskit.js.symbols": "b61b5f4673c9698029fa0a746a9ad581",
"canvaskit/chromium/canvaskit.wasm": "f504de372e31c8031018a9ec0a9ef5f0",
"canvaskit/skwasm.js": "ea559890a088fe28b4ddf70e17e60052",
"canvaskit/skwasm.js.symbols": "e72c79950c8a8483d826a7f0560573a1",
"canvaskit/skwasm.wasm": "39dd80367a4e71582d234948adc521c0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "83d881c1dbb6d6bcd6b42e274605b69c",
"flutter_bootstrap.js": "c85e6b65908fb31c04d2a1b75ec2c2a2",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "4810ec7579fdd3351df83225bacab4ee",
"/": "4810ec7579fdd3351df83225bacab4ee",
"main.dart.js": "55ee05e4f78ec54b88e5ea2a7232f322",
"manifest.json": "c28fe2a838ee1a1d9a000ee5cd6dbca0",
"version.json": "29cea4516b7787f9f00f87d9f1e2a174"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
