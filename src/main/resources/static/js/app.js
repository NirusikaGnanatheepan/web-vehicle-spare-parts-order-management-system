document.addEventListener('DOMContentLoaded', () => {
  const confirmables = document.querySelectorAll('[data-confirm]');
  confirmables.forEach((el) => {
    el.addEventListener('click', (e) => {
      const msg = el.getAttribute('data-confirm') || 'Are you sure?';
      if (!confirm(msg)) {
        e.preventDefault();
      }
    });
  });

  const supplierForm = document.querySelector('form[action$="/suppliers/save"]');
  if (supplierForm) {
    const nameEl = supplierForm.querySelector('input[name="name"], [th\\:field="*{name}"]') || supplierForm.querySelector('[id$="name"]');
    const emailEl = supplierForm.querySelector('input[type="email"]');
    const contactEl = supplierForm.querySelector('input[name="contactNumber"], [th\\:field="*{contactNumber}"]');

    function clearError(input) {
      input.classList.remove('input-error');
      const help = input.parentElement.querySelector('.field-error');
      if (help) help.remove();
    }

    function showError(input, message) {
      input.classList.add('input-error');
      const help = document.createElement('div');
      help.className = 'field-error';
      help.textContent = message;
      input.parentElement.appendChild(help);
    }

    function isEmailValid(v) {
      if (!v) return true; // optional
      return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v);
    }

    supplierForm.addEventListener('submit', (e) => {
      let valid = true;
      [nameEl, emailEl, contactEl].forEach((el) => el && clearError(el));

      if (nameEl) {
        const v = (nameEl.value || '').trim();
        if (v.length < 2) {
          valid = false;
          showError(nameEl, 'Name is required (min 2 characters).');
        }
      }

      if (emailEl) {
        const v = (emailEl.value || '').trim();
        if (!isEmailValid(v)) {
          valid = false;
          showError(emailEl, 'Enter a valid email address.');
        }
      }

      if (contactEl) {
        const v = (contactEl.value || '').trim();
        if (v && v.length < 7) {
          valid = false;
          showError(contactEl, 'Contact number should be at least 7 digits.');
        }
      }

      if (!valid) {
        e.preventDefault();
      }
    });
  }
});


