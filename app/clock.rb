require 'clockwork'
require './config/boot'
require './config/environment'

include Clockwork

every(5.minutes, 'update_balances_in_hold') {
  Delayed::Job.enqueue UpdateHoldBalancesJob.new
}
