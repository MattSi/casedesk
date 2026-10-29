# Demo data for the Today page.
# Safe to run again: it deletes the demo firm and builds it fresh, so every date is relative to now.

DEMO_FIRM = "Harbor & Pine LLP"

if (old_firm = Firm.find_by(name: DEMO_FIRM))
  CalendarEvent.where(firm: old_firm).delete_all
  Task.where(firm: old_firm).delete_all
  Matter.where(firm: old_firm).delete_all
  Contact.where(firm: old_firm).delete_all
  Session.where(user: User.where(firm: old_firm)).delete_all
  User.where(firm: old_firm).delete_all
  old_firm.delete
end

firm = Firm.create!(name: DEMO_FIRM, time_zone: "Pacific Time (US & Canada)")
now = firm.now

# A time on a day relative to today, e.g. at.(2, 10) is 10:00 AM two days from now
at = ->(days, hour, min = 0) { (now + days.days).change(hour: hour, min: min) }

emily = firm.users.create!(name: "Emily Foster", email_address: "demo@example.com", password: "password")
david = firm.users.create!(name: "David Chen", email_address: "david@example.com", password: "password")

harrington = firm.contacts.create!(name: "Margaret Harrington", email: "margaret@example.com")
okafor = firm.contacts.create!(name: "Daniel Okafor", email: "daniel@example.com")
nguyen = firm.contacts.create!(name: "Linh Nguyen", email: "linh@example.com")
brightwater = firm.contacts.create!(name: "Brightwater Holdings")

termination = firm.matters.create!(client: harrington, title: "Wrongful termination claim",
                                   practice_area: "Employment", opened_on: now.to_date - 90)
injury = firm.matters.create!(client: okafor, title: "Motor vehicle accident",
                              practice_area: "Personal Injury", opened_on: now.to_date - 45)
estate = firm.matters.create!(client: nguyen, title: "Estate of Thanh Nguyen",
                              practice_area: "Wills & Estates", opened_on: now.to_date - 20)
lease = firm.matters.create!(client: brightwater, title: "Commercial lease dispute",
                             practice_area: "Real Estate", opened_on: now.to_date - 10)

# Overdue: shows in Top priority
[
  [ termination, "Review settlement offer", "Opposing counsel sent revised terms. Client wants a call first.", now - 3.days - 2.hours ],
  [ injury, "Request medical records", "St. Paul's Hospital, admission and follow-up visits.", now - 1.day - 4.hours ],
  [ estate, "File probate application", nil, now - 5.days ],
  [ lease, "Reply to landlord's demand letter", "Deadline in the letter has passed. Send a holding reply.", now - 2.hours ]
].each do |matter, title, description, due_at|
  Task.create!(matter: matter, assignee: emily, title: title, description: description, due_at: due_at)
end

# Upcoming: the next 7 days
[
  [ termination, "Prepare mediation brief", at.(1, 15) ],
  [ injury, "Draft demand letter to insurer", at.(2, 11) ],
  [ estate, "Send asset list to executor", at.(3, 9, 30) ],
  [ lease, "Review lease renewal clause", at.(5, 14) ],
  [ termination, "Book expert witness", at.(6, 10) ]
].each do |matter, title, due_at|
  Task.create!(matter: matter, assignee: emily, title: title, due_at: due_at)
end

# Done, and David's work: neither shows on Emily's Today page
Task.create!(matter: injury, assignee: emily, title: "Open client file", due_at: now - 10.days,
             status: :completed, completed_at: now - 11.days)
Task.create!(matter: lease, assignee: david, title: "Pull title search", due_at: now - 1.day)

[
  [ termination, "Mediation with Harrington", at.(2, 9), at.(2, 12), "Vancouver Mediation Centre" ],
  [ nil, "Team meeting", at.(1, 9), at.(1, 10), "Boardroom" ],
  [ injury, "Call with Daniel Okafor", at.(4, 13), at.(4, 13, 30), "Phone" ],
  [ estate, "Meet executor", at.(6, 15), at.(6, 16), nil ]
].each do |matter, title, starts_at, ends_at, location|
  CalendarEvent.create!(user: emily, matter: matter, title: title,
                        starts_at: starts_at, ends_at: ends_at, location: location)
end

puts "Seeded #{DEMO_FIRM}. Sign in as demo@example.com / password"
