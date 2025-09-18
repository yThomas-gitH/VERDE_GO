import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Make sure closeOnOutsideClick always has the right "this"
    this.closeOnOutsideClick = this.closeOnOutsideClick.bind(this)
    console.log("yo le sang")
  }

  toggle(event) {
    event.preventDefault()
    this.menuTarget.classList.toggle("hidden")

    if (!this.menuTarget.classList.contains("hidden")) {
      document.addEventListener("click", this.closeOnOutsideClick)
    } else {
      document.removeEventListener("click", this.closeOnOutsideClick)
    }
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.menuTarget.classList.add("hidden")
      document.removeEventListener("click", this.closeOnOutsideClick)
    }
  }

  disconnect() {
    document.removeEventListener("click", this.closeOnOutsideClick)
  }
}
