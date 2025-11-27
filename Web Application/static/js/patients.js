// patients.js - Enhanced with better UI feedback

document.addEventListener('DOMContentLoaded', function() {
    loadPatients();
});

async function loadPatients() {
    const tbody = document.getElementById('patients-table-body');
    tbody.innerHTML = '<tr><td colspan="3" class="loading">Loading patients</td></tr>';
    
    try {
        const response = await fetch('/api/patients?limit=50');
        
        if (!response.ok) {
            throw new Error('Failed to load patients');
        }
        
        const patients = await response.json();
        
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
                    <div style="font-weight: 600; color: var(--text-primary);">${patient["FullName"]}</div>
                    <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.25rem;">ID: ${patient["IID"]}</div>
                </td>
                <td>
                    <span style="display: inline-flex; align-items: center; gap: 0.5rem;">
                        ${patient["Sex"] === 'M' ? '👨 Male' : '👩 Female'}
                    </span>
                </td>
                <td>${patient["Phone"] || 'N/A'}</td>
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
    // For now, just add a subtle animation
}