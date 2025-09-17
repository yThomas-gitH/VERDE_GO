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
  }

  disconnect() {
    this.geocoder.onRemove()
  }
}
