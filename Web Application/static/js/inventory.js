// Low Stock Inventory - Grouped by Hospital for Easy Reading

document.addEventListener('DOMContentLoaded', function() {
    loadLowStock();
});

async function loadLowStock() {
    const container = document.getElementById('stock-table-body');
    container.innerHTML = '<tr><td colspan="4" class="loading">Loading low stock items...</td></tr>';
    
    try {
        const response = await fetch('/api/inventory/low-stock');
        
        if (!response.ok) {
            throw new Error('Failed to load inventory data');
        }
        
        const stockData = await response.json();
        
        if (stockData.length === 0) {
            container.innerHTML = `
                <tr>
                    <td colspan="4" style="text-align: center; padding: 3rem;">
                        <div style="font-size: 3rem; margin-bottom: 1rem;">✓</div>
                        <div style="color: var(--accent-green); font-weight: 600; font-size: 1.2rem;">
                            All stock levels are good!
                        </div>
                        <div style="color: var(--text-muted); margin-top: 0.5rem;">
                            No items below reorder level
                        </div>
                    </td>
                </tr>
            `;
            return;
        }
        
        // Group by hospital
        const groupedByHospital = {};
        stockData.forEach(item => {
            const hospitalName = item.HospitalName;
            if (!groupedByHospital[hospitalName]) {
                groupedByHospital[hospitalName] = [];
            }
            groupedByHospital[hospitalName].push(item);
        });
        
        // Build HTML with hospital groups
        let html = '';
        
        Object.keys(groupedByHospital).forEach((hospitalName, hospitalIndex) => {
            const items = groupedByHospital[hospitalName];
            
            // Hospital Header Row
            html += `
                <tr style="background: var(--bg-tertiary);">
                    <td colspan="4" style="padding: 1rem; border-top: 2px solid var(--border-light);">
                        <div style="display: flex; justify-content: space-between; align-items: center;">
                            <div style="font-weight: 700; font-size: 1.125rem; color: var(--text-primary);">
                                🏥 ${hospitalName}
                            </div>
                            <div style="background: var(--accent-red); color: white; padding: 0.25rem 0.75rem; border-radius: 4px; font-size: 0.875rem; font-weight: 600;">
                                ${items.length} item${items.length !== 1 ? 's' : ''} low
                            </div>
                        </div>
                    </td>
                </tr>
            `;
            
            // Items for this hospital
            items.forEach(item => {
                const deficit = item['Reorder Level'] - item['Quantity'];
                const urgencyPercent = (item['Quantity'] / item['Reorder Level']) * 100;
                
                let urgencyLevel = 'low';
                let urgencyColor = '#d4905d';
                let urgencyText = 'Low Stock';
                let urgencyBg = 'rgba(212, 144, 93, 0.1)';
                
                if (urgencyPercent < 30) {
                    urgencyLevel = 'critical';
                    urgencyColor = '#d66969';
                    urgencyText = 'Critical';
                    urgencyBg = 'rgba(214, 105, 105, 0.1)';
                } else if (urgencyPercent < 60) {
                    urgencyLevel = 'high';
                    urgencyColor = '#d4905d';
                    urgencyText = 'Very Low';
                    urgencyBg = 'rgba(212, 144, 93, 0.1)';
                }
                
                html += `
                    <tr style="background: ${urgencyBg};">
                        <td style="padding-left: 2rem;">
                            <div style="font-weight: 600; color: var(--text-primary);">
                                ${item['Medication Name']}
                            </div>
                            <div style="font-size: 0.75rem; color: ${urgencyColor}; margin-top: 0.25rem; font-weight: 600;">
                                ${urgencyText}
                            </div>
                        </td>
                        <td>
                            <div style="display: flex; align-items: center; gap: 0.75rem;">
                                <div style="flex: 1; background: var(--bg-primary); height: 8px; border-radius: 4px; overflow: hidden; min-width: 80px;">
                                    <div style="width: ${Math.max(urgencyPercent, 5)}%; height: 100%; background: ${urgencyColor}; transition: width 1s ease;"></div>
                                </div>
                                <div style="font-weight: 700; color: ${urgencyColor}; font-size: 1.125rem; min-width: 40px;">
                                    ${item['Quantity']}
                                </div>
                            </div>
                        </td>
                        <td>
                            <div style="font-weight: 600; color: var(--text-secondary); font-size: 1rem;">
                                ${item['Reorder Level']}
                            </div>
                        </td>
                        <td>
                            <div style="background: ${urgencyColor}; color: white; padding: 0.5rem 0.75rem; border-radius: 4px; text-align: center; font-weight: 600; font-size: 0.875rem;">
                                Need ${deficit} units
                            </div>
                        </td>
                    </tr>
                `;
            });
            
            // Add spacing between hospitals
            if (hospitalIndex < Object.keys(groupedByHospital).length - 1) {
                html += '<tr style="height: 0.5rem;"><td colspan="4" style="padding: 0; border: none;"></td></tr>';
            }
        });
        
        container.innerHTML = html;
        
        // Animate progress bars
        setTimeout(() => {
            const bars = container.querySelectorAll('div[style*="transition: width"]');
            bars.forEach((bar, index) => {
                const width = bar.style.width;
                bar.style.width = '0%';
                setTimeout(() => {
                    bar.style.width = width;
                }, index * 50);
            });
        }, 100);
        
    } catch (error) {
        console.error('Error loading inventory data:', error);
        container.innerHTML = `
            <tr>
                <td colspan="4" style="text-align: center; padding: 2rem; color: var(--accent-red);">
                    Error loading inventory data. Please try again.
                </td>
            </tr>
        `;
    }
}