// API Endpoint
const API_URL = "https://nq7wno0qmg.execute-api.ap-southeast-1.amazonaws.com";

function toggleProject() {
    const content = document.getElementById('p-content');
    const icon = document.getElementById('p-icon');
    content.classList.toggle('active');
    icon.innerText = content.classList.contains('active') ? "−" : "+";
}

async function updateVisitorCount() {
    try {
        const response = await fetch(API_URL);
        const data = await response.json();
        if (data.count) {
            document.getElementById('counter').innerText = data.count;
        }
    } catch (error) {
        console.error("Lỗi counter:", error);
    }
}

async function sendComment() {
    const nameInput = document.getElementById('name');
    const messageInput = document.getElementById('message');
    
    const name = nameInput ? nameInput.value.trim() : '';
    const message = messageInput ? messageInput.value.trim() : '';
    
    if (!message) {
        showToast("⚠️ Please write a message before sending.", "#ff6b6b");
        return;
    }
    
    try {
        showToast("⏳ Sending message...", "#f1c40f");
        
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                name: name || 'Anonymous',
                message: message
            })
        });
        
        const data = await response.json();
        
        if (response.ok) {
            showToast("✅ Message sent successfully!", "#2ecc71");
            if (messageInput) messageInput.value = '';
        } else {
            showToast("❌ Error: " + (data.error || "Unknown error"), "#ff6b6b");
        }
    } catch (error) {
        console.error("Error:", error);
        showToast("❌ Network error. Please try again.", "#ff6b6b");
    }
}

function showToast(message, color = "#bc13fe") {
    const container = document.getElementById('toast-container');
    if (!container) return;
    
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.style.borderLeftColor = color;
    toast.innerHTML = `<i class="fas fa-comment-dots" style="margin-right: 10px;"></i> ${message}`;
    container.appendChild(toast);
    setTimeout(() => {
        toast.remove();
    }, 3200);
}

// Khởi chạy khi trang load
document.addEventListener('DOMContentLoaded', function() {
    updateVisitorCount();
});
