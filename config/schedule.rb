# Use this file to define all tasks, which should be executed by cron
# Learn more: http://github.com/javan/whenever

# Upcoming tasks notifier
every :day, :at => '7:20 am' do
  rake "multicoops:run TASK=foodsoft:notify_upcoming_tasks"
end

# Import and assign bank transactions
every :weekday, :at => %w(5:56am 6:04pm) do
  rake "multicoops:run TASK=foodsoft:import_and_assign_bank_transactions"
end

# Weekly taks
every :sunday, :at => '7:14 am' do
  rake "multicoops:run TASK=foodsoft:create_upcoming_periodic_tasks"
  rake "multicoops:run TASK=foodsoft:notify_users_of_weekly_task"
end