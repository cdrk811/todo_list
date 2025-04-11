# TODO List API

This is a RESTful API for managing a TODO list, including task creation, listing, updating, deletion, and reordering (
used for drag-and-drop functionality).

## Features

- List all tasks
- Add a task
- Update a task
- Delete a task
- Reorder tasks (like drag-and-drop)

All API responses return JSON.

---

## Base URL

http://localhost:3000

---

## Endpoints

### 1. Get All Tasks
- Returns a list of all tasks.

**GET** `/api/v1/tasks`

#### Response:
```json
{
  "status": 200,
  "success": true,
  "message": "Success",
  "data": [
    {
        "id": 1,
        "title": "Task 1",
        "description": "Description for Task 1",
        "sequence": 1,
        "created_at": "2025-04-10T10:07:55.965Z",
        "updated_at": "2025-04-10T13:13:40.521Z"
    },
    {
        "id": 2,
        "title": "Task 2",
        "description": "Description for Task 2",
        "sequence": 2,
        "created_at": "2025-04-10T10:07:55.972Z",
        "updated_at": "2025-04-10T13:13:40.529Z"
    },
    ...
  ]
}
```

### 2. Create a New Task

**POST** `/api/v1/tasks`

#### Request Body:
```json
{
  "task": {
    "title": "Task 101",
    "description": "Description for Task 101"
  }
}
```


#### Response:
```json
{
  "status": 200,
  "success": true,
  "message": "Success",
  "data": {
    "id": 101,
    "title": "Task 101",
    "description": "Description for Task 101",
    "sequence": 101,
    "created_at": "2025-04-11T05:50:48.223Z",
    "updated_at": "2025-04-11T05:50:48.223Z"
  }
}
```

### Error Example
```json
{
    "status": 422,
    "success": false,
    "errors": [
        "Title can't be blank"
    ]
}
```

### 3. Update a Task

**PUT/PATCH** `/api/v1/tasks/:id`

#### Request Body:
```json
{
  "task": {
    "title": "Updated Task 1",
    "description": "Updated Description for Task 1"
  }
}
```

#### Response:
```json
{
  "status": 200,
  "success": true,
  "message": "Success",
  "data": {
    "title": "Updated Task 1",
    "description": "Updated Description for Task 1",
    "id": 1,
    "sequence": 1,
    "created_at": "2025-04-10T10:07:55.381Z",
    "updated_at": "2025-04-11T05:54:14.287Z"
  }
}
```

#### Error Example
```json
{
    "status": 422,
    "success": false,
    "errors": [
        "Title can't be blank"
    ]
}
```

### 4. Delete a Task

**DELETE** `/api/v1/tasks/:id`

#### Response:
```json
{
  "status": 200,
  "success": true,
  "message": "Success",
  "data": {
    "id": 101,
    "title": "Task 101",
    "description": "Description for Task 101",
    "sequence": 101,
    "created_at": "2025-04-11T05:50:48.223Z",
    "updated_at": "2025-04-11T05:50:48.223Z"
  }
}
```

### 5. Reorder Tasks (Drag and Drop)

**PATCH** `/api/v1/tasks/reorder`

#### Request Body:
```json
{
  "tasks": [
    { "id": 100, "sequence": 1 }
  ]
}
```

#### Response:
```json
{
  "status": 200,
  "success": true,
  "message": "Success",
  "data": [
    {
      "id": 100,
      "title": "Task 100",
      "description": "Description for Task 100",
      "sequence": 1,
      "created_at": "2025-04-10T10:07:56.059Z",
      "updated_at": "2025-04-11T06:03:32.597Z"
    }
  ]
}
```

## Why I use bulk update for reorder?
- When you need to update the order of a bunch of tasks — especially if you’re dealing with hundreds or even millions — doing it one-by-one is like telling the database, “Hey, update this one. Now this one. And now this one…” over and over. That takes time.
- Instead, I use bulk update to say, “Here’s the full list of updates — do them all at once.” It’s way faster, easier on the system, and helps us meet performance goals like updating up to 1 million tasks in under 5 seconds.
