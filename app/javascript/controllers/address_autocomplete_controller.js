import { Controller } from "@hotwired/stimulus"
import "mapbox-gl"               // Ensure mapbox-gl is loaded
import "mapbox-gl-geocoder"      // Ensure geocoder attaches to window

// Connects to data-controller="address-autocomplete"
export default class extends Controller {
  static values = { apiKey: String }
  static targets = ["address"]

  connect() {
    // Use the global MapboxGeocoder
    this.geocoder = new window.MapboxGeocoder({
      accessToken: this.apiKeyValue,
      types: "country,region,place,postcode,locality,neighborhood,address"
    })

    // Attach geocoder to this element
    this.geocoder.addTo(this.element)
    console.log("MapboxGeocoder connected")

    this.geocoder.on("result", event => this.#setInputValue(event))
    this.geocoder.on("clear", () => this.#clearInputValue())
  }

  #setInputValue(event) {
    this.addressTarget.value = event.result["place_name"]
  }

  #clearInputValue() {
    this.addressTarget.value = ""
  }

  disconnect() {
    this.geocoder.onRemove()
  }
}
