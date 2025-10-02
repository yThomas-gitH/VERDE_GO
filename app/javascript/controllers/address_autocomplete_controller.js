import { Controller } from "@hotwired/stimulus"
import "mapbox-gl"               // Ensure mapbox-gl is loaded
import "mapbox-gl-geocoder"      // Ensure geocoder attaches to window

export default class extends Controller {
  static targets = ["address"]
  static values = {
    apiKey: String
  }

  connect() {
    this.initializeGeocoder()
  }

  disconnect() {
    if (this.geocoder) {
      this.geocoder.onRemove()
    }
  }

  initializeGeocoder() {
    if (!this.apiKeyValue) {
      console.error("Mapbox API key is missing")
      return
    }

    // Créer un container pour le geocoder
    const geocoderContainer = document.createElement('div')
    geocoderContainer.classList.add('geocoder-container')
    
    // Insérer le container avant l'input caché
    this.addressTarget.parentElement.insertBefore(geocoderContainer, this.addressTarget)

    this.geocoder = new MapboxGeocoder({
      accessToken: this.apiKeyValue,
      types: 'address,place,poi',
      placeholder: this.addressTarget.labels[0]?.textContent || 'Rechercher une adresse...',
      countries: 'be,fr,nl,de,lu', // Pays européens proches
      language: 'fr'
    })

    this.geocoder.addTo(geocoderContainer)

    // Quand une adresse est sélectionnée
    this.geocoder.on('result', (e) => {
      const result = e.result
      // Remplir le champ caché avec le texte de l'adresse
      this.addressTarget.value = result.place_name
      
      // Vous pouvez aussi stocker les coordonnées si nécessaire
      console.log('Selected:', result.place_name)
      console.log('Coordinates:', result.center)
    })

    // Nettoyer quand l'adresse est effacée
    this.geocoder.on('clear', () => {
      this.addressTarget.value = ''
    })
  }
}
