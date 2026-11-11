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
    route: 'Bypass Hub ➔ Sri Sai PG ➔ Kakatiya Girls ➔ Collectorate Quarters'
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
    route: 'Wyra Road Hub ➔ Green Valley ➔ Sri Chaitanya ➔ Vijaya Towers'
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
    route: 'East Hub ➔ Bus Stand Gate ➔ Mamata Quarters ➔ Krishna Residency'
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
    route: 'West Hub ➔ Gayatri Towers ➔ Mayuri Centre ➔ Rotary Nagar'
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
  });
});

// 9. Live Clock
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
  setInterval(updateClock, 1000);
});
