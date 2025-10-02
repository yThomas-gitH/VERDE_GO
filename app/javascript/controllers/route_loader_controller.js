import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loading", "content", "progressBar", "progressText", "routesList"]
  static values = {
    journeyId: Number,
    pollInterval: { type: Number, default: 2000 }
  }

  connect() {
    this.pollTimer = null
    this.checkInitialState()
  }

  disconnect() {
    this.stopPolling()
  }

  checkInitialState() {
    // Si des routes existent déjà, afficher le contenu
    const routeItems = this.routesListTarget.querySelectorAll('.route-item')
    
    if (routeItems.length > 0) {
      this.showContent()
    } else {
      this.showLoading()
      this.startPolling()
    }
  }

  startPolling() {
    this.pollTimer = setInterval(() => {
      this.checkRouteStatus()
    }, this.pollIntervalValue)
    
    // Premier check immédiat
    this.checkRouteStatus()
  }

  stopPolling() {
    if (this.pollTimer) {
      clearInterval(this.pollTimer)
      this.pollTimer = null
    }
  }

  async checkRouteStatus() {
    try {
      const response = await fetch(`/journeys/${this.journeyIdValue}/route_status`, {
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })

      if (!response.ok) {
        throw new Error('Network response was not ok')
      }

      const data = await response.json()
      
      // Mettre à jour la barre de progression
      this.updateProgress(data.progress_percentage)

      // Si le calcul est terminé
      if (data.status === 'complete' && data.routes.length > 0) {
        this.stopPolling()
        await this.loadRoutes(data.routes)
      }
    } catch (error) {
      console.error('Error checking route status:', error)
      // Continuer le polling même en cas d'erreur
    }
  }

  updateProgress(percentage) {
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${percentage}%`
    }
    if (this.hasProgressTextTarget) {
      this.progressTextTarget.textContent = `${percentage}%`
    }
  }

  async loadRoutes(routes) {
    try {
      // Récupérer le HTML des routes depuis le serveur
      const response = await fetch(`/journeys/${this.journeyIdValue}/routes`, {
        headers: {
          'Accept': 'text/html',
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
        }
      })

      if (!response.ok) {
        throw new Error('Failed to load routes')
      }

      const html = await response.text()
      
      // Parser le HTML pour extraire uniquement la liste des routes
      const parser = new DOMParser()
      const doc = parser.parseFromString(html, 'text/html')
      const routesList = doc.querySelector('[data-route-loader-target="routesList"]')
      
      if (routesList) {
        this.routesListTarget.innerHTML = routesList.innerHTML
      }

      // Attendre un peu pour l'animation
      await new Promise(resolve => setTimeout(resolve, 500))
      
      this.showContent()
      
      // Déclencher l'initialisation de la carte si elle n'est pas encore prête
      this.dispatch('routesLoaded')
    } catch (error) {
      console.error('Error loading routes:', error)
      this.showError()
    }
  }

  showLoading() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = 'flex'
    }
    if (this.hasContentTarget) {
      this.contentTarget.style.display = 'none'
    }
  }

  showContent() {
    if (this.hasLoadingTarget) {
      this.loadingTarget.style.display = 'none'
    }
    if (this.hasContentTarget) {
      this.contentTarget.style.display = 'flex'
    }
  }

  showError() {
    if (this.hasLoadingTarget) {
      const loadingContent = this.loadingTarget.querySelector('.loading-content')
      if (loadingContent) {
        loadingContent.innerHTML = `
          <div style="color: white;">
            <h2>Une erreur s'est produite</h2>
            <p>Impossible de charger les routes. Veuillez rafraîchir la page.</p>
            <button onclick="location.reload()" style="margin-top: 20px; padding: 10px 20px; background: white; color: #667eea; border: none; border-radius: 5px; cursor: pointer; font-weight: 600;">
              Rafraîchir
            </button>
          </div>
        `
      }
    }
  }
}