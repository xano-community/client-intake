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
