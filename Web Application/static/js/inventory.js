document.addEventListener('DOMContentLoaded', async () => {
    try {
        const response = await fetch('/api/inventory/low-stock');
        const data = await response.json();
        
        const tbody = document.getElementById('stock-table-body');
        
        data.forEach(item => {
            const html = `
                <tr>
                    <td>${item["HospitalName"]}</td> <td>${item["Medication Name"]}</td> <td style="color:red; font-weight:bold">${item["Quantity"]}</td>
                    <td>${item["Reorder Level"]}</td>
                </tr>
            `;
            tbody.innerHTML += html;
        });
    } catch (error) {
        console.error(error);
    }
});