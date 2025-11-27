// Staff Analytics - Ordered by Percentage Share (Descending)

document.addEventListener('DOMContentLoaded', function() {
    loadStaffShare();
});

async function loadStaffShare() {
    const tbody = document.getElementById('staff-table-body');
    tbody.innerHTML = '<tr><td colspan="4" class="loading">Loading staff analytics...</td></tr>';
    
    try {
        const response = await fetch('/api/staff/share');
        
        if (!response.ok) {
            throw new Error('Failed to load staff data');
        }
        
        const staffData = await response.json();
        
        if (staffData.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="4" style="text-align: center; padding: 2rem; color: var(--text-muted);">
                        No staff data available
                    </td>
                </tr>
            `;
            return;
        }
        
        // Sort by percentage (descending) - data should already be sorted from backend
        // But we ensure it here as well
        staffData.sort((a, b) => {
            const percentA = a['Percentage Share within the Hospital'] || 0;
            const percentB = b['Percentage Share within the Hospital'] || 0;
            return percentB - percentA;
        });
        
        tbody.innerHTML = staffData.map((staff, index) => {
            const percentage = staff['Percentage Share within the Hospital'] || 0;
            console.log(percentage)
            // Determine color based on workload
            let shareColor = '#5b8dd6';
            let workloadText = 'Normal';
            
            if (percentage > 20) {
                shareColor = '#d66969';
                workloadText = 'High Load';
            } else if (percentage > 15) {
                shareColor = '#d4905d';
                workloadText = 'Above Average';
            } else if (percentage > 10) {
                shareColor = '#58a182';
                workloadText = 'Good';
            }
            
            return `
                <tr>
                    <td>
                        <div style="font-weight: 600; color: var(--text-primary);">
                            ${staff['Staff FullName']}
                        </div>
                        <div style="font-size: 0.75rem; color: var(--text-muted); margin-top: 0.25rem;">
                            ${workloadText}
                        </div>
                    </td>
                    <td style="color: var(--text-secondary);">
                        ${staff['Hospital Name']}
                    </td>
                    <td>
                        <div style="font-weight: 600; color: var(--text-primary); font-size: 1.125rem;">
                            ${staff['Total Appointments']}
                        </div>
                    </td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 0.75rem;">
                            <div style="flex: 1; background: var(--bg-primary); height: 10px; border-radius: 5px; overflow: hidden;">
                                <div style="width: ${Math.min(percentage, 100)}%; height: 100%; background: ${shareColor}; transition: width 1s ease;"></div>
                            </div>
                            <div style="font-weight: 700; color: ${shareColor}; min-width: 60px; text-align: right; font-size: 1.125rem;">
                                ${parseFloat(percentage).toFixed(1)}%
                            </div>
                        </div>
                    </td>
                </tr>
            `;
        }).join('');
        
        // Animate progress bars after a short delay
        setTimeout(() => {
            const bars = tbody.querySelectorAll('div[style*="transition: width"]');
            bars.forEach((bar, index) => {
                bar.style.width = '0%';
                setTimeout(() => {
                    const width = bar.getAttribute('data-width') || bar.style.width;
                    bar.style.width = width;
                }, index * 100);
            });
        }, 100);
        
    } catch (error) {
        console.error('Error loading staff data:', error);
        tbody.innerHTML = `
            <tr>
                <td colspan="4" style="text-align: center; padding: 2rem; color: var(--accent-red);">
                    Error loading staff analytics. Please try again.
                </td>
            </tr>
        `;
    }
}