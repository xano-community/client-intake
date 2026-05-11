query "by-id/{client_id}/tasks" verb=POST {
  api_group = "Clients"
  description = "Create a follow-up task for a client"
  input {
    int client_id filters=min:1
    text title filters=trim
    date due_date
    enum status?="pending" {
      values = ["pending", "in_progress", "completed"]
    }
    text notes? filters=trim
  }
  stack {
    db.get "clients" {
      field_name = "id"
      field_value = $input.client_id
    } as $client

    precondition ($client) {
      error_type = "notfound"
      error = "Client not found"
    }

    precondition ((($input.title|strlen) > 0)) {
      error_type = "inputerror"
      error = "Task title is required"
    }

    db.add "client_tasks" {
      data = {
        client_id: $input.client_id,
        title: $input.title,
        due_date: $input.due_date,
        status: $input.status,
        notes: $input.notes
      }
    } as $task
  }
  response = {
    success: true,
    message: "Task created successfully",
    task: $task
  }
}
