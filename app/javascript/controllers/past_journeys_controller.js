import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "title"]

  connect() {
    // Make sure closeOnOutsideClick always has the right "this"
    console.log("controller past journey ok")
  }

  toggle(event) {
    event.preventDefault()

    const list = this.listTarget
    const title = this.titleTarget

    // Determine what the new title text should be
    const isCurrentlyOpen = list.classList.contains("show")
    const newText = isCurrentlyOpen ? "Want to see your past journeys?" : "Past journeys"

    // Toggle the list open/closed
    list.classList.toggle("show")
    title.textContent = newText
  }
}
