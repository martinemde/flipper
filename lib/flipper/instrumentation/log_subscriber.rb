require 'securerandom'
require 'active_support/notifications'
require 'active_support/log_subscriber'

module Flipper
  module Instrumentation
    class LogSubscriber < ::ActiveSupport::LogSubscriber
      # Logs a feature operation.
      #
      # Example Output
      #
      #   flipper[:search].enabled?(user)
      #   # Flipper feature(search) enabled? false (1.2ms)  [ thing=... ]
      #
      # Returns nothing.
      def feature_operation(event)
        return unless logger.debug?

        feature_name = event.payload[:feature_name]
        gate_name = event.payload[:gate_name]
        operation = event.payload[:operation]
        result = event.payload[:result]
        thing = event.payload[:thing]

        description = "Flipper feature(#{feature_name}) #{operation} #{result.inspect}"
        details = "thing=#{thing.inspect}"

        unless gate_name.nil?
          details += " gate_name=#{gate_name}"
        end

        name = '%s (%.1fms)' % [description, event.duration]
        debug "  #{color(name, CYAN, true)}  [ #{details} ]"
      end

      def logger
        self.class.logger
      end
    end
  end

  Instrumentation::LogSubscriber.attach_to InstrumentationNamespace
end
