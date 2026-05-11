query "by-id/{id}" verb=GET {
  api_group = "Clients"
  description = "Get a single client by ID"
  input {
    int id filters=min:1
  }
  stack {
    db.get "clients" {
      field_name = "id"
      field_value = $input.id
    } as $client

    precondition ($client) {
      error_type = "notfound"
      error = "Client not found"
    }
  }
  response = {
    success: true,
    client: $client
  }
}
