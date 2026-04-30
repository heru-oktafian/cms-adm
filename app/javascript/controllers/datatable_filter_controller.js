import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "search", "featured", "sort", "emptyState", "debug"]

  connect() {
    console.log("[datatable-filter] connect", {
      rows: this.rowTargets.length,
      hasSearch: this.hasSearchTarget,
      hasFeatured: this.hasFeaturedTarget,
      hasSort: this.hasSortTarget,
      hasEmptyState: this.hasEmptyStateTarget
    })

    if (this.hasDebugTarget) {
      this.debugTarget.textContent = `datatable-filter connected | rows=${this.rowTargets.length}`
    }

    this.apply()
  }

  apply() {
    const query = (this.hasSearchTarget ? this.searchTarget.value : "").trim().toLowerCase()
    const featured = this.hasFeaturedTarget ? this.featuredTarget.value : "all"
    const sort = this.hasSortTarget ? this.sortTarget.value : "latest"

    console.log("[datatable-filter] apply", { query, featured, sort, rows: this.rowTargets.length })

    let rows = [...this.rowTargets]

    rows.forEach((row) => {
      const haystack = row.textContent.toLowerCase()
      const matchQuery = query === "" || haystack.includes(query)
      const matchFeatured = featured === "all" || (row.dataset.featured || "false") === featured
      const visible = matchQuery && matchFeatured
      row.style.display = visible ? "" : "none"
    })

    rows = rows.filter((row) => row.style.display !== "none")

    rows.sort((a, b) => {
      if (sort === "title") {
        return (a.dataset.title || "").localeCompare(b.dataset.title || "")
      }

      if (sort === "sort_order") {
        return Number(a.dataset.sortOrder || 0) - Number(b.dataset.sortOrder || 0)
      }

      return (b.dataset.updatedAt || "").localeCompare(a.dataset.updatedAt || "")
    })

    const tbody = this.rowTargets[0]?.parentElement
    rows.forEach((row) => tbody?.appendChild(row))

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.toggle("hidden", rows.length > 0)
    }

    if (this.hasDebugTarget) {
      this.debugTarget.textContent = `query=${query || '-'} | featured=${featured} | sort=${sort} | visible=${rows.length}/${this.rowTargets.length}`
    }
  }
}
