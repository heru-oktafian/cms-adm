import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "backdrop"]

  connect() {
    this.close()
  }

  toggle() {
    if (this.panelTarget.classList.contains("-translate-x-full")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.backdropTarget.classList.remove("hidden")
    this.panelTarget.classList.remove("-translate-x-full")
  }

  close() {
    this.backdropTarget.classList.add("hidden")
    this.panelTarget.classList.add("-translate-x-full")
  }
}
