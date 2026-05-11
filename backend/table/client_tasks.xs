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
