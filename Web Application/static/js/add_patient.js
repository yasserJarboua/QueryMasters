// add_patient.js - Enhanced form submission with better feedback

document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('addPatientForm');
    const messageDiv = document.getElementById('message');
    
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        // Get form data
        const patientData = {
            iid: parseInt(document.getElementById('iid').value),
            cin: document.getElementById('cin').value,
            full_name: document.getElementById('full_name').value,
            birth: document.getElementById('birth').value,
            sex: document.getElementById('sex').value,
            blood: document.getElementById('blood').value,
            phone: document.getElementById('phone').value
        };
        
        // Validate data
        if (!patientData.full_name || !patientData.cin || !patientData.phone) {
            showMessage('Please fill in all required fields', 'error');
            return;
        }
        
        // Disable submit button
        const submitBtn = form.querySelector('button[type="submit"]');
        const originalText = submitBtn.textContent;
        submitBtn.disabled = true;
        submitBtn.textContent = 'Saving...';
        
        try {
            const response = await fetch('/api/patients/add', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(patientData)
            });
            
            const result = await response.json();
            
            if (response.ok && result.success) {
                showMessage('Patient added successfully! ✓', 'success');
                form.reset();
                
                // Redirect after 2 seconds
                setTimeout(() => {
                    window.location.href = '/patients';
                }, 2000);
            } else {
                showMessage(result.error || 'Failed to add patient', 'error');
                submitBtn.disabled = false;
                submitBtn.textContent = originalText;
            }
            
        } catch (error) {
            console.error('Error adding patient:', error);
            showMessage('Network error. Please try again.', 'error');
            submitBtn.disabled = false;
            submitBtn.textContent = originalText;
        }
    });
});

function showMessage(text, type) {
    const messageDiv = document.getElementById('message');
    messageDiv.textContent = text;
    messageDiv.className = `message ${type}`;
    messageDiv.style.display = 'block';
    
    // Auto-hide error messages after 5 seconds
    if (type === 'error') {
        setTimeout(() => {
            messageDiv.style.display = 'none';
        }, 5000);
    }
}