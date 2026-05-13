# cms-adm

🛠️ Admin control panel for the Heru Oktafian portfolio CMS.

Built with **Ruby on Rails 8**, **Hotwire (Turbo + Stimulus)**, and **Tailwind CSS**. This repository provides a private admin interface for managing all portfolio content — skills, tools, projects, experiences, social links, and contact messages — via the [`cms-be`](https://github.com/heru-oktafian/cms-be) backend API.

> Both `cms-adm` and [`cms-fe`](https://github.com/heru-oktafian/cms-fe) share the same backend (`cms-be`). `cms-adm` is the admin panel; `cms-fe` is the public portfolio site.

---

## 🚀 Stack

- **Ruby on Rails 8.1**
- **Hotwire** (`turbo-rails` + `stimulus-rails`) — SPA-like page transitions
- **Tailwind CSS** — utility-first styling
- **Propshaft** — modern asset pipeline
- **Kamal** — zero-downtime deployment
- **Docker** — containerized deployment support
- **`cms-be`** — backend API (Go + Fiber + PostgreSQL)

---

## 📌 Features

- **8 content modules:** Profile, Skills, Tools, Projects, Experiences, Social Links, Messages, Dashboard
- **CRUD operations** for all portfolio modules via RESTful routes
- **Inline search & filtering** in datatable views
- **Modal-based forms** for create/edit workflows
- **Session-based admin authentication**
- **PWA-ready** with custom icons and viewport support
- **Responsive sidebar** with active state indicators
- **Contact message management** — mark as read/unread

---

## 🗂️ Project Structure

```text
cms-adm/
├── app/
│   ├── controllers/
│   │   ├── admin_resources_controller.rb  # main CRUD handler for all modules
│   │   ├── application_controller.rb      # auth, navigation, helpers
│   │   ├── dashboard_controller.rb       # admin dashboard + menu config
│   │   └── sessions_controller.rb         # admin login/logout
│   ├── javascript/
│   │   ├── application.js                # entry point
│   │   └── controllers/
│   │       ├── datatable_filter_controller.js  # table search & filtering
│   │       └── sidebar_controller.js     # mobile sidebar toggle
│   ├── views/
│   │   ├── admin_resources/
│   │   │   ├── datatable.html.erb    # resource list with filters
│   │   │   ├── profile.html.erb       # profile edit form
│   │   │   ├── project_form.html.erb # create/edit project modal
│   │   │   └── show.html.erb          # main sidebar + content layout
│   │   ├── dashboard/
│   │   │   └── index.html.erb        # admin dashboard
│   │   ├── layouts/
│   │   │   └── application.html.erb   # PWA-aware layout
│   │   └── sessions/
│   │       └── new.html.erb          # login page
│   └── views/admin_resources/         # section partials
├── config/
│   ├── routes.rb                     # all CRUD routes
│   └── environments/development.rb
├── lib/                              # custom helpers/extensions
├── config.ru                         # Rack config
├── Dockerfile                        # production Docker image
├── .kamal/                           # Kamal deployment config
├── Gemfile                           # Rails + Kamal + Docker deps
├── Procfile.dev                      # development process types
├── bin/dev                           # starts Rails + JS/CSS watchers
└── package.json                      # Tailwind CSS config
```

---

## ⚙️ Environment Variables

Copy the example file and adjust values:

```bash
cp .env.example .env
```

Key variables:

```env
CMS_BE_BASE_URL=http://127.0.0.1:8080
PORT=3000
```

> Make sure the backend (`cms-be`) is running first. `cms-adm` communicates with it via HTTP.

---

## ▶️ Running Locally

Make sure the backend (`cms-be`) is running. Then:

```bash
# Install dependencies
bundle install
yarn install

# Start dev server (Rails + esbuild watch + Tailwind CSS)
./bin/dev
```

The app should be available at:

```text
http://127.0.0.1:3000
```

Navigate to `/login` to access the admin panel.

---

## 🏗️ Production Build

```bash
yarn build        # compile JS via esbuild
yarn build:css    # compile Tailwind CSS
rails assets:precompile
```

---

## 🚢 Deployment (Kamal)

This project uses **Kamal** for zero-downtime deployment to a configured server.

```bash
# First-time setup
kamal setup

# Deploy (pushes Docker image + runs health checks)
kamal deploy

# Rollback to previous release
kamal rollback
```

Deployments use the `Dockerfile` in the project root and target a configured server in `.kamal/config.yml`.

---

## 🔗 API Integration

`cms-adm` communicates with the backend via the `cms-be` HTTP API. The backend owns all data; `cms-adm` sends CRUD requests to:

```text
/api/v1/...
```

API endpoints used internally:

| Module | Create | Update | Delete |
|--------|--------|--------|--------|
| Profile | — | `PATCH /api/v1/admin/profile` | — |
| Skills | `POST /api/v1/admin/skills` | `PATCH /api/v1/admin/skills/:id` | `DELETE /api/v1/admin/skills/:id` |
| Tools | `POST /api/v1/admin/tools` | `PATCH /api/v1/admin/tools/:id` | `DELETE /api/v1/admin/tools/:id` |
| Projects | `POST /api/v1/admin/projects` | `PATCH /api/v1/admin/projects/:id` | `DELETE /api/v1/admin/projects/:id` |
| Experiences | `POST /api/v1/admin/experiences` | `PATCH /api/v1/admin/experiences/:id` | `DELETE /api/v1/admin/experiences/:id` |
| Social Links | `POST /api/v1/admin/social-links` | `PATCH /api/v1/admin/social-links/:id` | `DELETE /api/v1/admin/social-links/:id` |
| Contact Messages | — | `PATCH /api/v1/admin/contact-messages/:id` | — |

---

## 🔐 Authentication

Admin login uses session-based authentication managed by `SessionsController`. There is no separate admin user registration — admin credentials are managed on the backend.

---

## 🔒 License

Private project for internal development.