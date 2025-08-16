// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"
import flatpickr from "flatpickr"

function initDatepickers() {
  // 1) Cenário: booking/show com datas disponíveis no JSON
  const availableDatesTag = document.getElementById("available-dates-json")
  if (availableDatesTag) {
    const availableDates = JSON.parse(availableDatesTag.textContent)

    if (document.querySelector("#start_date")) {
      flatpickr("#start_date", {
        dateFormat: "Y-m-d",
        altInput: true,
        altFormat: "d/m/Y",
        allowInput: false,
        enable: availableDates
      })
    }

    if (document.querySelector("#end_date")) {
      flatpickr("#end_date", {
        dateFormat: "Y-m-d",
        altInput: true,
        altFormat: "d/m/Y",
        allowInput: false,
        enable: availableDates
      })
    }
    return // já tratou este caso, não precisa cair no próximo
  }

  // 2) Cenário: home com ícone clicável (wrap: true)
  if (document.querySelector(".flatpickr")) {
    flatpickr(".flatpickr", {
      wrap: true,
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
}

document.addEventListener("DOMContentLoaded", initDatepickers)
document.addEventListener("turbo:load", initDatepickers)
