module Lita
  module Handlers
    class Quote < Handler

      route /^qadd\s+(.*)$/, :add_quote, command: true,
        help: { "qadd <text>" => "Store quote following the command" }

      route /^qget(\s*(\d+))?$/, :get_quote, command: true,
        help: { "qget [id]" => "Retrieve a quote by #id or randomly" }

      route /^delquote\s+(\d+)$/, :del_quote, command: true, restrict_to: ["admins"],
        help: { "qdel <id>" => "Delete quote with given #id (admins only)" }

      def add_quote(response)
        quote_id = redis.incr("last_id")
        redis.hset("list", quote_id, "#{Time.now.strftime("%Y%m%d-%H%M")} ##{quote_id}: #{response.matches.flatten.first}")
        response.reply("added quote ##{quote_id}")
      end

      def get_quote(response)
        if quote_id = response.matches.flatten.last
          quote = redis.hget("list", quote_id.to_i)
        else
          quotes = redis.hvals("list")
          quote = quotes[rand(quotes.length)]
        end

        if quote
          response.reply(quote)
        else
          response.reply("No quote found")
        end
      end

      def del_quote(response)
        quote_id = response.matches.flatten.last.to_i
        if redis.hdel("list", quote_id) == 1
          response.reply("Deleted quote ##{quote_id}")
        else
          response.reply("Quote ##{quote_id} does not exist")
        end
      end
    end

    Lita.register_handler(Quote)
  end
end
