# This class is responsible for handling exceptions.
#
# Our service classes and controllers should not be awared of details of error
# reporting strategy we use: we may use no error reporting, we may use Rollbar
# or we may change Rollbar to Airbrake.
#
# Intention for this class is to:
#
# * Hide that we use Rollbar as error reporting from core classees
# * Be able to quickly disable Rollbar or to change it to different service
#   without the need to modify tons of application classes
# * Add more steps for error handling if we need
#   (like extra error logging, reports or notifications/webhooks)
#
# In future, this class can be rewritten using MacroCommand pattern using
# registered Commands.
class ErrorHandlerService
  class << self
    # Call error handling service
    #
    # Arguments:
    #
    #   +error+ instance of any +Exception+ object
    def call(error)
      report_error(error)
    end

    private
    def report_error(error)
      Rollbar.error(error)
    end
  end
end
