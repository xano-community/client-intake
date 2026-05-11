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
