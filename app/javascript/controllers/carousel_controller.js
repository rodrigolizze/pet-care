import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["image"]

  connect() {
    console.log("Carousel controller connected!")
    this.photos = [
      this.imageTarget.dataset.photo1,
      this.imageTarget.dataset.photo2,
      this.imageTarget.dataset.photo3,
      this.imageTarget.dataset.photo4
    ]
    this.index = 0
    this.start()
  }

  start() {
    this.timer = setInterval(() => this.next(), 3000)
  }

  next() {
    this.index = (this.index + 1) % this.photos.length
    this.imageTarget.src = this.photos[this.index]
  }

  disconnect() {
    clearInterval(this.timer)
  }
}