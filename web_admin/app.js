// Hungr Operations Web Command - Khammam Morning Tiffin Portal
// Comprehensive Standalone Admin Engine

// 1. Initial State for Khammam Kitchens & 4 Zones
const DEFAULT_SHOPS = [
  {
    id: 'shop_venkateshwara',
    name: 'Sri Venkateshwara Tiffin Hub',
    tagline: "Khammam's Famous Woodfire Ghee Dosa & Spongy Thatte Idli",
    zone: 'Khammam North (Bypass Road)',
    address: 'Near Old Collectorate Circle, Bypass Road, Khammam',
    status: 'open',
    rating: 4.8,
    reviews: 2450,
    deliveryWindow: 'Drop at gate by 7:30 AM',
    closureReason: '',
    reopenDate: '',
    dishes: [
      { id: 'item_set_dosa', name: 'Rayalaseema Set Dosa (3 Pcs)', price: 49 },
      { id: 'item_idli_vada', name: 'Ghee Idlis (4 Pcs) + Medu Vada (1 Pc)', price: 49 },
      { id: 'item_mysore_bonda', name: 'Crisp Mysore Bonda (4 Pcs)', price: 45 },
      { id: 'addon_filter_coffee', name: 'Degree Filter Coffee (200ml)', price: 25 }
    ]
  },
  {
    id: 'shop_amma_chethi',
    name: 'Amma Chethi Vanta',
    tagline: 'Authentic Andhra Homestyle Breakfast prepared with pure cow ghee',
    zone: 'Khammam South (Wyra Road)',
    address: 'Shop 4, Mamillagudem Main Road, Wyra Road, Khammam',
    status: 'open',
    rating: 4.9,
    reviews: 3120,
    deliveryWindow: 'Drop at gate by 7:30 AM',
    closureReason: '',
    reopenDate: '',
    dishes: [
      { id: 'item_poori_masala', name: 'Homestyle Poori Masala (3 Pcs)', price: 55 },
      { id: 'item_upma_pesarattu', name: 'MLA Pesarattu Upma', price: 55 },
      { id: 'addon_boiled_eggs', name: 'Farm Boiled Eggs (2 Pcs)', price: 20 },
      { id: 'addon_badam_milk', name: 'Steaming Kesari Badam Milk (200ml)', price: 25 }
    ]
  },
  {
    id: 'shop_bala_corner',
    name: 'Bala Tiffin Corner',
    tagline: 'Crispy hot Mysore Bondas & Vadas since 1994',
    zone: 'Khammam East (Bus Stand)',
    address: 'Opposite RTC New Bus Stand, Khammam',
    status: 'closedToday',
    rating: 4.7,
    reviews: 1890,
    deliveryWindow: 'Drop at gate by 7:30 AM',
    closureReason: 'Kitchen equipment steam-valve maintenance today',
    reopenDate: 'Tomorrow at 6:00 AM',
    dishes: [
      { id: 'item_idli_vada', name: 'Ghee Idlis (4 Pcs) + Medu Vada (1 Pc)', price: 49 },
      { id: 'item_mysore_bonda', name: 'Crisp Mysore Bonda (4 Pcs)', price: 45 },
      { id: 'addon_filter_coffee', name: 'Degree Filter Coffee (200ml)', price: 25 }
    ]
  },
  {
    id: 'shop_sai_udupi',
    name: 'Sri Sai Udupi Upahar',
    tagline: 'Traditional Karnataka Udupi breakfast with rich drumstick sambar',
    zone: 'Khammam West (Gandhi Chowk)',
    address: 'Near Clock Tower, Gandhi Chowk, Khammam',
    status: 'closedTemporary',
    rating: 4.6,
    reviews: 980,
    deliveryWindow: 'Drop at gate by 7:30 AM',
    closureReason: 'Closed for 2 days due to family temple festival',
    reopenDate: 'Reopens Thursday, 14 Nov',
    dishes: [
      { id: 'item_set_dosa', name: 'Rayalaseema Set Dosa (3 Pcs)', price: 49 },
      { id: 'item_idli_vada', name: 'Ghee Idlis (4 Pcs) + Medu Vada (1 Pc)', price: 49 },
      { id: 'addon_badam_milk', name: 'Steaming Kesari Badam Milk (200ml)', price: 25 }
    ]
  }
];

const ZONES = [
  {
    id: 'north',
    name: 'Khammam North (Bypass Road)',
    overview: 'Bypass Road, New Collectorate & Mamatha Circle',
    driver: 'Ramesh Goud',
    phone: '+91 98480 11223',
    vehicle: 'Honda Activa 6G (TS 04 EA 1234)',
    orders: 42,
    fuelSaved: 2.8,
    route: 'Bypass Hub ➔ Sri Sai PG ➔ Kakatiya Girls ➔ Collectorate Quarters',
    coords: [17.2620, 80.1470],
    color: '#3B82F6',
    clusters: [
      { name: 'Sri Sai PG Gate', lat: 17.2635, lng: 80.1465, meals: 18, token: '#SS-04' },
      { name: 'Kakatiya Girls Hostel', lat: 17.2605, lng: 80.1485, meals: 14, token: '#KG-09' },
      { name: 'Mamata Medical Campus', lat: 17.2650, lng: 80.1440, meals: 10, token: '#MM-02' }
    ]
  },
  {
    id: 'south',
    name: 'Khammam South (Wyra Road)',
    overview: 'Wyra Road, Mamillagudem & NSP Colony',
    driver: 'Suresh Kumar',
    phone: '+91 98480 22334',
    vehicle: 'Hero Splendor+ (TS 04 EB 5678)',
    orders: 38,
    fuelSaved: 2.3,
    route: 'Wyra Road Hub ➔ Green Valley ➔ Sri Chaitanya ➔ Vijaya Towers',
    coords: [17.2340, 80.1600],
    color: '#10B981',
    clusters: [
      { name: 'Green Valley Enclave Gate', lat: 17.2325, lng: 80.1620, meals: 16, token: '#GV-11' },
      { name: 'Sri Chaitanya Boys Gate', lat: 17.2360, lng: 80.1580, meals: 12, token: '#SC-05' },
      { name: 'NSP Colony Watchman Desk', lat: 17.2310, lng: 80.1650, meals: 10, token: '#NS-07' }
    ]
  },
  {
    id: 'east',
    name: 'Khammam East (Bus Stand & Station)',
    overview: 'RTC New Bus Stand, Railway Station & Mamata Hospital',
    driver: 'Naresh Babu',
    phone: '+91 98480 33445',
    vehicle: 'TVS Jupiter 125 (TS 04 EC 9012)',
    orders: 51,
    fuelSaved: 3.4,
    route: 'East Hub ➔ Bus Stand Gate ➔ Mamata Quarters ➔ Krishna Residency',
    coords: [17.2510, 80.1650],
    color: '#F59E0B',
    clusters: [
      { name: 'RTC Bus Stand Entrance', lat: 17.2515, lng: 80.1635, meals: 22, token: '#BS-14' },
      { name: 'Sri Krishna Residency', lat: 17.2490, lng: 80.1680, meals: 18, token: '#KR-03' },
      { name: 'Railway Colony Gate 2', lat: 17.2530, lng: 80.1670, meals: 11, token: '#RC-08' }
    ]
  },
  {
    id: 'west',
    name: 'Khammam West (Gandhi Chowk & Old Town)',
    overview: 'Gandhi Chowk, Mayuri Centre & Rotary Nagar',
    driver: 'Mahesh Yadav',
    phone: '+91 98480 44556',
    vehicle: 'Bajaj Pulsar 125 (TS 04 ED 3456)',
    orders: 29,
    fuelSaved: 1.9,
    route: 'West Hub ➔ Gayatri Towers ➔ Mayuri Centre ➔ Rotary Nagar',
    coords: [17.2430, 80.1380],
    color: '#EF4444',
    clusters: [
      { name: 'Clock Tower / Gandhi Chowk', lat: 17.2440, lng: 80.1370, meals: 13, token: '#CT-01' },
      { name: 'Gayatri Towers Reception', lat: 17.2415, lng: 80.1395, meals: 9, token: '#GT-06' },
      { name: 'Rotary Nagar Security Gate', lat: 17.2460, lng: 80.1350, meals: 7, token: '#RN-12' }
    ]
  }
];

const DISPATCH_FEED = [
  {
    cluster: 'Sri Sai PG Main Gate',
    zone: 'North (Bypass)',
    details: '12 Units Delivered • Photo verified at watchman desk by Ramesh Goud',
    time: '07:38 AM IST',
    status: 'delivered',
    icon: '✅'
  },
  {
    cluster: 'Green Valley Watchman Desk',
    zone: 'South (Wyra)',
    details: '9 Units Out for Delivery • Driver Suresh Kumar en route (2 min away)',
    time: '07:44 AM IST',
    status: 'out',
    icon: '🛵'
  },
  {
    cluster: 'Sri Krishna Residency Gate',
    zone: 'East (Bus Stand)',
    details: '14 Units Delivered • Received by Watchman Mallesh',
    time: '07:29 AM IST',
    status: 'delivered',
    icon: '✅'
  },
  {
    cluster: 'Gayatri Towers Reception Gate',
    zone: 'West (Gandhi Chowk)',
    details: 'Delivery Failed: Gate was locked / Security guard was asleep',
    time: '07:48 AM IST',
    status: 'failed',
    icon: '⚠️',
    canRetry: true
  }
];

// 2. State & Storage Engine
let shops = JSON.parse(localStorage.getItem('hungr_admin_shops')) || DEFAULT_SHOPS;

function saveShopsToStorage() {
  localStorage.setItem('hungr_admin_shops', JSON.stringify(shops));
  renderShops();
  updateKPIs();
}

// 3. KPI Updates
function updateKPIs() {
  const openCount = shops.filter(s => s.status === 'open').length;
  const closedCount = shops.length - openCount;
  const totalOrders = ZONES.reduce((acc, z) => acc + z.orders, 0);
  const totalFuel = ZONES.reduce((acc, z) => acc + z.fuelSaved, 0).toFixed(1);

  document.getElementById('total-shops-kpi').innerText = `${shops.length} Shops`;
  document.getElementById('open-shops-kpi').innerText = `${openCount} Open • ${closedCount} Closed`;
  document.getElementById('total-orders-kpi').innerText = `${totalOrders} Meals`;
  document.getElementById('fuel-saved-kpi').innerText = `${totalFuel} Litres`;
}

// 4. Render Partner Shops
function renderShops() {
  const container = document.getElementById('shops-container');
  container.innerHTML = '';

  shops.forEach(shop => {
    const isClosed = shop.status !== 'open';
    const statusLabels = {
      open: 'Open for Drops',
      closedToday: 'Closed Today',
      closedTemporary: 'Closed Temporarily',
      permanentlyClosed: 'Permanently Closed'
    };

    const card = document.createElement('div');
    card.className = `shop-card ${isClosed ? 'closed' : ''}`;
    card.innerHTML = `
      <div class="shop-card-header">
        <div>
          <h3 class="shop-info-title">${shop.name}</h3>
          <p class="shop-info-zone">📍 ${shop.zone}</p>
        </div>
        <span class="status-badge ${shop.status}">${statusLabels[shop.status]}</span>
      </div>

      <div class="shop-card-body">
        <p class="shop-tagline">"${shop.tagline}"</p>

        ${isClosed ? `
          <div class="closure-alert-box">
            <strong>⚠️ Closure Alert:</strong> ${shop.closureReason || 'Temporarily closed'}<br>
            <span style="font-size: 11px;">Expected Reopening: <strong>${shop.reopenDate || 'Soon'}</strong></span>
          </div>
        ` : ''}

        <p style="font-size: 11px; font-weight: 700; color: #4B5563; margin-bottom: 6px;">DISH MENU & LIVE PRICING:</p>
        <div class="dishes-pill-list">
          ${shop.dishes.map(d => `
            <div class="dish-pill">
              <span>${d.name}</span>
              <span class="dish-price">₹${d.price}</span>
            </div>
          `).join('')}
        </div>
      </div>

      <div class="shop-card-footer">
        <span class="delivery-window-pill">⏰ ${shop.deliveryWindow}</span>
        <button class="btn btn-secondary btn-sm" onclick="openEditShopModal('${shop.id}')">Manage & Edit ➔</button>
      </div>
    `;

    container.appendChild(card);
  });
}

// 5. Render Khammam 4-Zones Heatmap
function renderZones() {
  const container = document.getElementById('zones-container');
  container.innerHTML = '';
  const maxOrders = Math.max(...ZONES.map(z => z.orders));

  ZONES.forEach(zone => {
    const percentage = Math.round((zone.orders / maxOrders) * 100);

    const card = document.createElement('div');
    card.className = 'zone-card';
    card.innerHTML = `
      <div class="zone-header">
        <div>
          <h3 class="zone-title">${zone.name}</h3>
          <p class="zone-overview">${zone.overview}</p>
        </div>
        <span class="zone-orders-badge">${zone.orders} ORDERS</span>
      </div>

      <div class="density-bar-container">
        <div class="density-bar-fill" style="width: ${percentage}%;"></div>
      </div>

      <div class="driver-info-box">
        <div>
          <p class="driver-name">🛵 Driver: ${zone.driver}</p>
          <p class="driver-phone">${zone.vehicle} • ${zone.phone}</p>
        </div>
        <button class="btn btn-secondary btn-sm" onclick="alert('Calling Driver ${zone.driver} (${zone.phone})...')">Call Driver</button>
      </div>

      <p class="route-desc">Consolidated Route: ${zone.route}</p>
      <p style="font-size: 11px; color: #16A34A; font-weight: 600; margin-top: 4px;">⚡ Fuel Saved: ${zone.fuelSaved}L</p>
    `;

    container.appendChild(card);
  });
}

// 6. Render Live Dispatch Feed
function renderDispatchFeed() {
  const container = document.getElementById('dispatch-container');
  container.innerHTML = '';

  DISPATCH_FEED.forEach((item, index) => {
    const el = document.createElement('div');
    el.className = `feed-item ${item.status}`;
    el.innerHTML = `
      <div class="feed-icon">${item.icon}</div>
      <div class="feed-content">
        <h4 class="feed-title">${item.cluster} <span style="font-size: 11px; font-weight: normal; color: #6B7280;">(${item.zone})</span></h4>
        <p class="feed-sub">${item.details}</p>
      </div>
      <div style="text-align: right;">
        <span class="feed-time">${item.time}</span>
        ${item.canRetry ? `
          <br><button class="btn btn-primary btn-sm" style="margin-top: 6px;" onclick="retryDrop(${index})">Re-Attempt Drop</button>
        ` : ''}
      </div>
    `;
    container.appendChild(el);
  });
}

function retryDrop(index) {
  DISPATCH_FEED[index].status = 'out';
  DISPATCH_FEED[index].icon = '🛵';
  DISPATCH_FEED[index].details = 'Re-attempt dispatched. Driver Mahesh returning to gate with warden notified.';
  DISPATCH_FEED[index].canRetry = false;
  renderDispatchFeed();
}

// 7. Modal Controls
function openEditShopModal(shopId) {
  const shop = shops.find(s => s.id === shopId);
  if (!shop) return;

  document.getElementById('edit-shop-id').value = shop.id;
  document.getElementById('edit-modal-title').innerText = `Manage: ${shop.name}`;
  document.getElementById('edit-shop-status').value = shop.status;
  document.getElementById('edit-shop-reason').value = shop.closureReason || '';
  document.getElementById('edit-shop-reopen').value = shop.reopenDate || '';

  const dishesContainer = document.getElementById('edit-shop-dishes');
  dishesContainer.innerHTML = shop.dishes.map((dish, idx) => `
    <div class="dish-edit-row">
      <span>${dish.name}</span>
      <div>
        <span>₹ </span>
        <input type="number" id="dish-price-${idx}" value="${dish.price}" min="10" max="300">
      </div>
    </div>
  `).join('');

  toggleClosureFields();
  document.getElementById('edit-shop-modal').classList.add('open');
}

function closeEditShopModal() {
  document.getElementById('edit-shop-modal').classList.remove('open');
}

function toggleClosureFields() {
  const status = document.getElementById('edit-shop-status').value;
  const reasonGroup = document.getElementById('closure-reason-group');
  const reopenGroup = document.getElementById('reopen-date-group');

  if (status === 'open') {
    reasonGroup.style.display = 'none';
    reopenGroup.style.display = 'none';
  } else {
    reasonGroup.style.display = 'block';
    reopenGroup.style.display = 'block';
  }
}

function saveShopChanges() {
  const id = document.getElementById('edit-shop-id').value;
  const shop = shops.find(s => s.id === id);
  if (!shop) return;

  shop.status = document.getElementById('edit-shop-status').value;
  shop.closureReason = document.getElementById('edit-shop-reason').value.trim();
  shop.reopenDate = document.getElementById('edit-shop-reopen').value.trim();

  shop.dishes.forEach((dish, idx) => {
    const input = document.getElementById(`dish-price-${idx}`);
    if (input) {
      dish.price = parseInt(input.value) || dish.price;
    }
  });

  saveShopsToStorage();
  broadcastKitchenUpdate('UPDATE_SHOP_STATUS_AND_PRICES', shop);
  closeEditShopModal();
  alert(`Changes saved for ${shop.name}! Status: ${shop.status.toUpperCase()}`);
}

function openAddShopModal() {
  document.getElementById('add-shop-modal').classList.add('open');
}

function closeAddShopModal() {
  document.getElementById('add-shop-modal').classList.remove('open');
}

function saveNewShop() {
  const name = document.getElementById('add-shop-name').value.trim();
  const tagline = document.getElementById('add-shop-tagline').value.trim();
  const zone = document.getElementById('add-shop-zone').value;
  const address = document.getElementById('add-shop-address').value.trim();

  if (!name) {
    alert('Please enter a kitchen name.');
    return;
  }

  const newShop = {
    id: `shop_${Date.now()}`,
    name,
    tagline: tagline || 'Fresh Khammam morning tiffin',
    zone,
    address: address || 'Khammam Central',
    status: 'open',
    rating: 4.8,
    reviews: 50,
    deliveryWindow: 'Drop at gate by 7:30 AM',
    closureReason: '',
    reopenDate: '',
    dishes: [
      { id: 'item_set_dosa', name: 'Rayalaseema Set Dosa (3 Pcs)', price: 49 },
      { id: 'item_idli_vada', name: 'Steaming Ghee Idli + Vada', price: 49 }
    ]
  };

  shops.push(newShop);
  saveShopsToStorage();
  broadcastKitchenUpdate('ADD_NEW_SHOP', newShop);
  closeAddShopModal();
  alert(`Onboarded ${name} successfully!`);
}

// 8. Tab Navigation Logic
document.querySelectorAll('.tab-btn').forEach(button => {
  button.addEventListener('click', () => {
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));

    button.classList.add('active');
    const targetId = button.getAttribute('data-tab');
    document.getElementById(targetId).classList.add('active');

    if (targetId === 'zones-tab' && khammamMap) {
      setTimeout(() => khammamMap.invalidateSize(), 200);
    }
  });
});

// 9. Realtime Live Sync Engine (Web Admin ⇄ Mobile App)
const opsBroadcastChannel = (typeof BroadcastChannel !== 'undefined') ? new BroadcastChannel('hungr_ops_channel') : null;

function broadcastKitchenUpdate(action, data) {
  const payload = {
    action: action,
    data: data,
    timestamp: Date.now()
  };
  if (opsBroadcastChannel) {
    try {
      opsBroadcastChannel.postMessage(payload);
    } catch (e) {
      console.warn('BroadcastChannel error:', e);
    }
  }
  try {
    localStorage.setItem('hungr_kitchen_sync_event', JSON.stringify(payload));
  } catch (e) {
    console.warn('localStorage sync error:', e);
  }
}

// 10. Khammam Interactive Leaflet & Vector Heatmap Engine
let khammamMap = null;
let mapMarkers = [];
let mapPolylines = [];

function initKhammamMap() {
  const mapElement = document.getElementById('khammam-map');
  if (!mapElement) return;

  const khammamCenter = [17.2472, 80.1514];

  if (typeof L !== 'undefined' && L.map) {
    try {
      khammamMap = L.map('khammam-map', {
        center: khammamCenter,
        zoom: 13,
        zoomControl: true
      });

      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '© OpenStreetMap contributors • Hungr Morning Dispatch',
        maxZoom: 18
      }).addTo(khammamMap);

      ZONES.forEach(zone => {
        // Sector Coverage Area
        L.circle(zone.coords, {
          color: zone.color,
          fillColor: zone.color,
          fillOpacity: 0.12,
          radius: 1200,
          weight: 1.5,
          dashArray: '4, 4'
        }).addTo(khammamMap);

        // Hub Node Marker
        const hubHtml = `<div class="heat-pulse-node" style="background:${zone.color}; width:32px; height:32px;">${zone.orders}</div>`;
        const hubIcon = L.divIcon({
          html: hubHtml,
          className: 'custom-hub-marker',
          iconSize: [32, 32],
          iconAnchor: [16, 16]
        });

        const hubMarker = L.marker(zone.coords, { icon: hubIcon }).addTo(khammamMap);
        hubMarker.bindPopup(`
          <div style="font-family:'Plus Jakarta Sans',sans-serif; min-width:180px;">
            <strong style="color:${zone.color}; font-size:13px;">${zone.name}</strong><br>
            <span style="font-size:11px; color:#4B5563;">🛵 Driver: <b>${zone.driver}</b></span><br>
            <span style="font-size:11px; color:#16A34A;">⛽ Saved: <b>${zone.fuelSaved} Litres</b></span><br>
            <span style="font-size:12px; font-weight:700; color:#111827;">📦 ${zone.orders} Pre-Batched Meals</span>
          </div>
        `);
        mapMarkers.push({ sector: zone.id, marker: hubMarker, coords: zone.coords });

        // Cluster stops & route polyline
        const routeCoords = [zone.coords];
        if (zone.clusters) {
          zone.clusters.forEach(cluster => {
            routeCoords.push([cluster.lat, cluster.lng]);
            const clusterHtml = `<div style="background:white; border:2px solid ${zone.color}; border-radius:50%; width:22px; height:22px; display:flex; align-items:center; justify-content:center; font-size:9px; font-weight:800; color:${zone.color}; box-shadow:0 1px 4px rgba(0,0,0,0.25);">${cluster.meals}</div>`;
            const clusterIcon = L.divIcon({
              html: clusterHtml,
              className: 'cluster-stop-marker',
              iconSize: [22, 22],
              iconAnchor: [11, 11]
            });

            const clusterMarker = L.marker([cluster.lat, cluster.lng], { icon: clusterIcon }).addTo(khammamMap);
            clusterMarker.bindPopup(`
              <div style="font-family:'Plus Jakarta Sans',sans-serif; min-width:160px;">
                <span style="background:${zone.color}; color:white; font-size:10px; font-weight:700; padding:2px 6px; border-radius:4px;">${cluster.token}</span>
                <h4 style="margin:4px 0 2px 0; font-size:12px; color:#111827;">${cluster.name}</h4>
                <p style="margin:0; font-size:11px; color:#6B7280;">${cluster.meals} breakfast parcels • Dropped at Gate</p>
              </div>
            `);
            mapMarkers.push({ sector: zone.id, marker: clusterMarker, coords: [cluster.lat, cluster.lng] });
          });
        }

        // Polyline connecting stops
        const poly = L.polyline(routeCoords, {
          color: zone.color,
          weight: 2.5,
          opacity: 0.7,
          dashArray: '6, 6'
        }).addTo(khammamMap);
        mapPolylines.push({ sector: zone.id, polyline: poly });
      });

      return;
    } catch (e) {
      console.warn('Leaflet initialization warning, falling back to vector SVG:', e);
    }
  }

  // Fallback: Rich Vector Interactive SVG Radar Map if Leaflet is blocked / offline
  renderVectorMapFallback(mapElement);
}

function renderVectorMapFallback(container) {
  container.innerHTML = `
    <div class="vector-map-overlay">
      <svg viewBox="0 0 800 400" width="100%" height="100%" style="max-height: 420px;">
        <defs>
          <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M 40 0 L 0 0 0 40" fill="none" stroke="#E5E7EB" stroke-width="1"/>
          </pattern>
        </defs>
        <rect width="800" height="400" fill="url(#grid)" />

        <!-- Khammam Center Landmark -->
        <circle cx="400" cy="200" r="14" fill="#E23744" opacity="0.15"/>
        <circle cx="400" cy="200" r="6" fill="#E23744"/>
        <text x="400" y="222" font-family="'Plus Jakarta Sans', sans-serif" font-size="11" font-weight="700" fill="#111827" text-anchor="middle">Khammam Central Hub</text>

        <!-- North Sector (Bypass) -->
        <g id="svg-sector-north" class="svg-sector-group" style="cursor:pointer;" onclick="filterMapSector('north')">
          <circle cx="400" cy="75" r="55" fill="#3B82F6" opacity="0.12" stroke="#3B82F6" stroke-width="2" stroke-dasharray="4,4"/>
          <line x1="400" y1="200" x2="400" y2="90" stroke="#3B82F6" stroke-width="2" stroke-dasharray="5,5"/>
          <circle cx="400" cy="75" r="16" fill="#3B82F6"/>
          <text x="400" y="79" fill="#FFFFFF" font-family="'JetBrains Mono'" font-size="10" font-weight="800" text-anchor="middle">42</text>
          <text x="400" y="50" font-family="'Plus Jakarta Sans'" font-size="12" font-weight="800" fill="#1D4ED8" text-anchor="middle">NORTH (Bypass)</text>
          <text x="400" y="105" font-family="sans-serif" font-size="10" fill="#4B5563" text-anchor="middle">Ramesh Goud • 3 Clusters</text>
        </g>

        <!-- South Sector (Wyra Road) -->
        <g id="svg-sector-south" class="svg-sector-group" style="cursor:pointer;" onclick="filterMapSector('south')">
          <circle cx="400" cy="320" r="55" fill="#10B981" opacity="0.12" stroke="#10B981" stroke-width="2" stroke-dasharray="4,4"/>
          <line x1="400" y1="200" x2="400" y2="305" stroke="#10B981" stroke-width="2" stroke-dasharray="5,5"/>
          <circle cx="400" cy="320" r="16" fill="#10B981"/>
          <text x="400" y="324" fill="#FFFFFF" font-family="'JetBrains Mono'" font-size="10" font-weight="800" text-anchor="middle">38</text>
          <text x="400" y="352" font-family="'Plus Jakarta Sans'" font-size="12" font-weight="800" fill="#047857" text-anchor="middle">SOUTH (Wyra Rd)</text>
          <text x="400" y="295" font-family="sans-serif" font-size="10" fill="#4B5563" text-anchor="middle">Suresh Kumar • 3 Clusters</text>
        </g>

        <!-- East Sector (Bus Stand) -->
        <g id="svg-sector-east" class="svg-sector-group" style="cursor:pointer;" onclick="filterMapSector('east')">
          <circle cx="620" cy="200" r="55" fill="#F59E0B" opacity="0.12" stroke="#F59E0B" stroke-width="2" stroke-dasharray="4,4"/>
          <line x1="400" y1="200" x2="605" y2="200" stroke="#F59E0B" stroke-width="2" stroke-dasharray="5,5"/>
          <circle cx="620" cy="200" r="16" fill="#F59E0B"/>
          <text x="620" y="204" fill="#FFFFFF" font-family="'JetBrains Mono'" font-size="10" font-weight="800" text-anchor="middle">51</text>
          <text x="620" y="170" font-family="'Plus Jakarta Sans'" font-size="12" font-weight="800" fill="#B45309" text-anchor="middle">EAST (Bus Stand)</text>
          <text x="620" y="230" font-family="sans-serif" font-size="10" fill="#4B5563" text-anchor="middle">Naresh Babu • 3 Clusters</text>
        </g>

        <!-- West Sector (Gandhi Chowk) -->
        <g id="svg-sector-west" class="svg-sector-group" style="cursor:pointer;" onclick="filterMapSector('west')">
          <circle cx="180" cy="200" r="55" fill="#EF4444" opacity="0.12" stroke="#EF4444" stroke-width="2" stroke-dasharray="4,4"/>
          <line x1="400" y1="200" x2="195" y2="200" stroke="#EF4444" stroke-width="2" stroke-dasharray="5,5"/>
          <circle cx="180" cy="200" r="16" fill="#EF4444"/>
          <text x="180" y="204" fill="#FFFFFF" font-family="'JetBrains Mono'" font-size="10" font-weight="800" text-anchor="middle">29</text>
          <text x="180" y="170" font-family="'Plus Jakarta Sans'" font-size="12" font-weight="800" fill="#B91C1C" text-anchor="middle">WEST (Gandhi Chowk)</text>
          <text x="180" y="230" font-family="sans-serif" font-size="10" fill="#4B5563" text-anchor="middle">Mahesh Yadav • 3 Clusters</text>
        </g>
      </svg>
    </div>
  `;
}

function filterMapSector(sector, btnElement) {
  document.querySelectorAll('.sector-btn').forEach(b => b.classList.remove('active'));
  if (btnElement) {
    btnElement.classList.add('active');
  } else {
    const matchingBtn = Array.from(document.querySelectorAll('.sector-btn')).find(b => b.getAttribute('onclick')?.includes(sector));
    if (matchingBtn) matchingBtn.classList.add('active');
  }

  const cards = document.querySelectorAll('.zone-card');
  cards.forEach(card => {
    const title = card.querySelector('.zone-title')?.innerText.toLowerCase() || '';
    if (sector === 'all' || title.includes(sector)) {
      card.style.display = 'block';
      card.style.border = sector === 'all' ? '1px solid var(--border-color)' : '2px solid var(--primary-red)';
    } else {
      card.style.display = 'none';
    }
  });

  if (khammamMap) {
    if (sector === 'all') {
      khammamMap.setView([17.2472, 80.1514], 13);
    } else {
      const targetZone = ZONES.find(z => z.id === sector);
      if (targetZone) {
        khammamMap.flyTo(targetZone.coords, 14.5, { animate: true, duration: 1.0 });
      }
    }
  }
}

// 11. Live Clock
function updateClock() {
  const now = new Date();
  const options = { timeZone: 'Asia/Kolkata', hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true };
  const timeStr = now.toLocaleTimeString('en-US', options);
  document.getElementById('live-time').innerText = `${timeStr} IST`;
}

// Initialize on Load
window.addEventListener('DOMContentLoaded', () => {
  renderShops();
  renderZones();
  renderDispatchFeed();
  updateKPIs();
  updateClock();
  initKhammamMap();
  setInterval(updateClock, 1000);
});
