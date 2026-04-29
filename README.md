# cms-adm

✨ Admin panel for the new portfolio CMS.

This repository is intended to be the internal management interface for the CMS ecosystem:

- `cms-be` → backend API service
- `cms-fe` → public-facing portfolio frontend
- `cms-adm` → authenticated admin dashboard for managing content

The admin panel should communicate with the backend exclusively through API requests. It must **not** access the database directly.

---

## 🎯 Project Goal

`cms-adm` is designed to provide a clean and practical interface for managing portfolio content, including:

- 👤 profile information
- 💼 projects
- 🧠 skills
- 🧾 experiences
- 🔗 social links
- 🔐 admin authentication
- 🖼️ future media/upload management

This application is meant to serve as the operational dashboard for the portfolio owner.

---

## 🧱 Platform Direction

This project is planned to follow the same platform/style direction as the older Rails-based portfolio system, while remaining a separate application from the backend.

### Current platform direction
- **Web admin application**
- **API-driven architecture**
- **Consumes `cms-be` endpoints only**
- **No direct PostgreSQL access**
- **Authentication handled through backend login endpoint**

### Architectural role
`cms-adm` is the control surface for content management, while `cms-be` remains the source of truth for business logic and persistence.

---

## 🧩 Planned Core Features

### Authentication
- admin login
- admin logout
- protected dashboard routes
- token/session handling for authenticated requests

### Content Management Modules
- profile management
- project CRUD
- skill CRUD
- experience CRUD
- social link CRUD

### Future Extensions
- media library / upload manager
- dashboard summary widgets
- draft/publish workflow (if later needed)
- richer validation and content preview

---

## 🔌 Backend Integration

The admin panel is expected to integrate with the following backend API groups:

- `POST /api/v1/admin/auth/login`
- `POST /api/v1/admin/auth/logout`
- `GET /api/v1/admin/profile`
- `PUT /api/v1/admin/profile`
- `GET /api/v1/admin/projects`
- `POST /api/v1/admin/projects`
- `PUT /api/v1/admin/projects/:id`
- `DELETE /api/v1/admin/projects/:id`
- `GET /api/v1/admin/skills`
- `POST /api/v1/admin/skills`
- `PUT /api/v1/admin/skills/:id`
- `DELETE /api/v1/admin/skills/:id`
- `GET /api/v1/admin/experiences`
- `POST /api/v1/admin/experiences`
- `PUT /api/v1/admin/experiences/:id`
- `DELETE /api/v1/admin/experiences/:id`
- `GET /api/v1/admin/social-links`
- `POST /api/v1/admin/social-links`
- `PUT /api/v1/admin/social-links/:id`
- `DELETE /api/v1/admin/social-links/:id`

---

## 🛠️ Dependency Status

At the moment, this repository is still in initialization stage, so the dependency list is split into two categories:

### 1. Already decided
These are architectural/stack decisions that are already clear:

- **Backend API source:** `cms-be`
- **API communication:** HTTP/JSON
- **Authentication flow:** backend-driven login/logout
- **Data source policy:** API only, no direct DB access

### 2. Planned application dependencies
These are the dependencies expected to be used once scaffolding begins, but are not yet finalized in code at the time this README was written.

Possible dependency categories:

- **Frontend framework / app runtime**
- **UI component library**
- **form handling**
- **validation library**
- **HTTP client**
- **state management**
- **routing**
- **authentication token/session storage helper**
- **table/list management utilities**
- **date formatting helpers**
- **file upload helpers**

> Important: dependency names and versions are **not finalized yet**. They should be documented precisely once the project scaffold is created.

---

## 📦 Expected Module Areas

A likely initial module layout for `cms-adm`:

- login page
- dashboard shell/layout
- profile page
- projects management page
- skills management page
- experiences management page
- social links management page
- shared API client layer
- auth/session helper layer
- reusable form components

---

## 🔐 Authentication Notes

The backend currently provides login and logout endpoints.

Expected admin login flow:
1. submit email + password
2. receive auth token from `cms-be`
3. store token in the admin app runtime
4. attach token to protected admin API requests
5. clear token on logout

---

## 🧭 Development Status

Current status of `cms-adm`:

- repository initialized
- GitHub remote connected
- README drafted
- application scaffold not started yet
- dependencies not installed yet
- platform implementation still pending

So this README currently describes the **project contract and intended direction**, not a finished implementation.

---

## 🛣️ Suggested Next Steps

1. choose the exact admin app stack/platform
2. scaffold the admin application
3. install real dependencies
4. connect login flow to `cms-be`
5. build CRUD screens module by module
6. refine UX and validation

---

## 📌 Relationship to Other Repositories

- `cms-be` → business logic, persistence, auth source, API
- `cms-adm` → internal admin dashboard
- `cms-fe` → public portfolio frontend

Together they form a 3-repository CMS portfolio architecture.

---

## 🔒 License

Private project for internal development.
