module Pelvis
  class Job
    def self.create(token, operation, args, options, parent, &block)
      klass = Job
      if block_given?
        klass = Class.new(Job, &block)
      end
      klass.new(token, operation, args, options, parent)
    end

    def initialize(token, operation, args, options, parent)
      @token, @operation, @args, @options, @parent = token, operation, args, options, parent
      @token << ":#{@parent.job.token}" if @parent
    end
    attr_reader :token, :operation, :args, :options, :parent

    def receive(data)
      LOGGER.debug "data: Doing nothing with #{data.inspect}"
    end

    def complete(event)
      LOGGER.debug "complete: Doing nothing with #{event.inspect}"
    end

    def error(event)
      LOGGER.debug "error: Doing nothing with #{event.inspect}"
    end
  end
end
