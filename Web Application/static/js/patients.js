document.addEventListener('DOMContentLoaded', function() {
    fetchPatients();
});

async function fetchPatients() {
    try {
        // Calls your Python: @app.route('/api/patients')
        const response = await fetch('/api/patients?limit=50');
        const data = await response.json();
        const tbody = document.getElementById('patients-table-body');
        tbody.innerHTML = ''; // Clear loading text
        
        data.forEach(patient => {
            // Note: Adjust indices [0], [1] based on your database tuple order
            // Or use patient.ColumnName if your DB returns a dictionary
            const row = `
                <tr>
                    <td>${patient["FullName"]}</td> <td>${patient['Sex']}</td><td>${patient["Phone"]}</td>
                </tr>
            `;
            tbody.innerHTML += row;
        });
    } catch (error) {
        console.error('Error:', error);
    }
}