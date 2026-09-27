// 30-Day Work Emotion & Resignation Tracker State Management (Single Emotion Selection)
const STORAGE_KEY = 'resignation_tracker_single_slot_v2';
const VERDICT_KEY = 'resignation_tracker_verdict_v2';

// Initial state
let entries = [];
let activeDay = 1;
let currentSelectedEmotion = null; // Single selected emotion per day ('fcuk', 'fire', 'happy', or null)
let manualVerdictOverride = null; // 'quit', 'stay', or null

const EMOTIONS = {
  fcuk: { id: 'fcuk', title: 'FCUK!!', emoji: '🤬', subtitle: 'Overwhelmed / WTF moment', class: 'fcuk' },
  fire: { id: 'fire', title: 'On Fire', emoji: '🔥', subtitle: 'Fierce anger & friction', class: 'fire' },
  happy: { id: 'happy', title: 'Happy Chick', emoji: '🐥', subtitle: 'Good vibes & peaceful progress', class: 'happy' }
};

// Initialize App
document.addEventListener('DOMContentLoaded', () => {
  loadData();
  renderGrid();
  renderLegendCounts();
  updateProgressRing();
  renderVerdictSlot();
  renderAnalytics();
  
  // Tab switching
  document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', (e) => {
      document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      
      const tab = btn.dataset.tab;
      document.getElementById('view-grid').style.display = tab === 'grid' ? 'block' : 'none';
      document.getElementById('view-analytics').style.display = tab === 'analytics' ? 'block' : 'none';
      document.getElementById('view-guide').style.display = tab === 'guide' ? 'block' : 'none';
      
      if (tab === 'analytics') renderAnalytics();
    });
  });
});

function loadData() {
  const raw = localStorage.getItem(STORAGE_KEY);
  if (raw) {
    try {
      entries = JSON.parse(raw);
    } catch (e) {
      initFreshEntries();
    }
  } else {
    initFreshEntries();
  }
  
  manualVerdictOverride = localStorage.getItem(VERDICT_KEY);
}

function initFreshEntries() {
  entries = [];
  for (let i = 1; i <= 30; i++) {
    entries.push({ day: i, emotion: null, note: '' });
  }
  manualVerdictOverride = null;
  localStorage.removeItem(VERDICT_KEY);
  saveData();
}

function saveData() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
  if (manualVerdictOverride) {
    localStorage.setItem(VERDICT_KEY, manualVerdictOverride);
  } else {
    localStorage.removeItem(VERDICT_KEY);
  }
  renderGrid();
  renderLegendCounts();
  updateProgressRing();
  renderVerdictSlot();
}

// Render 30 Day Grid (Single Emotion per Day)
function renderGrid() {
  const container = document.getElementById('grid-container');
  if (!container) return;
  
  container.innerHTML = '';
  
  entries.forEach(entry => {
    const card = document.createElement('div');
    card.className = `day-card ${entry.emotion ? 'filled' : ''}`;
    card.onclick = () => openPicker(entry.day);
    
    let slotsHtml = '';
    if (!entry.emotion) {
      slotsHtml = `
        <div class="empty-placeholder">
          <span style="font-size:16px">+</span>
          <span>Log Vibe</span>
        </div>
      `;
    } else {
      const em = EMOTIONS[entry.emotion];
      if (em) {
        slotsHtml = `
          <div style="display:flex; align-items:center; gap:6px">
            <div class="slot-badge ${em.class}">${em.emoji}</div>
            <span style="font-size:11px; font-weight:700; color:#fff">${em.title}</span>
          </div>
        `;
      }
    }
    
    card.innerHTML = `
      <div class="day-card-header">
        <span class="day-num">DAY ${entry.day}</span>
        ${entry.note ? '<div class="note-dot"></div>' : ''}
      </div>
      <div class="day-slots">
        ${slotsHtml}
      </div>
    `;
    
    container.appendChild(card);
  });
}

// Auto-Computing Verdict Calculation Logic
function computeVerdict() {
  const counts = getEmotionCounts();
  const negativeTotal = counts.fcuk + counts.fire;
  const positiveTotal = counts.happy;
  
  if (counts.total === 0) {
    return { verdict: null, negativeTotal, positiveTotal, isAuto: true };
  }
  
  // Rule: If (FCUK + On Fire) > Happy Chick -> FCUK THIS I QUIT!!
  // Else if Happy Chick >= (FCUK + On Fire) -> I WILL STAY for now
  const computed = negativeTotal > positiveTotal ? 'quit' : 'stay';
  
  return {
    verdict: manualVerdictOverride || computed,
    autoVerdict: computed,
    negativeTotal,
    positiveTotal,
    isManualOverride: !!manualVerdictOverride
  };
}

function renderVerdictSlot() {
  const displayEl = document.getElementById('verdict-status-display');
  const cardEl = document.querySelector('.triangle-verdict-card');
  if (!displayEl) return;
  
  const status = computeVerdict();
  
  if (cardEl) {
    cardEl.classList.remove('verdict-stay', 'verdict-quit');
  }
  
  if (status.verdict === 'quit') {
    if (cardEl) cardEl.classList.add('verdict-quit');
    displayEl.innerHTML = `
      <div style="font-size:10px; font-weight:800; font-family:monospace; text-transform:uppercase; letter-spacing:1px; color:#fca5a5; margin-bottom:4px">
        ⚡ ${status.isManualOverride ? 'MANUAL OVERRIDE' : 'AUTO-COMPUTED VERDICT'} (🤬+🔥: ${status.negativeTotal} > 🐥: ${status.positiveTotal})
      </div>
      <div class="verdict-status-text" style="color:#ff3b30">
        💣 FCUK THIS I QUIT!! 🤬💣
      </div>
      <div style="font-size:11px; color:#fca5a5; margin-top:4px">
        ${status.negativeTotal} Stress/Rage days vs ${status.positiveTotal} Happy Chick days
      </div>
    `;
  } else if (status.verdict === 'stay') {
    if (cardEl) cardEl.classList.add('verdict-stay');
    displayEl.innerHTML = `
      <div style="font-size:10px; font-weight:800; font-family:monospace; text-transform:uppercase; letter-spacing:1px; color:#7dd3fc; margin-bottom:4px">
        ⚡ ${status.isManualOverride ? 'MANUAL OVERRIDE' : 'AUTO-COMPUTED VERDICT'} (🐥: ${status.positiveTotal} ≥ 🤬+🔥: ${status.negativeTotal})
      </div>
      <div class="verdict-stay-text">
        🛡️ I WILL STAY <span class="for-now">for now</span>
      </div>
      <div style="font-size:11px; color:#7dd3fc; margin-top:4px">
        ${status.positiveTotal} Happy Chick days vs ${status.negativeTotal} Stress/Rage days
      </div>
    `;
  } else {
    displayEl.innerHTML = `
      <div style="font-size:12px; font-weight:700; color:var(--text-secondary); margin-top:4px">
        Log 30-day slots to auto-compute final verdict
      </div>
    `;
  }
}

function openVerdictPicker() {
  document.getElementById('modal-verdict-overlay').classList.add('active');
  renderVerdictModalOptions();
}

function closeVerdictPicker() {
  document.getElementById('modal-verdict-overlay').classList.remove('active');
}

function renderVerdictModalOptions() {
  const container = document.getElementById('verdict-options-container');
  if (!container) return;
  
  const status = computeVerdict();
  
  container.innerHTML = `
    <div class="verdict-card-option option-quit ${status.verdict === 'quit' ? 'selected-quit' : ''}" onclick="selectVerdict('quit')">
      <div style="font-size:32px">💣</div>
      <div style="flex:1">
        <div style="display:flex; justify-content:space-between; align-items:center">
          <div style="font-size:16px; font-weight:800; color:#ff3b30">FCUK THIS I QUIT!! 🤬💣</div>
          ${status.autoVerdict === 'quit' ? '<span style="font-size:9px; font-weight:800; padding:3px 8px; border-radius:10px; background:#ff3b30; color:#fff">AUTO-RECOMMENDED</span>' : ''}
        </div>
        <div style="font-size:11px; color:#fca5a5; margin-top:2px">Triggered when FCUK!! 🤬 + On Fire 🔥 (${status.negativeTotal}) > Happy Chick 🐥 (${status.positiveTotal})</div>
      </div>
    </div>
    
    <div class="verdict-card-option option-stay ${status.verdict === 'stay' ? 'selected-stay' : ''}" onclick="selectVerdict('stay')">
      <div style="font-size:32px">🛡️</div>
      <div style="flex:1">
        <div style="display:flex; justify-content:space-between; align-items:center">
          <div class="verdict-stay-text">
            I WILL STAY <span class="for-now">for now</span>
          </div>
          ${status.autoVerdict === 'stay' ? '<span style="font-size:9px; font-weight:800; padding:3px 8px; border-radius:10px; background:#38bdf8; color:#000">AUTO-RECOMMENDED</span>' : ''}
        </div>
        <div style="font-size:11px; color:#7dd3fc; margin-top:2px">Triggered when Happy Chick 🐥 (${status.positiveTotal}) ≥ FCUK!! 🤬 + On Fire 🔥 (${status.negativeTotal})</div>
      </div>
    </div>
    
    ${status.isManualOverride ? `
      <button onclick="resetToAutoVerdict()" style="width:100%; padding:10px; border-radius:12px; background:rgba(255,255,255,0.06); border:1px solid rgba(255,255,255,0.15); color:var(--text-secondary); font-size:12px; font-weight:600; cursor:pointer; margin-top:8px">
        ↺ Reset to Auto-Computed Verdict
      </button>
    ` : ''}
  `;
}

function selectVerdict(val) {
  manualVerdictOverride = val;
  saveData();
  closeVerdictPicker();
}

function resetToAutoVerdict() {
  manualVerdictOverride = null;
  localStorage.removeItem(VERDICT_KEY);
  saveData();
  closeVerdictPicker();
}

function renderLegendCounts() {
  const counts = getEmotionCounts();
  document.getElementById('count-fcuk').textContent = counts.fcuk;
  document.getElementById('count-fire').textContent = counts.fire;
  document.getElementById('count-happy').textContent = counts.happy;
}

function updateProgressRing() {
  const filledCount = entries.filter(e => e.emotion !== null).length;
  document.getElementById('progress-text').textContent = `${filledCount}/30`;
  
  const circle = document.getElementById('progress-val');
  if (circle) {
    const circumference = 2 * Math.PI * 22;
    const offset = circumference - (filledCount / 30) * circumference;
    circle.style.strokeDasharray = `${circumference} ${circumference}`;
    circle.style.strokeDashoffset = offset;
  }
}

// Modal Picker Sheet for Day Entries (Single Selection)
function openPicker(dayNum) {
  activeDay = dayNum;
  const entry = entries.find(e => e.day === dayNum) || { emotion: null, note: '' };
  currentSelectedEmotion = entry.emotion;
  
  document.getElementById('sheet-day-title').textContent = `Day ${dayNum} Vibe Log`;
  document.getElementById('note-input').value = entry.note || '';
  
  renderOptionList();
  renderSlotPreview();
  
  document.getElementById('modal-overlay').classList.add('active');
}

function closePicker() {
  document.getElementById('modal-overlay').classList.remove('active');
}

function renderOptionList() {
  const container = document.getElementById('options-container');
  container.innerHTML = '';
  
  Object.values(EMOTIONS).forEach(em => {
    const isSelected = currentSelectedEmotion === em.id;
    
    const div = document.createElement('div');
    div.className = `emotion-option ${isSelected ? 'selected' : ''}`;
    
    div.onclick = () => {
      toggleEmotionSlot(em.id);
    };
    
    div.innerHTML = `
      <div class="emotion-left">
        <div class="emotion-icon-lg ${em.class}">${em.emoji}</div>
        <div class="emotion-info">
          <h3>${em.title}</h3>
          <p>${em.subtitle}</p>
        </div>
      </div>
      <div style="font-size:18px; color:${isSelected ? '#ff9500' : 'rgba(255,255,255,0.3)'}">
        ${isSelected ? '✓' : '○'}
      </div>
    `;
    
    container.appendChild(div);
  });
}

function toggleEmotionSlot(emId) {
  if (currentSelectedEmotion === emId) {
    currentSelectedEmotion = null;
  } else {
    currentSelectedEmotion = emId;
  }
  renderOptionList();
  renderSlotPreview();
}

function renderSlotPreview() {
  const container = document.getElementById('slots-preview');
  container.innerHTML = '';
  
  const box = document.createElement('div');
  box.className = `slot-box ${currentSelectedEmotion ? 'active' : ''}`;
  
  if (currentSelectedEmotion) {
    const em = EMOTIONS[currentSelectedEmotion];
    box.className += ` ${em.class}`;
    box.innerHTML = `${em.emoji} ${em.title} (Selected)`;
  } else {
    box.textContent = `No Emotion Selected`;
  }
  
  container.appendChild(box);
}

function saveCurrentDay() {
  const entryIndex = entries.findIndex(e => e.day === activeDay);
  if (entryIndex !== -1) {
    entries[entryIndex].emotion = currentSelectedEmotion;
    entries[entryIndex].note = document.getElementById('note-input').value.trim();
    saveData();
  }
  closePicker();
}

function getEmotionCounts() {
  let fcuk = 0, fire = 0, happy = 0;
  entries.forEach(e => {
    if (e.emotion === 'fcuk') fcuk++;
    if (e.emotion === 'fire') fire++;
    if (e.emotion === 'happy') happy++;
  });
  return { fcuk, fire, happy, total: fcuk + fire + happy };
}

function renderAnalytics() {
  const counts = getEmotionCounts();
  const total = counts.total;
  
  // Balance Score Calculation
  let score = 50;
  if (total > 0) {
    score = Math.round((counts.happy * 100 + counts.fire * 40 + counts.fcuk * 0) / total);
  }
  
  document.getElementById('analytics-score').textContent = score;
  
  // Verdict Analytics Display
  const status = computeVerdict();
  const analyticsVerdictDisplay = document.getElementById('analytics-verdict-display');
  
  if (analyticsVerdictDisplay) {
    if (status.verdict === 'quit') {
      analyticsVerdictDisplay.innerHTML = `
        <div style="padding:16px; border-radius:16px; background:rgba(255,59,48,0.2); border:1.5px solid #ff3b30; text-align:center">
          <div style="font-size:10px; font-weight:800; font-family:monospace; text-transform:uppercase; color:#fca5a5; margin-bottom:4px">
            ⚡ ${status.isManualOverride ? 'MANUAL OVERRIDE' : 'AUTO-COMPUTED VERDICT'}
          </div>
          <div style="font-size:18px; font-weight:900; color:#ff3b30">💣 FCUK THIS I QUIT!! 🤬💣</div>
          <div style="font-size:12px; color:#fca5a5; margin-top:4px">Stress/Rage (🤬+🔥: ${status.negativeTotal}) > Happy Chick (🐥: ${status.positiveTotal})</div>
        </div>
      `;
    } else if (status.verdict === 'stay') {
      analyticsVerdictDisplay.innerHTML = `
        <div style="padding:16px; border-radius:16px; background:rgba(56,189,248,0.18); border:1.5px solid #38bdf8; text-align:center">
          <div style="font-size:10px; font-weight:800; font-family:monospace; text-transform:uppercase; color:#7dd3fc; margin-bottom:4px">
            ⚡ ${status.isManualOverride ? 'MANUAL OVERRIDE' : 'AUTO-COMPUTED VERDICT'}
          </div>
          <div class="verdict-stay-text" style="font-size:18px">
            🛡️ I WILL STAY <span class="for-now">for now</span>
          </div>
          <div style="font-size:12px; color:#7dd3fc; margin-top:4px">Happy Chick (🐥: ${status.positiveTotal}) ≥ Stress/Rage (🤬+🔥: ${status.negativeTotal})</div>
        </div>
      `;
    } else {
      analyticsVerdictDisplay.innerHTML = `
        <div style="font-size:12px; color:var(--text-secondary); text-align:center">Log day slots to auto-compute final verdict.</div>
      `;
    }
  }
  
  // Emotion Bars
  const fcukPct = total > 0 ? Math.round((counts.fcuk / total) * 100) : 0;
  const firePct = total > 0 ? Math.round((counts.fire / total) * 100) : 0;
  const happyPct = total > 0 ? Math.round((counts.happy / total) * 100) : 0;
  
  document.getElementById('bar-fcuk-text').textContent = `${counts.fcuk} days (${fcukPct}%)`;
  document.getElementById('bar-fcuk-fill').style.width = `${fcukPct}%`;
  
  document.getElementById('bar-fire-text').textContent = `${counts.fire} days (${firePct}%)`;
  document.getElementById('bar-fire-fill').style.width = `${firePct}%`;
  
  document.getElementById('bar-happy-text').textContent = `${counts.happy} days (${happyPct}%)`;
  document.getElementById('bar-happy-fill').style.width = `${happyPct}%`;
}

function resetData() {
  if (confirm('Reset all 30 days of logged emotions and verdict?')) {
    initFreshEntries();
    renderAnalytics();
  }
}
