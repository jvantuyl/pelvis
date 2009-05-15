require 'blather'
require 'json'
require 'base64'

module Pelvis
  module Protocols
    class XMPP < Protocol
      register :xmpp

      def connect
        logger.debug "connecting using #{self.class}: #{options.inspect}"
        @stream = Blather::Stream::Client.start(self, jid, options[:password])
      end
      attr_reader :stream

      def stream_started(stream)
        connected
      end

      def stopped
        logger.warn "Got disconnected"
      end

      def call(stanza)
        logger.debug "got a stanza for #{identity}:\n#{stanza.inspect}"
        if stanza.is_a?(Blather::SASLError)
          failed stanza.message
          return
        end
        remote_agent = agent_for(stanza["from"])
        node = stanza.find("job").first
        token = node["token"]

        type = node["type"]
        unless %w( init begin data end ).include?(type)
          raise "Unable to handle job XML of type: #{type.inspect}"
        end

        case stanza["type"]
        when "set"
          remote_agent.send("handle_job_#{type}", stanza, node, token)
        when "result"
          remote_agent.handle_result(stanza, node, token)
        when "error"
          remote_agent.handle_error(stanza, node, token)
        else
          raise "Unable to handle weird IQ with type: #{stanza["type"].inspect}"
        end
      end

      def evoke(identity, job)
        agent_for(identity).evoke(job)
      end

      def agent_for(identity)
        agents[identity] ||= RemoteAgent.new(self, identity)
      end

      def agents
        @agents ||= {}
      end

      def jid=(jid)
      end

      def jid
        Blather::JID.new(identity)
      end

      def identity
        options[:jid] || raise("XMPP protocol needs an JID")
      end

      def herault
        "herault@localhost/agent"
      end

      def advertise?
        identity != herault
      end
    end
  end
end

require 'pelvis/protocols/xmpp/remote_agent'
require 'pelvis/protocols/xmpp/incall'
