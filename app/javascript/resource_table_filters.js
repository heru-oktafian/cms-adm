function initResourceTableFilters() {
  const roots = document.querySelectorAll('[data-resource-table-root]')
  if (roots.length === 0) return

  roots.forEach((root) => {
    const searchInput = root.querySelector('[data-resource-search-input]')
    const sortSelect = root.querySelector('[data-resource-sort-filter]')
    const tbody = root.querySelector('[data-resource-table-body]')
    const rows = Array.from(root.querySelectorAll('[data-resource-row]'))
    const emptyState = root.querySelector('[data-resource-empty-state]')
    const debug = root.querySelector('[data-resource-debug]')
    const mode = root.dataset.resourceMode || 'generic'

    if (!searchInput || !tbody || rows.length === 0) return

    const applyFilter = () => {
      const query = searchInput.value.trim().toLowerCase()
      const sort = sortSelect ? sortSelect.value : 'latest'

      let visibleRows = rows.filter((row) => {
        const haystack = row.textContent.toLowerCase()
        return query === '' || haystack.includes(query)
      })

      visibleRows.sort((a, b) => {
        if (sort === 'name') {
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
        debug.textContent = `${mode} | query=${query || '-'} | sort=${sort} | visible=${visibleRows.length}/${rows.length}`
      }
    }

    searchInput.addEventListener('input', applyFilter)
    sortSelect?.addEventListener('change', applyFilter)

    applyFilter()
  })
}

document.addEventListener('turbo:load', initResourceTableFilters)
document.addEventListener('DOMContentLoaded', initResourceTableFilters)
