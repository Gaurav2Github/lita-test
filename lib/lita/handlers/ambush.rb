require 'pry'
require 'yaml'
module Lita
  module Handlers
    class Ambush < Handler
      # insert handler code here

      route(/^ambush:\s+(\S+):\s*(.+)/, :test)

      def test(response)
        store_hash = {
          time: Time.now.to_i,
          msg: response.matches[0][1]
        }.to_yaml

        redis.lpush(response.matches[0][0], store_hash)
        # binding.pry
        response.reply("#{response.user.name} I've stored the ambush")
      end


      Lita.register_handler(self)
    end
  end
end
