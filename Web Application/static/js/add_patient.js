// Add Patient with Complete Validation

document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('addPatientForm');
    const messageDiv = document.getElementById('message');
    
    // Real-time validation on inputs
    const inputs = form.querySelectorAll('input, select');
    inputs.forEach(input => {
        input.addEventListener('blur', function() {
            validateField(this);
        });
        
        input.addEventListener('input', function() {
            if (this.parentElement.classList.contains('error')) {
                validateField(this);
            }
        });
    });
    
    // Form submission
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        // Clear previous message
        hideMessage();
        
        // Validate all fields
        if (!validateForm()) {
            showMessage('Please fix all validation errors', 'error');
            return;
        }
        
        // Get form data
        const patientData = {
            iid: parseInt(document.getElementById('iid').value),
            cin: document.getElementById('cin').value.trim(),
            full_name: document.getElementById('full_name').value.trim(),
            birth: document.getElementById('birth').value,
            sex: document.getElementById('sex').value,
            blood: document.getElementById('blood').value.trim(),
            phone: document.getElementById('phone').value.trim()
        };
        
        // Additional validation
        if (!validatePatientData(patientData)) {
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
                showMessage('Patient added successfully!', 'success');
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

// Validate individual field
function validateField(field) {
    const formGroup = field.parentElement;
    const value = field.value.trim();
    let isValid = true;
    
    // Remove previous error
    formGroup.classList.remove('error');
    
    switch(field.id) {
        case 'iid':
            if (!value || parseInt(value) <= 0) {
                isValid = false;
            }
            break;
            
        case 'cin':
            // CIN should be alphanumeric and have reasonable length
            if (!value || value.length < 5 || value.length > 20) {
                isValid = false;
            }
            break;
            
        case 'full_name':
            // Name should be at least 3 characters and contain letters
            if (!value || value.length < 3 || !/[a-zA-Z]/.test(value)) {
                isValid = false;
            }
            break;
            
        case 'birth':
            if (!value) {
                isValid = false;
            } else {
                // Check if birth date is not in the future
                const birthDate = new Date(value);
                const today = new Date();
                
                if (birthDate > today) {
                    isValid = false;
                }
                
                // Check if age is reasonable (not more than 150 years)
                const age = Math.floor((today - birthDate) / (365.25 * 24 * 60 * 60 * 1000));
                if (age > 150 || age < 0) {
                    isValid = false;
                }
            }
            break;
            
        case 'blood':
            // Blood type validation (A+, A-, B+, B-, O+, O-, AB+, AB-)
            const validBloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
            if (value && !validBloodTypes.includes(value.toUpperCase())) {
                isValid = false;
            }
            break;
            
        case 'phone':
            // Phone should be at least 10 digits
            const phoneDigits = value.replace(/\D/g, '');
            if (!value || phoneDigits.length < 10) {
                isValid = false;
            }
            break;
    }
    
    if (!isValid) {
        formGroup.classList.add('error');
    }
    
    return isValid;
}

// Validate entire form
function validateForm() {
    const form = document.getElementById('addPatientForm');
    const inputs = form.querySelectorAll('input, select');
    let isValid = true;
    
    inputs.forEach(input => {
        if (input.hasAttribute('required') || input.value.trim() !== '') {
            if (!validateField(input)) {
                isValid = false;
            }
        }
    });
    
    return isValid;
}

// Additional business logic validation
function validatePatientData(data) {
    // Check IID is positive
    if (data.iid <= 0) {
        showMessage('Patient ID must be a positive number', 'error');
        return false;
    }
    
    // Check CIN format
    if (data.cin.length < 5) {
        showMessage('CIN must be at least 5 characters', 'error');
        return false;
    }
    
    // Check name is meaningful
    if (data.full_name.length < 3) {
        showMessage('Full name must be at least 3 characters', 'error');
        return false;
    }
    
    // Check birth date
    const birthDate = new Date(data.birth);
    const today = new Date();
    
    if (birthDate > today) {
        showMessage('Birth date cannot be in the future', 'error');
        return false;
    }
    
    const age = Math.floor((today - birthDate) / (365.25 * 24 * 60 * 60 * 1000));
    if (age > 150) {
        showMessage('Invalid birth date (age cannot exceed 150 years)', 'error');
        return false;
    }
    
    // Check blood type if provided
    if (data.blood) {
        const validBloodTypes = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
        if (!validBloodTypes.includes(data.blood.toUpperCase())) {
            showMessage('Invalid blood type. Must be one of: A+, A-, B+, B-, O+, O-, AB+, AB-', 'error');
            return false;
        }
    }
    
    // Check phone format
    const phoneDigits = data.phone.replace(/\D/g, '');
    if (phoneDigits.length < 10) {
        showMessage('Phone number must contain at least 10 digits', 'error');
        return false;
    }
    
    return true;
}

// Show message helper
function showMessage(text, type) {
    const messageDiv = document.getElementById('message');
    messageDiv.textContent = text;
    messageDiv.className = `message ${type} show`;
    
    // Auto-hide error messages after 5 seconds
    if (type === 'error') {
        setTimeout(() => {
            hideMessage();
        }, 5000);
    }
}

// Hide message helper
function hideMessage() {
    const messageDiv = document.getElementById('message');
    messageDiv.className = 'message';
}