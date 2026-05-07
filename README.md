# Taskflow API

A Rails API backend for a task workflow app. Tasks can be created, assigned to users, transitioned through workflow statuses, filtered, sorted by priority, and viewed with audit history.

## Tech Stack

- Ruby on Rails API
- PostgreSQL
- React frontend
- REST API

## Features

- Create tasks
- Assign tasks to users
- Transition tasks through:
  - Queued
  - Assigned
  - In Progress
  - Completed
- Track task audit history
- Filter tasks by status
- Sort tasks by priority
- Support current-user based workflow actions

## Setup

Install dependencies:

```bash
bundle install

Create and migrate the database:

rails db:create
rails db:migrate

Seed the database:

rails db:seed

Run the Rails server:

rails server

The API runs at:

http://localhost:3000
Useful Rails Console Commands

Check users:

rails console
User.all.pluck(:id, :name)

Expected sample users:

[[1, "Michael"], [2, "Sage"], [3, "Alex"]]
API Endpoints
Tasks

Get all tasks:

GET /tasks

Filter by status:

GET /tasks?status=queued

Sort by priority:

GET /tasks?sort=priority

Create a task:

POST /tasks

Assign a task:

PATCH /tasks/:id/assign

Transition a task:

PATCH /tasks/:id/transition
Example Workflow
queued → assigned → in_progress → completed
Frontend

The React frontend connects to:

http://localhost:3000