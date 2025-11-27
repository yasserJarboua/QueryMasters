// Load patients when page loads
document.addEventListener('DOMContentLoaded', function() {
    loadPatients();
});

// Fetch patients from API
async function loadPatients() {
    const loading = document.getElementById('loading');
    const error = document.getElementById('error');
    const tableBody = document.getElementById('patients-table-body');
    
    try {
        loading.style.display = 'block';
        error.style.display = 'none';
        
        // Call your Flask API endpoint
        const response = await fetch('/api/patients?limit=50');
        
        if (!response.ok) {
            throw new Error('Failed to fetch patients');
        }
        
        const data = await response.json();
        
        // Clear existing data
        tableBody.innerHTML = '';
        
        // Populate table
        data.forEach(patient => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${patient.IID}</td>
                <td>${patient.FullName}</td>
                <td>
                    <button onclick="viewPatient('${patient.IID}')" class="btn btn-small">View</button>
                    <button onclick="editPatient('${patient.IID}')" class="btn btn-small">Edit</button>
                </td>
            `;
            tableBody.appendChild(row);
        });
        
    } catch (err) {
        error.textContent = 'Error loading patients: ' + err.message;
        error.style.display = 'block';
    } finally {
        loading.style.display = 'none';
    }
}

// Search functionality
function searchPatients() {
    const searchValue = document.getElementById('searchInput').value.toLowerCase();
    const rows = document.querySelectorAll('#patients-table-body tr');
    
    rows.forEach(row => {
        const text = row.textContent.toLowerCase();
        row.style.display = text.includes(searchValue) ? '' : 'none';
    });
}

// View patient details
function viewPatient(iid) {
    window.location.href = `/patients/${iid}`;
}

// Edit patient
function editPatient(iid) {
    window.location.href = `/patients/${iid}/edit`;
}