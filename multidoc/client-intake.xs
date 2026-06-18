workspace templates {
  acceptance = {ai_terms: false}
  preferences = {
    internal_docs    : false
    track_performance: true
    sql_names        : false
    sql_columns      : true
  }
}
---
table "client_tasks" {
  auth = false
  schema {
    int id
    int client_id {
      table = "clients"
      description = "Reference to the client"
    }
    text title filters=trim {
      description = "Follow-up task title"
    }
    date due_date {
      description = "Task due date"
    }
    enum status?="pending" {
      values = ["pending", "in_progress", "completed"]
      description = "Task status"
    }
    text notes? {
      description = "Internal task notes"
    }
    timestamp created_at?=now
    timestamp updated_at?=now
  }
  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree", field: [{name: "client_id"}]}
    {type: "btree", field: [{name: "status"}]}
    {type: "btree", field: [{name: "due_date", op: "asc"}]}
  ]
}
---
table "clients" {
  auth = false
  schema {
    int id
    text name filters=trim {
      description = "Client full name"
    }
    email email filters=trim|lower {
      description = "Client email address"
      sensitive = true
    }
    text phone? filters=trim {
      description = "Client phone number"
    }
    enum risk_tolerance {
      values = ["low", "medium", "high"]
      description = "Investment risk tolerance level"
    }
    text investment_objective filters=trim {
      description = "Client investment objective"
    }
    text advisor_notes? {
      description = "Internal advisor notes"
    }
    timestamp created_at?=now
    timestamp updated_at?=now
  }
  index = [
    {type: "primary", field: [{name: "id"}]}
    {type: "btree|unique", field: [{name: "email"}]}
    {type: "btree", field: [{name: "created_at", op: "desc"}]}
  ]
}
---
api_group Clients {
  canonical = "client-intake"
  description = "Client Intake - Advisor client onboarding and follow-up tasks"
  tags = ["advisor", "clients", "intake"]
}
---
query "create" verb=POST {
  api_group = "Clients"
  description = "Create a new client"
  input {
    text name filters=trim
    email email filters=trim|lower
    text phone? filters=trim
    enum risk_tolerance {
      values = ["low", "medium", "high"]
    }
    text investment_objective filters=trim
    text advisor_notes? filters=trim
  }
  stack {
    precondition ((($input.name|strlen) > 0)) {
      error_type = "inputerror"
      error = "Name is required"
    }

    precondition ((($input.email|strlen) > 0)) {
      error_type = "inputerror"
      error = "Email is required"
    }

    precondition ((($input.investment_objective|strlen) > 0)) {
      error_type = "inputerror"
      error = "Investment objective is required"
    }

    db.query "clients" {
      where = $db.clients.email == $input.email
      return = {type: "exists"}
    } as $email_exists

    precondition (!$email_exists) {
      error_type = "inputerror"
      error = "Email already exists"
    }

    db.add "clients" {
      data = {
        name: $input.name,
        email: $input.email,
        phone: $input.phone,
        risk_tolerance: $input.risk_tolerance,
        investment_objective: $input.investment_objective,
        advisor_notes: $input.advisor_notes
      }
    } as $new_client
  }
  response = {
    success: true,
    message: "Client created successfully",
    client: $new_client
  }
}
---
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
---
query "list" verb=GET {
  api_group = "Clients"
  description = "List all clients with pagination"
  input {
    int page?=1 filters=min:1
    int per_page?=20 filters=min:1|max:100
    text sort_by?="created_at" filters=trim|lower
    text sort_order?="desc" filters=trim|lower
  }
  stack {
    precondition ((["created_at", "name", "email", "risk_tolerance"]|some:$$ == $input.sort_by)) {
      error_type = "inputerror"
      error = "Invalid sort_by field"
    }

    precondition ((["asc", "desc"]|some:$$ == $input.sort_order)) {
      error_type = "inputerror"
      error = "Invalid sort_order"
    }

    conditional {
      if ($input.sort_by == "created_at" && $input.sort_order == "asc") {
        db.query "clients" {
          sort = {created_at: "asc"}
          return = {
            type: "list",
            paging: {page: $input.page, per_page: $input.per_page, totals: true}
          }
        } as $clients
      }
      elseif ($input.sort_by == "created_at" && $input.sort_order == "desc") {
        db.query "clients" {
          sort = {created_at: "desc"}
          return = {
            type: "list",
            paging: {page: $input.page, per_page: $input.per_page, totals: true}
          }
        } as $clients
      }
      elseif ($input.sort_by == "name" && $input.sort_order == "asc") {
        db.query "clients" {
          sort = {name: "asc"}
          return = {
            type: "list",
            paging: {page: $input.page, per_page: $input.per_page, totals: true}
          }
        } as $clients
      }
      elseif ($input.sort_by == "name" && $input.sort_order == "desc") {
        db.query "clients" {
          sort = {name: "desc"}
          return = {
            type: "list",
            paging: {page: $input.page, per_page: $input.per_page, totals: true}
          }
        } as $clients
      }
      elseif ($input.sort_by == "email" && $input.sort_order == "asc") {
        db.query "clients" {
          sort = {email: "asc"}
          return = {
            type: "list",
            paging: {page: $input.page, per_page: $input.per_page, totals: true}
          }
        } as $clients
      }
      elseif ($input.sort_by == "email" && $input.sort_order == "desc") {
        db.query "clients" {
          sort = {email: "desc"}
          return = {
            type: "list",
            paging: {page: $input.page, per_page: $input.per_page, totals: true}
          }
        } as $clients
      }
      elseif ($input.sort_by == "risk_tolerance" && $input.sort_order == "asc") {
        db.query "clients" {
          sort = {risk_tolerance: "asc"}
          return = {
            type: "list",
            paging: {page: $input.page, per_page: $input.per_page, totals: true}
          }
        } as $clients
      }
      else {
        db.query "clients" {
          sort = {risk_tolerance: "desc"}
          return = {
            type: "list",
            paging: {page: $input.page, per_page: $input.per_page, totals: true}
          }
        } as $clients
      }
    }
  }
  response = {
    success: true,
    page: $input.page,
    per_page: $input.per_page,
    total: $clients.itemsTotal,
    data: $clients
  }
}
---
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
---
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
---
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
---
query "by-id/{id}" verb=PATCH {
  api_group = "Clients"
  description = "Update client details"
  input {
    int id filters=min:1
    text name? filters=trim
    email email? filters=trim|lower
    text phone? filters=trim
    enum risk_tolerance? {
      values = ["low", "medium", "high"]
    }
    text investment_objective? filters=trim
    text advisor_notes? filters=trim
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

    conditional {
      if ($input.name) {
        precondition ((($input.name|strlen) > 0)) {
          error_type = "inputerror"
          error = "Name cannot be empty"
        }
      }
    }

    conditional {
      if ($input.investment_objective) {
        precondition ((($input.investment_objective|strlen) > 0)) {
          error_type = "inputerror"
          error = "Investment objective cannot be empty"
        }
      }
    }

    conditional {
      if ($input.risk_tolerance) {
        precondition ((["low", "medium", "high"]|some:$$ == $input.risk_tolerance)) {
          error_type = "inputerror"
          error = "Invalid risk tolerance value"
        }
      }
    }

    conditional {
      if ($input.email && $input.email != $client.email) {
        db.query "clients" {
          where = $db.clients.email == $input.email && $db.clients.id != $input.id
          return = {type: "exists"}
        } as $email_exists

        precondition (!$email_exists) {
          error_type = "inputerror"
          error = "Email already exists"
        }
      }
    }

    // Build a partial update of only the provided fields. (Avoid `||` here:
    // XanoScript `||` is logical-OR and yields a boolean, not a coalesce.)
    var $updates {
      value = {updated_at: now}
    }

    conditional {
      if ($input.name != null) {
        var.update $updates {value = $updates|set:"name":$input.name}
      }
    }
    conditional {
      if ($input.email != null) {
        var.update $updates {value = $updates|set:"email":$input.email}
      }
    }
    conditional {
      if ($input.phone != null) {
        var.update $updates {value = $updates|set:"phone":$input.phone}
      }
    }
    conditional {
      if ($input.risk_tolerance != null) {
        var.update $updates {value = $updates|set:"risk_tolerance":$input.risk_tolerance}
      }
    }
    conditional {
      if ($input.investment_objective != null) {
        var.update $updates {value = $updates|set:"investment_objective":$input.investment_objective}
      }
    }
    conditional {
      if ($input.advisor_notes != null) {
        var.update $updates {value = $updates|set:"advisor_notes":$input.advisor_notes}
      }
    }

    db.patch "clients" {
      field_name = "id"
      field_value = $input.id
      data = $updates
    } as $updated_client
  }
  response = {
    success: true,
    message: "Client updated successfully",
    client: $updated_client
  }
}
