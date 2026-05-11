query "tasks/{task_id}/complete" verb=PATCH {
  api_group = "Clients"
  description = "Mark a client follow-up task as complete"
  input {
    int task_id filters=min:1
  }
  stack {
    db.get "client_tasks" {
      field_name = "id"
      field_value = $input.task_id
    } as $task

    precondition ($task) {
      error_type = "notfound"
      error = "Task not found"
    }

    db.edit "client_tasks" {
      field_name = "id"
      field_value = $input.task_id
      data = {
        client_id: $task.client_id,
        title: $task.title,
        due_date: $task.due_date,
        status: "completed",
        notes: $task.notes,
        created_at: $task.created_at,
        updated_at: now
      }
    } as $updated_task
  }
  response = {
    success: true,
    message: "Task marked as complete",
    task: $updated_task
  }
}
