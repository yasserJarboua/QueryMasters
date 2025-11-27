document.addEventListener('DOMContentLoaded', async () => {
    try {
        const response = await fetch('/api/staff/share');
        const data = await response.json();
        
        const tbody = document.getElementById('staff-table-body');
        
        data.forEach(row => {
            // Assuming row is tuple: (Name, Hospital, Total, Percentage)
            const html = `
                <tr>
                    <td>${row["Staff FullName"]}</td>
                    <td>${row["Hospital Name"]}</td>
                    <td>${row["Total Appointments"]}</td>
                    <td>${row["Percentage Share within the Hospital"]}%</td>
                </tr>
            `;
            tbody.innerHTML += html;
        });
    } catch (error) {
        console.error(error);
    }
});