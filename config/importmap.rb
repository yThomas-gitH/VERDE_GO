# Pin Rails libraries
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"

# Mapbox GL + Geocoder
pin "mapbox-gl", to: "https://ga.jspm.io/npm:mapbox-gl@3.1.2/dist/mapbox-gl.js"
pin "mapbox-gl-geocoder", to: "https://unpkg.com/@mapbox/mapbox-gl-geocoder/dist/mapbox-gl-geocoder.min.js", preload: true

# Node.js polyfills (if needed by mapbox-gl)
pin "process", to: "https://ga.jspm.io/npm:@jspm/core@2.1.0/nodelibs/browser/process-production.js"