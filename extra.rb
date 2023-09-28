
<div class = "right">
<div id="id01" class="edit">
<span onclick="window.location.href='/admin_main'" class="close" title="Close Modal">&times;</span>
<form action="/delete_process" method = "post">
  <div class="container">
  <div id = "user-table">
    <h1>Edit Employees</h1>
    <hr>
    <div class = "table-container">
    <table>
    <thead>
      <tr>
        <th>Employee ID</th>
        <th>First Name</th>
        <th>Last Name</th>
        <th>Active Status</th>
        <th> Edit </th>
        <th>Deactivate</th>
        <th>Pay Period</th>
        <th>Edit Work History</th>
        <th>View Past Pay Periods</th>
      </tr>
    </thead>
    <tbody>
      <% @users.each do |user| %>
        <tr>
          <td><%= user.employee_id %></td>
          <td><%= user.first_name %></td>
          <td><%= user.last_name %></td>
          <td><%= user.active %></td>
          <td> <button class = "edit-button" formaction = "/edit" data-id = "<%= user.id %>" >Edit</button> </td>
          <td><button class="delete-button" data-id="<%= user.id %>">X</button></td>
          <td>
            <button class="work_history" formaction = "/work_history_process" data-id="<%= user.id %>">Download</button>
          </td>
          <td>
              <button formaction = "/switch_work" method = "post" type="submit" class = "edit-button" data-id = "<%= user.id %>" >Edit</button>
          </td>
          <td>
            <button formaction = "/view_pay_reports" method = "post" type="submit" class = "work_history" data-id = "<%= user.id %>">View</button>
            </td>
            
        </tr>
      <% end %>
    </tbody>
  </table>
  </div>
  </div>
  <input type="hidden" id="user_id_input" name="user_id">
    </div>
    </form>
    </div>
</div>