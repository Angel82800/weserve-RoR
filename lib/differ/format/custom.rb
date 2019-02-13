module Differ
  module Format
    module Custom
      class << self
        def format(change)
          (change.change? && as_change(change)) ||
          (change.delete? && as_delete(change)) ||
          (change.insert? && as_insert(change)) ||
          ''
        end

      private
        def as_insert(change)
          %Q{<p><b>Add:</b>&nbsp;#{change.insert}</p>}
        end

        def as_delete(change)
          %Q{<p><b>Remove:</b>&nbsp;#{change.delete}</p>}
        end

        def as_change(change)
          as_delete(change) << as_insert(change)
        end
      end
    end
  end
end