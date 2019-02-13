set :output, {:standard => 'log/cron_log.log', :error => 'log/cron_error_log.log'}
env :PATH, ENV['PATH']

every 1.minute do
  rake "weserve:fetch_btc_exchange_rate", :environment => 'production'
end

every 5.minutes do
  rake "balances:add_fund_to_balance", :environment => 'production'
end

every 1.day, :at => '5:30 am' do
  rake "task_summary:send_summary_notification", :environment => 'production'
end