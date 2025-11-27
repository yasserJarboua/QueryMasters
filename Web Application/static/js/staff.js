// staff.js - Enhanced staff analytics display

document.addEventListener('DOMContentLoaded', function() {
    loadStaffShare();
});

async function loadStaffShare() {
    const tbody = document.getElementById('staff-table-body');
    tbody.innerHTML = '<tr><td colspan="4" class="loading">Loading staff analytics</td></tr>';
    
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
        
        tbody.innerHTML = staffData.map((staff, index) => {
            // Determine color based on share percentage
            let shareColor = 'var(--accent-blue)';
            if (staff["Percentage Share within the Hospital"] > 20) {
                shareColor = 'var(--accent-red)';
            } else if (staff["Percentage Share within the Hospital"]> 15) {
                shareColor = 'var(--accent-orange)';
            } else if (staff["Percentage Share within the Hospital"] > 10) {
                shareColor = 'var(--accent-green)';
            }
            
            return `
                <tr>
                    <td>
                        <div style="font-weight: 600; color: var(--text-primary);">${staff["Staff FullName"]}</div>
                    </td>
                    <td>${staff["Hospital Name"]}</td>
                    <td>
                        <div style="font-weight: 600; color: var(--text-primary);">${staff["Total Appointments"]}</div>
                    </td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 0.75rem;">
                            <div style="flex: 1; background: var(--bg-tertiary); height: 8px; border-radius: 10px; overflow: hidden;">
                                <div style="width: ${Math.min(staff["Percentage Share within the Hospital"], 100)}%; height: 100%; background: ${shareColor}; transition: width 1s ease;"></div>
                            </div>
                            <div style="font-weight: 700; color: ${shareColor}; min-width: 60px; text-align: right;">
                                ${staff["Percentage Share within the Hospital"]}%
                            </div>
                        </div>
                    </td>
                </tr>
            `;
        }).join('');
        
        // Animate progress bars
        setTimeout(() => {
            const bars = tbody.querySelectorAll('div[style*="width:"]');
            bars.forEach(bar => {
                bar.style.transition = 'width 1s ease';
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