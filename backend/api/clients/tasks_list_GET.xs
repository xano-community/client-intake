query "by-id/{client_id}/tasks" verb=GET {
  api_group = "Clients"
  description = "List all follow-up tasks for a client"
  input {
    int client_id filters=min:1
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

    db.query "client_tasks" {
      where = $db.client_tasks.client_id == $input.client_id
      sort = {due_date: "asc"}
      return = {type: "list"}
    } as $tasks
  }
  response = {
    success: true,
    client_id: $input.client_id,
    tasks: $tasks
  }
}
