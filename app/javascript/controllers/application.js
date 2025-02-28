import { Application } from "@hotwired/stimulus"
import "chartkick/chart.js"  // Add this line

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

// Import Cocoon
import "@nathanvda/cocoon"

// Import your custom JS
import "./receipt_form"

export { application }
