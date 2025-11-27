// inventory.js - Enhanced low stock alert display

document.addEventListener('DOMContentLoaded', function() {
    loadLowStock();
});

async function loadLowStock() {
    const tbody = document.getElementById('stock-table-body');
    tbody.innerHTML = '<tr><td colspan="4" class="loading">Loading low stock items</td></tr>';
    
    try {
        const response = await fetch('/api/inventory/low-stock');
        
        if (!response.ok) {
            throw new Error('Failed to load inventory data');
        }
        
        const stockData = await response.json();
        
        if (stockData.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="4" style="text-align: center; padding: 2rem;">
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
        
        tbody.innerHTML = stockData.map(item => {
            // Calculate urgency level
            const deficit = item["Reorder Level"] - item["Quantity"];
            const urgencyPercent = (item["Quantity"] / item["Reorder Level"]) * 100;
            
            let urgencyLevel = 'low';
            let urgencyColor = 'var(--accent-orange)';
            let urgencyText = 'Low Stock';
            
            if (urgencyPercent < 30) {
                urgencyLevel = 'critical';
                urgencyColor = 'var(--accent-red)';
                urgencyText = 'Critical';
            } else if (urgencyPercent < 60) {
                urgencyLevel = 'high';
                urgencyColor = 'var(--accent-orange)';
                urgencyText = 'Very Low';
            }
            
            return `
                <tr>
                    <td>
                        <div style="font-weight: 600; color: var(--text-primary);">${item["HospitalName"]}</div>
                    </td>
                    <td>
                        <div style="font-weight: 600; color: var(--text-primary);">${item["Medication Name"]}</div>
                        <div style="font-size: 0.85rem; color: ${urgencyColor}; margin-top: 0.25rem; font-weight: 500;">
                            ${urgencyText}
                        </div>
                    </td>
                    <td>
                        <div style="display: flex; align-items: center; gap: 0.5rem;">
                            <div style="font-weight: 700; color: ${urgencyColor}; font-size: 1.1rem;">
                                ${item["Quantity"]}
                            </div>
                            <div style="flex: 1; background: var(--bg-tertiary); height: 6px; border-radius: 10px; overflow: hidden; min-width: 60px;">
                                <div style="width: ${Math.max(urgencyPercent, 5)}%; height: 100%; background: ${urgencyColor}; transition: width 1s ease;"></div>
                            </div>
                        </div>
                    </td>
                    <td>
                        <div style="font-weight: 600; color: var(--text-secondary);">${item["Reorder Level"]}</div>
                        <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.25rem;">
                            Need ${deficit} more
                        </div>
                    </td>
                </tr>
            `;
        }).join('');
        
        // Animate progress bars
        setTimeout(() => {
            const bars = tbody.querySelectorAll('div[style*="width:"][style*="transition"]');
            bars.forEach(bar => {
                const width = bar.style.width;
                bar.style.width = '0%';
                setTimeout(() => {
                    bar.style.width = width;
                }, 50);
            });
        }, 100);
        
    } catch (error) {
        console.error('Error loading inventory data:', error);
        tbody.innerHTML = `
            <tr>
                <td colspan="4" style="text-align: center; padding: 2rem; color: var(--accent-red);">
                    Error loading inventory data. Please try again.
                </td>
            </tr>
        `;
    }
}