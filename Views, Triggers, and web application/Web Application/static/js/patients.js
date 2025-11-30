// Patients page with limit selector (minimum 10, ordered by last name)

document.addEventListener('DOMContentLoaded', function() {
    // Load patients on page load
    loadPatients();
    
    // Reload patients when limit changes
    const limitSelector = document.getElementById('limit-selector');
    limitSelector.addEventListener('change', function() {
        loadPatients();
    });
});

async function loadPatients() {
    const tbody = document.getElementById('patients-table-body');
    const limitSelector = document.getElementById('limit-selector');
    const patientCount = document.getElementById('patient-count');
    
    tbody.innerHTML = '<tr><td colspan="3" class="loading">Loading patients...</td></tr>';
    
    try {
        let limit = limitSelector.value;
        
        // If "all" is selected, use a very high number
        if (limit === 'all') {
            limit = 10000;
        }
        
        // Ensure minimum of 10
        limit = Math.max(parseInt(limit), 10);
        
        const response = await fetch(`/api/patients?limit=${limit}`);
        
        if (!response.ok) {
            throw new Error('Failed to load patients');
        }
        
        const patients = await response.json();
        
        // Update count
        patientCount.textContent = patients.length;
        
        if (patients.length === 0) {
            tbody.innerHTML = `
                <tr>
                    <td colspan="3" style="text-align: center; padding: 2rem; color: var(--text-muted);">
                        No patients found. <a href="/patients/add" style="color: var(--accent-blue);">Add your first patient</a>
                    </td>
                </tr>
            `;
            return;
        }
        
        tbody.innerHTML = patients.map(patient => `
            <tr style="cursor: pointer;" onclick="showPatientDetails(${patient["IID"]})">
                <td>
                    <div style="font-weight: 600; color: var(--text-primary);">${patient['FullName']}</div>
                    <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.25rem;">ID: ${patient['IID']}</div>
                </td>
                <td>
                    <span style="display: inline-flex; align-items: center; gap: 0.5rem;">
                        ${patient['Sex'] === 'M' ? '👨 Male' : '👩 Female'}
                    </span>
                </td>
                <td>${patient['Phone'] || 'N/A'}</td>
            </tr>
        `).join('');
        
    } catch (error) {
        console.error('Error loading patients:', error);
        tbody.innerHTML = `
            <tr>
                <td colspan="3" style="text-align: center; padding: 2rem; color: var(--accent-red);">
                    Error loading patients. Please try again.
                </td>
            </tr>
        `;
    }
}

function showPatientDetails(patientId) {
    // You can implement a modal or redirect to patient details page
    console.log('Show details for patient:', patientId);
}