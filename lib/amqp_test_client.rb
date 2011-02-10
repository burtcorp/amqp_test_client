# encoding: utf-8

require 'bundler/setup'
require 'eventmachine'
require 'mq'


Signal.trap('INT')  { AMQP.stop { EM.stop } }
Signal.trap('TERM') { AMQP.stop { EM.stop } }

def run(host, exchange_name)
  EM.run do
    AMQP.start(:host => host) do
      amqp_channel = MQ.new
      amqp_channel.fanout(exchange_name) do |exch|
        exchange = exch
        amqp_channel.queue(exchange_name) do |q, message_count, consumer_count|
          queue = q
          queue.bind(exchange) do
            yield exchange, queue
          end
        end
      end
    end
  end
end
