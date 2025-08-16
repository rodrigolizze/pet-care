// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"
import flatpickr from "flatpickr"

function initDatepickers() {
  flatpickr(".flatpickr", {
    wrap: true,        // permite que o ícone seja clicável
    dateFormat: "Y-m-d",
    altInput: true,
    altFormat: "d/m/Y",
    allowInput: true,
    onReady(_, __, instance) {
      if (instance.altInput && instance.input.placeholder) {
        instance.altInput.placeholder = instance.input.placeholder
      }
    }
  })
}

document.addEventListener("DOMContentLoaded", initDatepickers)
document.addEventListener("turbo:load", initDatepickers)
