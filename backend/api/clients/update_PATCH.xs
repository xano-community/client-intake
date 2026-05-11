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

    db.edit "clients" {
      field_name = "id"
      field_value = $input.id
      data = {
        name: $input.name || $client.name,
        email: $input.email || $client.email,
        phone: $input.phone || $client.phone,
        risk_tolerance: $input.risk_tolerance || $client.risk_tolerance,
        investment_objective: $input.investment_objective || $client.investment_objective,
        advisor_notes: $input.advisor_notes || $client.advisor_notes
      }
    } as $updated_client
  }
  response = {
    success: true,
    message: "Client updated successfully",
    client: $updated_client
  }
}
