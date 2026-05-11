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
