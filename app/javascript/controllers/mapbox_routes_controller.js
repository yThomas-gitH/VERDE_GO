import { Controller } from "@hotwired/stimulus"
import mapboxgl from "mapbox-gl"

export default class extends Controller {
  static targets = ["map", "routeItem"]
  
  connect() {
    this.currentRouteItem = null
    this.mapInitialized = false
    
    // Écouter l'événement de chargement des routes
    this.element.addEventListener('route-loader:routes-loaded', () => {
      if (!this.mapInitialized) {
        this.initializeMap()
      } else {
        // Si la carte existe déjà, juste afficher la première route
        if (this.routeItemTargets.length > 0) {
          this.displayRouteByIndex(0)
        }
      }
    })
    
    // Si des routes existent déjà au chargement, initialiser la carte
    if (this.routeItemTargets.length > 0) {
      this.initializeMap()
    }
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }

  initializeMap() {
    const token = this.mapTarget.dataset.mapboxToken
    
    if (!token) {
      console.error("Mapbox token is missing")
      return
    }

    mapboxgl.accessToken = token

    this.map = new mapboxgl.Map({
      container: this.mapTarget,
      style: 'mapbox://styles/mapbox/streets-v12',
      center: [4.35, 50.85], // Centre sur Bruxelles par défaut
      zoom: 12
    })

    // Afficher la première route une fois la carte chargée
    this.map.on('load', () => {
      if (this.routeItemTargets.length > 0) {
        this.displayRouteByIndex(0)
      }
    })
  }

  selectRoute(event) {
    // Ne pas déclencher si on clique sur un lien
    if (event.target.tagName === 'A') return

    const routeItem = event.currentTarget
    const index = parseInt(routeItem.dataset.index)
    
    this.displayRouteByIndex(index)
  }

  displayRouteByIndex(index) {
    const routeItem = this.routeItemTargets[index]
    if (!routeItem) return

    // Retirer le style de la route précédente
    if (this.currentRouteItem) {
      this.currentRouteItem.classList.remove('route-selected')
    }

    // Ajouter le style à la route sélectionnée
    routeItem.classList.add('route-selected')
    this.currentRouteItem = routeItem

    // Afficher la route sur la carte
    const polyline = routeItem.dataset.polyline
    this.displayRoute(polyline)
  }

  displayRoute(polyline) {
    let coordinates
    
    // Si polyline est "//" on crée une ligne droite depuis l'origine vers la destination
    if (polyline === '//') {
      const routeItem = this.currentRouteItem
      const origin = routeItem.dataset.origin ? JSON.parse(routeItem.dataset.origin) : null
      const destination = routeItem.dataset.destination ? JSON.parse(routeItem.dataset.destination) : null
      
      if (origin && destination) {
        coordinates = [
          [origin.lng, origin.lat],
          [destination.lng, destination.lat]
        ]
      } else {
        console.error('Origin or destination coordinates missing for straight line route')
        return
      }
    } else {
      coordinates = this.decodePolyline(polyline)
    }

    // Supprimer la route précédente si elle existe
    if (this.map.getSource('route')) {
      this.map.removeLayer('route')
      this.map.removeSource('route')
    }

    // Ajouter la nouvelle route
    this.map.addSource('route', {
      type: 'geojson',
      data: {
        type: 'Feature',
        properties: {},
        geometry: {
          type: 'LineString',
          coordinates: coordinates
        }
      }
    })

    this.map.addLayer({
      id: 'route',
      type: 'line',
      source: 'route',
      layout: {
        'line-join': 'round',
        'line-cap': 'round'
      },
      paint: {
        'line-color': '#3b82f6',
        'line-width': 4
      }
    })

    // Ajuster la vue pour afficher toute la route
    const bounds = coordinates.reduce((bounds, coord) => {
      return bounds.extend(coord)
    }, new mapboxgl.LngLatBounds(coordinates[0], coordinates[0]))

    this.map.fitBounds(bounds, {
      padding: 50
    })
  }

  decodePolyline(encoded) {
    const points = []
    let index = 0
    const len = encoded.length
    let lat = 0
    let lng = 0

    while (index < len) {
      let b
      let shift = 0
      let result = 0
      do {
        b = encoded.charCodeAt(index++) - 63
        result |= (b & 0x1f) << shift
        shift += 5
      } while (b >= 0x20)
      const dlat = ((result & 1) ? ~(result >> 1) : (result >> 1))
      lat += dlat

      shift = 0
      result = 0
      do {
        b = encoded.charCodeAt(index++) - 63
        result |= (b & 0x1f) << shift
        shift += 5
      } while (b >= 0x20)
      const dlng = ((result & 1) ? ~(result >> 1) : (result >> 1))
      lng += dlng

      points.push([lng / 1e5, lat / 1e5])
    }

    return points
  }
}