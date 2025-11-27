// Schedule Appointment with Visual Success Notification

document.addEventListener('DOMContentLoaded', function() {
    const form = document.getElementById('scheduleAppointmentForm');
    const messageDiv = document.getElementById('message');
    
    // Set minimum date to today
    const dateInput = document.getElementById('date_str');
    const today = new Date().toISOString().split('T')[0];
    dateInput.setAttribute('min', today);
    
    // Real-time validation on inputs
    const inputs = form.querySelectorAll('input, textarea');
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
        
        hideMessage();
        
        if (!validateForm()) {
            showMessage('Please fix all validation errors', 'error');
            return;
        }
        
        const appointmentData = {
            caid: parseInt(document.getElementById('caid').value),
            iid: parseInt(document.getElementById('iid').value),
            staff_id: parseInt(document.getElementById('staff_id').value),
            dep_id: parseInt(document.getElementById('dep_id').value),
            date_str: document.getElementById('date_str').value,
            time_str: document.getElementById('time_str').value,
            reason: document.getElementById('reason').value.trim()
        };
        
        if (!validateAppointmentData(appointmentData)) {
            return;
        }
        
        const submitBtn = form.querySelector('button[type="submit"]');
        const originalText = submitBtn.textContent;
        submitBtn.disabled = true;
        submitBtn.textContent = 'Scheduling...';
        
        try {
            const response = await fetch('/api/appointments/schedule', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(appointmentData)
            });
            
            const result = await response.json();
            
            if (response.ok && result.success) {
                // Show success message
                showMessage('✓ Appointment scheduled successfully!', 'success');
                
                // Show notification toast
                showNotification('Appointment Scheduled!', 'The appointment has been successfully added to the system.', 'success');
                
                // Reset form
                form.reset();
                
                // Re-enable button
                submitBtn.disabled = false;
                submitBtn.textContent = originalText;
                
                // Redirect after 2 seconds
                setTimeout(() => {
                    window.location.href = '/';
                }, 2000);
            } else {
                showMessage(result.error || 'Failed to schedule appointment', 'error');
                submitBtn.disabled = false;
                submitBtn.textContent = originalText;
            }
            
        } catch (error) {
            console.error('Error scheduling appointment:', error);
            showMessage('Network error. Please try again.', 'error');
            submitBtn.disabled = false;
            submitBtn.textContent = originalText;
        }
    });
});

function validateField(field) {
    const formGroup = field.parentElement;
    const value = field.value.trim();
    let isValid = true;
    
    formGroup.classList.remove('error');
    
    switch(field.id) {
        case 'caid':
        case 'iid':
        case 'staff_id':
        case 'dep_id':
            if (!value || parseInt(value) <= 0) {
                isValid = false;
            }
            break;
            
        case 'date_str':
            if (!value) {
                isValid = false;
            } else {
                const selectedDate = new Date(value);
                const today = new Date();
                today.setHours(0, 0, 0, 0);
                
                if (selectedDate < today) {
                    isValid = false;
                }
            }
            break;
            
        case 'time_str':
            if (!value) {
                isValid = false;
            }
            break;
            
        case 'reason':
            if (!value || value.length < 10) {
                isValid = false;
            }
            break;
    }
    
    if (!isValid) {
        formGroup.classList.add('error');
    }
    
    return isValid;
}

function validateForm() {
    const form = document.getElementById('scheduleAppointmentForm');
    const inputs = form.querySelectorAll('input, textarea');
    let isValid = true;
    
    inputs.forEach(input => {
        if (!validateField(input)) {
            isValid = false;
        }
    });
    
    return isValid;
}

function validateAppointmentData(data) {
    const appointmentDate = new Date(data.date_str + 'T' + data.time_str);
    const now = new Date();
    
    if (appointmentDate < now) {
        showMessage('Appointment date and time cannot be in the past', 'error');
        return false;
    }
    
    if (data.reason.length < 10) {
        showMessage('Please provide a detailed reason (at least 10 characters)', 'error');
        return false;
    }
    
    if (data.caid <= 0 || data.iid <= 0 || data.staff_id <= 0 || data.dep_id <= 0) {
        showMessage('All ID fields must be positive numbers', 'error');
        return false;
    }
    
    return true;
}

function showMessage(text, type) {
    const messageDiv = document.getElementById('message');
    messageDiv.textContent = text;
    messageDiv.className = `message ${type} show`;
    
    if (type === 'error') {
        setTimeout(() => {
            hideMessage();
        }, 5000);
    }
}

function hideMessage() {
    const messageDiv = document.getElementById('message');
    messageDiv.className = 'message';
}

// Toast Notification System
function showNotification(title, message, type) {
    // Create notification element
    const notification = document.createElement('div');
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: ${type === 'success' ? '#58a182' : '#d66969'};
        color: white;
        padding: 1rem 1.5rem;
        border-radius: 8px;
        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.5);
        z-index: 10000;
        min-width: 300px;
        animation: slideIn 0.3s ease;
    `;
    
    notification.innerHTML = `
        <div style="display: flex; align-items: start; gap: 1rem;">
            <div style="font-size: 1.5rem;">${type === 'success' ? '✓' : '✕'}</div>
            <div style="flex: 1;">
                <div style="font-weight: 700; font-size: 1rem; margin-bottom: 0.25rem;">${title}</div>
                <div style="font-size: 0.875rem; opacity: 0.9;">${message}</div>
            </div>
        </div>
    `;
    
    document.body.appendChild(notification);
    
    // Add animation
    const style = document.createElement('style');
    style.textContent = `
        @keyframes slideIn {
            from {
                transform: translateX(400px);
                opacity: 0;
            }
            to {
                transform: translateX(0);
                opacity: 1;
            }
        }
        @keyframes slideOut {
            from {
                transform: translateX(0);
                opacity: 1;
            }
            to {
                transform: translateX(400px);
                opacity: 0;
            }
        }
    `;
    document.head.appendChild(style);
    
    // Remove after 3 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.3s ease';
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, 3000);
}