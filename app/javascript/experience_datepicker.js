import flatpickr from "flatpickr"

function initExperienceDatepicker() {
  const fields = document.querySelectorAll('[data-experience-date-field]')
  if (fields.length === 0) return

  fields.forEach((field) => {
    if (field.dataset.datepickerBound === 'true') return
    field.dataset.datepickerBound = 'true'

    flatpickr(field, {
      dateFormat: 'd/m/Y',
      allowInput: true,
      disableMobile: true
    })
  })
}

document.addEventListener('turbo:load', initExperienceDatepicker)
document.addEventListener('DOMContentLoaded', initExperienceDatepicker)
