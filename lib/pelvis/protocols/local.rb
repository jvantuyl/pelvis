module Pelvis
  module Protocols
    class Local < Protocol
      register :local

      SET = []

      def connect
        LOGGER.debug "connecting using #{self.class}: identity=#{identity.inspect}"
        succeed("connected as #{identity.inspect}")
      end

      def on_spawn(agent)
        SET << agent
      end

      def agent_for(identity)
        SET.find do |a|
          a.identity == identity
        end
      end

      def identity
        options[:identity] || raise("Local protocol needs an identity")
      end

      def herault
        "herault"
      end

      def advertise?
        identity != herault
      end
    end
  end
end
