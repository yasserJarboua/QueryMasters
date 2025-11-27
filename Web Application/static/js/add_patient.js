document.getElementById('addPatientForm').addEventListener('submit', async function(e) {
    e.preventDefault(); // Stop page reload

    // Gather data exactly matching your Python data['key'] requirements
    const patientData = {
        iid: document.getElementById('iid').value,
        cin: document.getElementById('cin').value,
        full_name: document.getElementById('full_name').value,
        birth: document.getElementById('birth').value,
        sex: document.getElementById('sex').value,
        blood: document.getElementById('blood').value,
        phone: document.getElementById('phone').value
    };

    try {
        const response = await fetch('/api/patients/add', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(patientData)
        });

        const result = await response.json();

        const msgDiv = document.getElementById('message');
        if (result.success) {
            msgDiv.textContent = "Success! Redirecting...";
            msgDiv.style.color = "green";
            setTimeout(() => window.location.href = '/patients', 1500);
        } else {
            msgDiv.textContent = "Error: " + result.error;
            msgDiv.style.color = "red";
        }
    } catch (error) {
        console.error('Error:', error);
    }
});