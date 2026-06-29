/**
 * Xennrex Cloud - Shared JavaScript
 * Used across all pages for API calls, utilities, UI interactions
 */

const API_BASE = 'https://api.xennrex.org';
const RECAPTCHA_SITE_KEY = 'YOUR_RECAPTCHA_SITE_KEY';
const PAYFAST_RETURN_URL = 'https://xennrex.org/success.html';

/**
 * Fetch with authentication headers
 */
async function fetchWithAuth(endpoint, options = {}) {
  const apiKey = localStorage.getItem('admin_api_key') || '';
  const url = endpoint.startsWith('http') ? endpoint : `${API_BASE}${endpoint}`;

  const headers = {
    'Content-Type': 'application/json',
    ...options.headers,
  };

  if (apiKey) {
    headers['X-API-Key'] = apiKey;
  }

  try {
    const response = await fetch(url, {
      ...options,
      headers,
    });

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || `HTTP ${response.status}: ${response.statusText}`);
    }

    return response;
  } catch (error) {
    console.error('API Error:', error);
    throw error;
  }
}

/**
 * Format number as ZAR currency
 */
function formatCurrency(amount) {
  return new Intl.NumberFormat('en-ZA', {
    style: 'currency',
    currency: 'ZAR',
    minimumFractionDigits: 2,
  }).format(amount);
}

/**
 * Format date to local string
 */
function formatDate(dateString) {
  if (!dateString) return 'N/A';
  const date = new Date(dateString);
  if (isNaN(date.getTime())) return dateString;
  return new Intl.DateTimeFormat('en-ZA', {
    year: 'numeric',
    month: 'short',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  }).format(date);
}

/**
 * Toast notification system
 */
function showToast(message, type = 'info') {
  // Remove existing toast
  const existingToast = document.querySelector('.xennrex-toast');
  if (existingToast) existingToast.remove();

  const toast = document.createElement('div');
  toast.className = `xennrex-toast toast-${type}`;
  toast.innerHTML = `
    <span class="toast-icon">${type === 'success' ? '&#10003;' : type === 'error' ? '&#10007;' : type === 'warning' ? '&#9888;' : '&#9432;'}</span>
    <span class="toast-message">${message}</span>
  `;

  document.body.appendChild(toast);

  // Animate in
  requestAnimationFrame(() => {
    toast.classList.add('show');
  });

  // Auto dismiss
  setTimeout(() => {
    toast.classList.remove('show');
    setTimeout(() => toast.remove(), 300);
  }, 4000);
}

/**
 * Mobile menu toggle
 */
function initMobileMenu() {
  const toggle = document.getElementById('mobileMenuToggle');
  const menu = document.getElementById('mobileMenu');

  if (!toggle || !menu) return;

  toggle.addEventListener('click', () => {
    menu.classList.toggle('open');
    toggle.classList.toggle('active');
    const icon = toggle.querySelector('i');
    if (icon) {
      icon.className = menu.classList.contains('open') ? 'fas fa-times' : 'fas fa-bars';
    }
  });

  // Close menu on link click
  menu.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
      menu.classList.remove('open');
      toggle.classList.remove('active');
      const icon = toggle.querySelector('i');
      if (icon) icon.className = 'fas fa-bars';
    });
  });
}

/**
 * Scroll reveal animation observer
 */
function initScrollReveal() {
  const observer = new IntersectionObserver(
    (entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('revealed');
          observer.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px',
    }
  );

  document.querySelectorAll('.reveal').forEach((el) => observer.observe(el));
}

/**
 * Fleet status checker - shows Pi availability
 */
async function checkFleetStatus(containerId = 'fleetStatus') {
  const container = document.getElementById(containerId);
  if (!container) return;

  try {
    const response = await fetch(`${API_BASE}/api/fleet/status`);
    const data = await response.json();

    const availableNodes = data.availableNodes || data.available || 0;

    if (availableNodes > 0) {
      container.innerHTML = `
        <div class="fleet-status available">
          <span class="status-dot green"></span>
          <span class="status-text">${availableNodes} node${availableNodes > 1 ? 's' : ''} available — ready to provision</span>
        </div>
      `;
    } else {
      container.innerHTML = `
        <div class="fleet-status unavailable">
          <span class="status-dot red"></span>
          <span class="status-text">Out of stock — <a href="checkout.html">Join the waitlist</a></span>
        </div>
      `;
    }
  } catch (error) {
    console.error('Fleet status error:', error);
    container.innerHTML = `
      <div class="fleet-status unavailable">
        <span class="status-dot red"></span>
        <span class="status-text">Unable to check fleet status — <a href="checkout.html">Try checkout</a></span>
      </div>
    `;
  }
}

/**
 * Initialize common page elements
 */
document.addEventListener('DOMContentLoaded', () => {
  initMobileMenu();
  initScrollReveal();

  // Add active class to current nav item
  const currentPage = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-link').forEach(link => {
    const href = link.getAttribute('href');
    if (href === currentPage || (currentPage === '' && href === 'index.html')) {
      link.classList.add('active');
    }
  });
});
