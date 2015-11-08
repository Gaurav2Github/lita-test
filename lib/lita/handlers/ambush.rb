require 'pry'
require 'yaml'
module Lita
  module Handlers
    class Ambush < Handler
      # insert handler code here

      route(/^ambush:\s+(\S+):\s*(.+)/, :test, command: true)
      route(/./, :reading)

      def test(response)
        store_hash = {
          time: Time.now.to_i,
          msg: response.matches[0][1],
          ambusher: response.user.name
        }.to_yaml

        redis.lpush(response.matches[0][0], store_hash)
        # binding.pry
        response.reply("#{response.user.name} I've stored the ambush")
      end

      def reading(response)
        # binding.pry
        unless response.message.body.start_with? "ambush"
          stored_yaml = redis.rpop(response.user.name)
          while not stored_yaml.nil? do
            outputted_yaml = YAML.load(stored_yaml)
            response.reply("#{response.user.name}: While you were out, #{outputted_yaml[:ambusher]} said: #{outputted_yaml[:msg]}")
            stored_yaml = redis.rpop(response.user.name)
          end
          
        end

      end


      Lita.register_handler(self)
    end
  end
end
