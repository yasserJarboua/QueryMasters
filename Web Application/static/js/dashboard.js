document.addEventListener('DOMContentLoaded', function() {
    loadDashboardStats();
    loadRecentPatients();
    loadCriticalStock();
});

// Load dashboard statistics
async function loadDashboardStats() {
    try {
        const response = await fetch('/api/dashboard/stats');
        const stats = await response.json();

        animateValue('total-patients', 0, stats.total_patients, 1000);
        animateValue('total-staff', 0, stats.total_staff, 1000);
        animateValue('total-appointments', 0, stats.total_appointments, 1000);
        animateValue('low-stock-count', 0, stats.low_stock_count, 1000);

    } catch (error) {
        console.error('Error loading dashboard stats:', error);
    }
}

// Animate number counter
function animateValue(id, start, end, duration) {
    const element = document.getElementById(id);
    const range = end - start;
    const increment = range / (duration / 16);
    let current = start;

    const timer = setInterval(() => {
        current += increment;
        if ((increment > 0 && current >= end) || (increment < 0 && current <= end)) {
            current = end;
            clearInterval(timer);
        }
        element.textContent = Math.floor(current).toLocaleString();
    }, 16);
}

// Load recent patients
async function loadRecentPatients() {
    const container = document.getElementById('recent-patients-list');

    try {
        const response = await fetch('/api/dashboard/recent-patients?limit=5');
        const patients = await response.json();

        if (patients.length === 0) {
            container.innerHTML = '<p style="color: var(--text-muted); text-align: center;">No patients found</p>';
            return;
        }

        container.innerHTML = patients.map(p => `
            <div style="padding: 0.75rem 0; border-bottom: 1px solid rgba(30,39,64,0.5); display:flex; justify-content:space-between;">
                <div>
                    <div style="font-weight:600; color: var(--text-primary);">${p.FullName}</div>
                    <div style="font-size:0.85rem; color:var(--text-muted);">
                        ${(p.Sex === 'M' ? '👨' : '👩')} ${p.Phone}
                    </div>
                </div>
                <div style="font-size:0.85rem; color:var(--text-muted);">
                    ID: ${p.IID}
                </div>
            </div>
        `).join('');

        // Remove last border
        const items = container.querySelectorAll('div[style*="border-bottom"]');
        if (items.length > 0) items[items.length - 1].style.borderBottom = 'none';

    } catch (error) {
        console.error('Error loading recent patients:', error);
        container.innerHTML = '<p style="color: var(--accent-red); text-align:center;">Error loading data</p>';
    }
}

// Load critical stock items
async function loadCriticalStock() {
    const container = document.getElementById('critical-stock-list');

    try {
        const response = await fetch('/api/dashboard/critical-stock?limit=5');
        const items = await response.json();

        if (items.length === 0) {
            container.innerHTML = '<p style="color: var(--accent-green); text-align:center;">✓ All stocks OK</p>';
            return;
        }

        container.innerHTML = items.map(item => {
            const deficit = item.ReorderLevel - item.Quantity;
            const urgency = deficit > 10 ? 'var(--accent-red)' : 'var(--accent-orange)';

            return `
                <div style="padding:0.75rem 0; border-bottom:1px solid rgba(30,39,64,0.5);">
                    <div style="display:flex; justify-content:space-between;">
                        <div>
                            <div style="font-weight:600; color:var(--text-primary);">${item.MedicationName}</div>
                            <div style="font-size:0.85rem; color:var(--text-muted);">${item.HospitalName}</div>
                        </div>
                        <div style="text-align:right;">
                            <div style="font-weight:600; color:${urgency};">
                                ${item.Quantity} / ${item.ReorderLevel}
                            </div>
                            <div style="font-size:0.75rem; color:var(--text-muted);">
                                Need ${deficit} more
                            </div>
                        </div>
                    </div>
                </div>
            `;
        }).join('');

        // Remove last border
        const itemsDiv = container.querySelectorAll('div[style*="border-bottom"]');
        if (itemsDiv.length > 0) itemsDiv[itemsDiv.length - 1].style.borderBottom = 'none';

    } catch (error) {
        console.error('Error loading critical stock:', error);
        container.innerHTML = '<p style="color:var(--accent-red); text-align:center;">Error loading stock</p>';
    }
}