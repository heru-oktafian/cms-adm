function initProjectModal() {
  const root = document.querySelector('[data-project-modal-root]')
  if (!root) return

  const modal = root.querySelector('[data-project-modal]')
  const deleteModal = root.querySelector('[data-project-delete-modal]')
  const form = root.querySelector('[data-project-form]')
  const title = root.querySelector('[data-project-modal-title]')
  const submit = root.querySelector('[data-project-submit]')
  const deleteText = root.querySelector('[data-project-delete-text]')
  const deleteForm = root.querySelector('[data-project-delete-form]')
  const feedback = root.querySelector('[data-project-feedback]')

  const fields = {
    id: root.querySelector('[data-project-field="id"]'),
    title: root.querySelector('[data-project-field="title"]'),
    slug: root.querySelector('[data-project-field="slug"]'),
    summary: root.querySelector('[data-project-field="summary"]'),
    description: root.querySelector('[data-project-field="description"]'),
    thumbnail_path: root.querySelector('[data-project-field="thumbnail_path"]'),
    project_url: root.querySelector('[data-project-field="project_url"]'),
    repo_url: root.querySelector('[data-project-field="repo_url"]'),
    sort_order: root.querySelector('[data-project-field="sort_order"]'),
    is_featured: root.querySelector('[data-project-field="is_featured"]')
  }

  if (!modal || !form) return

  const createPath = root.dataset.projectCreatePath
  const updateBase = root.dataset.projectUpdateBase
  const deleteBase = root.dataset.projectDeleteBase
  const loginPath = root.dataset.loginPath || '/login'

  const openModal = () => modal.classList.remove('hidden')
  const closeModal = () => modal.classList.add('hidden')
  const openDeleteModal = () => deleteModal?.classList.remove('hidden')
  const closeDeleteModal = () => deleteModal?.classList.add('hidden')
  const showFeedback = (message, type = 'info') => {
    if (!feedback) return
    feedback.textContent = message
    feedback.className = `rounded-2xl px-4 py-3 text-sm ${type === 'error' ? 'bg-rose-50 text-rose-600' : 'bg-emerald-50 text-emerald-600'}`
    feedback.classList.remove('hidden')
  }

  const hideFeedback = () => {
    if (!feedback) return
    feedback.classList.add('hidden')
  }

  const fillForm = (project = {}) => {
    fields.id.value = project.id || ''
    fields.title.value = project.title || ''
    fields.slug.value = project.slug || ''
    fields.summary.value = project.summary || ''
    fields.description.value = project.description || ''
    fields.thumbnail_path.value = project.thumbnail_path || ''
    fields.project_url.value = project.project_url || ''
    fields.repo_url.value = project.repo_url || ''
    fields.sort_order.value = project.sort_order || 0
    fields.is_featured.checked = !!project.is_featured
  }

  root.querySelectorAll('[data-project-create]').forEach((button) => {
    button.addEventListener('click', () => {
      form.action = createPath
      form.querySelector('input[name="_method"]')?.remove()
      fillForm()
      hideFeedback()
      title.textContent = 'Create project'
      submit.textContent = 'Create project'
      openModal()
    })
  })

  root.querySelectorAll('[data-project-edit]').forEach((button) => {
    button.addEventListener('click', () => {
      const project = JSON.parse(button.dataset.projectPayload)
      fillForm(project)
      form.action = `${updateBase}/${project.id}`
      hideFeedback()

      let methodInput = form.querySelector('input[name="_method"]')
      if (!methodInput) {
        methodInput = document.createElement('input')
        methodInput.type = 'hidden'
        methodInput.name = '_method'
        form.prepend(methodInput)
      }
      methodInput.value = 'patch'

      title.textContent = 'Edit project'
      submit.textContent = 'Update project'
      openModal()
    })
  })

  root.querySelectorAll('[data-project-delete]').forEach((button) => {
    button.addEventListener('click', () => {
      const project = JSON.parse(button.dataset.projectPayload)
      if (deleteText) {
        deleteText.textContent = `Apakah anda yakin akan menghapus Project ${project.title} ini?`
      }
      if (deleteForm) {
        deleteForm.action = `${deleteBase}/${project.id}`
      }
      openDeleteModal()
    })
  })

  form.addEventListener('submit', async (event) => {
    event.preventDefault()
    hideFeedback()

    const formData = new FormData(form)
    const method = form.querySelector('input[name="_method"]')?.value?.toUpperCase() || 'POST'

    try {
      const response = await fetch(form.action, {
        method,
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || '',
          'Accept': 'application/json'
        },
        body: formData
      })

      const payload = await response.json()

      if (response.status === 401) {
        window.location.href = loginPath
        return
      }

      if (!response.ok) {
        showFeedback(payload.message || 'Gagal menyimpan project.', 'error')
        return
      }

      showFeedback(payload.message || 'Project saved.')
      window.location.href = '/admin/projects'
    } catch (error) {
      showFeedback(`Gagal mengirim request: ${error.message}`, 'error')
    }
  })

  deleteForm?.addEventListener('submit', async (event) => {
    event.preventDefault()

    try {
      const response = await fetch(deleteForm.action, {
        method: 'DELETE',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || '',
          'Accept': 'application/json'
        }
      })

      const payload = await response.json()

      if (response.status === 401) {
        window.location.href = loginPath
        return
      }

      if (!response.ok) {
        showFeedback(payload.message || 'Gagal menghapus project.', 'error')
        closeDeleteModal()
        return
      }

      window.location.href = '/admin/projects'
    } catch (error) {
      showFeedback(`Gagal mengirim request: ${error.message}`, 'error')
      closeDeleteModal()
    }
  })

  root.querySelectorAll('[data-project-close]').forEach((button) => {
    button.addEventListener('click', closeModal)
  })

  root.querySelectorAll('[data-project-delete-close]').forEach((button) => {
    button.addEventListener('click', closeDeleteModal)
  })
}

document.addEventListener('turbo:load', initProjectModal)
document.addEventListener('DOMContentLoaded', initProjectModal)
