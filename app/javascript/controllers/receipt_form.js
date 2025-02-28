document.addEventListener('DOMContentLoaded', function() {
  // Initialize Cocoon
  // This is handled by the gem's own initialization

  // Attach event handlers for calculating line totals
  document.addEventListener('cocoon:after-insert', function() {
    attachCalculationHandlers();
  });

  attachCalculationHandlers();

  // Total calculation
  function calculateTotal() {
    let total = 0;
    document.querySelectorAll('.js-line-total').forEach(function(field) {
      total += parseFloat(field.value || 0);
    });

    const totalField = document.querySelector('input[name="receipt[total_amount]"]');
    if (totalField) {
      totalField.value = total.toFixed(2);
    }
  }

  function attachCalculationHandlers() {
    document.querySelectorAll('.nested-fields').forEach(function(field) {
      const quantityInput = field.querySelector('.js-quantity');
      const priceInput = field.querySelector('.js-price');
      const totalInput = field.querySelector('.js-line-total');

      if (quantityInput && priceInput && totalInput) {
        const calculateLineTotal = function() {
          const quantity = parseFloat(quantityInput.value || 0);
          const price = parseFloat(priceInput.value || 0);
          totalInput.value = (quantity * price).toFixed(2);
          calculateTotal();
        };

        quantityInput.addEventListener('input', calculateLineTotal);
        priceInput.addEventListener('input', calculateLineTotal);

        // Initial calculation if values are present
        calculateLineTotal();
      }
    });
  }
});
