function initProjectSearch() {
  const root = document.querySelector('[data-project-search-root]')
  if (!root) return

  const searchInput = root.querySelector('[data-project-search-input]')
  const featuredSelect = root.querySelector('[data-project-featured-filter]')
  const sortSelect = root.querySelector('[data-project-sort-filter]')
  const tbody = root.querySelector('[data-project-table-body]')
  const rows = Array.from(root.querySelectorAll('[data-project-row]'))
  const emptyState = root.querySelector('[data-project-empty-state]')
  const debug = root.querySelector('[data-project-debug]')

  if (!searchInput || !tbody || rows.length === 0) return

  const applyFilter = () => {
    const query = searchInput.value.trim().toLowerCase()
    const featured = featuredSelect ? featuredSelect.value : 'all'
    const sort = sortSelect ? sortSelect.value : 'latest'

    let visibleRows = rows.filter((row) => {
      const haystack = row.textContent.toLowerCase()
      const matchQuery = query === '' || haystack.includes(query)
      const matchFeatured = featured === 'all' || (row.dataset.featured || 'false') === featured
      return matchQuery && matchFeatured
    })

    visibleRows.sort((a, b) => {
      if (sort === 'title') {
        return (a.dataset.title || '').localeCompare(b.dataset.title || '')
      }
      if (sort === 'sort_order') {
        return Number(a.dataset.sortOrder || 0) - Number(b.dataset.sortOrder || 0)
      }
      return (b.dataset.updatedAt || '').localeCompare(a.dataset.updatedAt || '')
    })

    rows.forEach((row) => {
      row.style.display = 'none'
    })

    visibleRows.forEach((row) => {
      row.style.display = ''
      tbody.appendChild(row)
    })

    if (emptyState) {
      emptyState.classList.toggle('hidden', visibleRows.length > 0)
    }

    if (debug) {
      debug.textContent = `query=${query || '-'} | featured=${featured} | sort=${sort} | visible=${visibleRows.length}/${rows.length}`
    }
  }

  searchInput.addEventListener('input', applyFilter)
  featuredSelect?.addEventListener('change', applyFilter)
  sortSelect?.addEventListener('change', applyFilter)

  applyFilter()
}

document.addEventListener('turbo:load', initProjectSearch)
document.addEventListener('DOMContentLoaded', initProjectSearch)
