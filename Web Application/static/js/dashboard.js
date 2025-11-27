// Dashboard with REAL data from database

let appointmentsChart = null;
let genderChart = null;
let staffChart = null;
let stockChart = null;

document.addEventListener('DOMContentLoaded', function() {
    loadDashboardStats();
    loadRecentPatients();
    loadCriticalStock();
    loadTopStaff();
    initializeCharts();
});

// ==================== LOAD STATISTICS ====================
async function loadDashboardStats() {
    try {
        const response = await fetch('/api/dashboard/stats');
        const stats = await response.json();

        animateValue('total-patients', 0, stats.total_patients || 0, 1500);
        animateValue('total-staff', 0, stats.total_staff || 0, 1500);
        animateValue('total-appointments', 0, stats.total_appointments || 0, 1500);
        animateValue('low-stock-count', 0, stats.low_stock_count || 0, 1500);

    } catch (error) {
        console.error('Error loading dashboard stats:', error);
        document.getElementById('total-patients').textContent = '0';
        document.getElementById('total-staff').textContent = '0';
        document.getElementById('total-appointments').textContent = '0';
        document.getElementById('low-stock-count').textContent = '0';
    }
}

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

// ==================== INITIALIZE CHARTS WITH REAL DATA ====================
async function initializeCharts() {
    Chart.defaults.color = '#b0b8c1';
    Chart.defaults.borderColor = '#2d333b';
    Chart.defaults.font.family = 'Inter, sans-serif';

    // 1. Appointments Trend Chart - REAL DATA FROM DATABASE
    try {
        const appointmentsResponse = await fetch('/api/dashboard/appointments-trend?months=6');
        const appointmentsData = await appointmentsResponse.json();
        
        const appointmentsCtx = document.getElementById('appointmentsChart');
        
        // Format month labels (e.g., "2024-01" -> "January 2024")
        const monthLabels = appointmentsData.months.map(monthStr => {
            const [year, month] = monthStr.split('-');
            const date = new Date(year, parseInt(month) - 1);
            return date.toLocaleDateString('en-US', { month: 'long', year: 'numeric' });
        });
        
        appointmentsChart = new Chart(appointmentsCtx, {
            type: 'line',
            data: {
                labels: monthLabels,
                datasets: [{
                    label: 'Appointments',
                    data: appointmentsData.counts,
                    borderColor: '#5b8dd6',
                    backgroundColor: 'rgba(91, 141, 214, 0.1)',
                    tension: 0.4,
                    fill: true,
                    pointBackgroundColor: '#5b8dd6',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 4,
                    pointHoverRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#1a1f26',
                        borderColor: '#2d333b',
                        borderWidth: 1,
                        padding: 12,
                        displayColors: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: '#2d333b' },
                        ticks: { 
                            color: '#b0b8c1',
                            stepSize: 1
                        }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { color: '#b0b8c1' }
                    }
                }
            }
        });
    } catch (error) {
        console.error('Error loading appointments chart:', error);
    }

    // 2. Gender Distribution Chart
    try {
        const genderResponse = await fetch('/api/dashboard/gender-distribution');
        const genderData = await genderResponse.json();
        
        const genderCtx = document.getElementById('genderChart');
        genderChart = new Chart(genderCtx, {
            type: 'doughnut',
            data: {
                labels: ['Male', 'Female'],
                datasets: [{
                    data: [genderData.male || 0, genderData.female || 0],
                    backgroundColor: ['#5b8dd6', '#9b8ad6'],
                    borderColor: '#1a1f26',
                    borderWidth: 2
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            color: '#b0b8c1',
                            padding: 15,
                            font: { size: 12 }
                        }
                    },
                    tooltip: {
                        backgroundColor: '#1a1f26',
                        borderColor: '#2d333b',
                        borderWidth: 1,
                        padding: 12
                    }
                }
            }
        });
    } catch (error) {
        console.error('Error loading gender chart:', error);
    }

    // 3. Staff Distribution Chart
    try {
        const staffResponse = await fetch('/api/dashboard/staff-distribution');
        const staffData = await staffResponse.json();
        
        const staffCtx = document.getElementById('staffChart');
        staffChart = new Chart(staffCtx, {
            type: 'bar',
            data: {
                labels: staffData.departments || [],
                datasets: [{
                    label: 'Staff Count',
                    data: staffData.counts || [],
                    backgroundColor: '#58a182',
                    borderColor: '#58a182',
                    borderWidth: 0,
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#1a1f26',
                        borderColor: '#2d333b',
                        borderWidth: 1,
                        padding: 12
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: { color: '#2d333b' },
                        ticks: { 
                            color: '#b0b8c1',
                            stepSize: 1
                        }
                    },
                    x: {
                        grid: { display: false },
                        ticks: { color: '#b0b8c1' }
                    }
                }
            }
        });
    } catch (error) {
        console.error('Error loading staff chart:', error);
    }

    // 4. Stock Status Chart
    try {
        const stockResponse = await fetch('/api/dashboard/stock-status');
        const stockData = await stockResponse.json();
        
        const stockCtx = document.getElementById('stockChart');
        stockChart = new Chart(stockCtx, {
            type: 'bar',
            data: {
                labels: ['Critical', 'Low', 'Normal', 'High'],
                datasets: [{
                    label: 'Items',
                    data: stockData.levels || [0, 0, 0, 0],
                    backgroundColor: ['#d66969', '#d4905d', '#58a182', '#5b8dd6'],
                    borderWidth: 0,
                    borderRadius: 6
                }]
            },
            options: {
                indexAxis: 'y',
                responsive: true,
                maintainAspectRatio: true,
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        backgroundColor: '#1a1f26',
                        borderColor: '#2d333b',
                        borderWidth: 1,
                        padding: 12
                    }
                },
                scales: {
                    x: {
                        beginAtZero: true,
                        grid: { color: '#2d333b' },
                        ticks: { 
                            color: '#b0b8c1',
                            stepSize: 1
                        }
                    },
                    y: {
                        grid: { display: false },
                        ticks: { color: '#b0b8c1' }
                    }
                }
            }
        });
    } catch (error) {
        console.error('Error loading stock chart:', error);
    }
}

// ==================== RECENT PATIENTS ====================
async function loadRecentPatients() {
    const container = document.getElementById('recent-patients-list');

    try {
        const response = await fetch('/api/dashboard/recent-patients?limit=5');
        const patients = await response.json();

        if (patients.length === 0) {
            container.innerHTML = '<p style="color: var(--text-muted); text-align: center; padding: 1rem;">No patients found</p>';
            return;
        }

        container.innerHTML = patients.map(p => `
            <div style="padding: 0.875rem; background: var(--bg-tertiary); border-radius: 6px; border: 1px solid var(--border-color); margin-bottom: 0.75rem;">
                <div style="display: flex; justify-content: space-between; align-items: center;">
                    <div style="flex: 1;">
                        <div style="font-weight: 600; color: var(--text-primary); margin-bottom: 0.25rem;">
                            ${p.FullName}
                        </div>
                        <div style="font-size: 0.8125rem; color: var(--text-muted);">
                            ${p.Sex === 'M' ? '👨 Male' : '👩 Female'} • ${p.Phone || 'N/A'}
                        </div>
                    </div>
                    <div style="text-align: right;">
                        <div style="font-size: 0.75rem; color: var(--text-muted);">ID</div>
                        <div style="font-weight: 600; color: var(--accent-blue);">#${p.IID}</div>
                    </div>
                </div>
            </div>
        `).join('');

    } catch (error) {
        console.error('Error loading recent patients:', error);
        container.innerHTML = '<p style="color: var(--accent-red); text-align: center;">Error loading patients</p>';
    }
}

// ==================== CRITICAL STOCK ====================
async function loadCriticalStock() {
    const container = document.getElementById('critical-stock-list');

    try {
        const response = await fetch('/api/dashboard/critical-stock?limit=5');
        const items = await response.json();

        if (items.length === 0) {
            container.innerHTML = `
                <div style="text-align: center; padding: 2rem;">
                    <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">✓</div>
                    <p style="color: var(--accent-green); font-weight: 600;">All stock levels are good</p>
                </div>
            `;
            return;
        }

        container.innerHTML = items.map(item => {
            const deficit = item.ReorderLevel - item.Quantity;
            const percentage = (item.Quantity / item.ReorderLevel) * 100;
            
            let urgencyColor = '#d66969';
            let urgencyText = 'Critical';
            if (percentage >= 50) {
                urgencyColor = '#d4905d';
                urgencyText = 'Low';
            }

            return `
                <div style="padding: 0.875rem; background: var(--bg-tertiary); border-radius: 6px; border: 1px solid var(--border-color); margin-bottom: 0.75rem;">
                    <div style="display: flex; justify-content: space-between; align-items: start; margin-bottom: 0.5rem;">
                        <div style="flex: 1;">
                            <div style="font-weight: 600; color: var(--text-primary); margin-bottom: 0.25rem;">
                                ${item.MedicationName}
                            </div>
                            <div style="font-size: 0.8125rem; color: var(--text-muted);">
                                ${item.HospitalName}
                            </div>
                        </div>
                        <div style="text-align: right;">
                            <div style="font-weight: 700; color: ${urgencyColor};">
                                ${item.Quantity}
                            </div>
                            <div style="font-size: 0.75rem; color: var(--text-muted);">of ${item.ReorderLevel}</div>
                        </div>
                    </div>
                    <div style="background: var(--bg-primary); height: 6px; border-radius: 3px; overflow: hidden;">
                        <div style="width: ${Math.min(percentage, 100)}%; height: 100%; background: ${urgencyColor}; transition: width 1s ease;"></div>
                    </div>
                    <div style="margin-top: 0.5rem; font-size: 0.75rem;">
                        <span style="color: ${urgencyColor}; font-weight: 600;">${urgencyText}</span>
                        <span style="color: var(--text-muted);"> • Need ${deficit} more units</span>
                    </div>
                </div>
            `;
        }).join('');

    } catch (error) {
        console.error('Error loading critical stock:', error);
        container.innerHTML = '<p style="color: var(--accent-red); text-align: center;">Error loading stock</p>';
    }
}

// ==================== TOP PERFORMING STAFF ====================
async function loadTopStaff() {
    const container = document.getElementById('top-staff-list');

    try {
        const response = await fetch('/api/staff/share?limit=5');
        const staff = await response.json();

        if (staff.length === 0) {
            container.innerHTML = '<p style="color: var(--text-muted); text-align: center; padding: 1rem;">No staff data available</p>';
            return;
        }

        container.innerHTML = `
            <table class="data-table" style="margin-top: 0;">
                <thead>
                    <tr>
                        <th style="width: 40px;">#</th>
                        <th>Staff Name</th>
                        <th>Hospital</th>
                        <th>Appointments</th>
                        <th style="width: 200px;">Share %</th>
                    </tr>
                </thead>
                <tbody>
                    ${staff.slice(0, 5).map((s, index) => {
                        const percentage = s['Percentage Share within the Hospital'] || 0;
                        let barColor = '#5b8dd6';
                        if (percentage > 20) barColor = '#d66969';
                        else if (percentage > 15) barColor = '#d4905d';
                        else if (percentage > 10) barColor = '#58a182';

                        return `
                            <tr>
                                <td style="font-weight: 600; color: var(--text-muted);">${index + 1}</td>
                                <td>
                                    <div style="font-weight: 600; color: var(--text-primary);">
                                        ${s['Staff FullName']}
                                    </div>
                                </td>
                                <td style="color: var(--text-secondary);">${s['Hospital Name']}</td>
                                <td>
                                    <div style="font-weight: 600; color: var(--text-primary);">
                                        ${s['Total Appointments']}
                                    </div>
                                </td>
                                <td>
                                    <div style="display: flex; align-items: center; gap: 0.5rem;">
                                        <div style="flex: 1; background: var(--bg-primary); height: 8px; border-radius: 4px; overflow: hidden;">
                                            <div style="width: ${Math.min(percentage, 100)}%; height: 100%; background: ${barColor}; transition: width 1s ease;"></div>
                                        </div>
                                        <div style="font-weight: 700; color: ${barColor}; min-width: 50px; text-align: right;">
                                            ${parseFloat(percentage).toFixed(1)}%
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        `;
                    }).join('')}
                </tbody>
            </table>
        `;

    } catch (error) {
        console.error('Error loading top staff:', error);
        container.innerHTML = '<p style="color: var(--accent-red); text-align: center;">Error loading staff data</p>';
    }
}