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
    total: $clients.total,
    data: $clients
  }
}
