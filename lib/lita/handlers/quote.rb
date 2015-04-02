require 'text'
module Lita
  module Handlers
    class Quote < Handler

      config :date_format

      route /^qadd\s+(.*)$/, :add_quote, command: true,
        help: { "qadd <text>" => "Store quote following the command" }

      route /^addquote\s+(.*)$/, :add_quote, command: true,
        help: { "addquote <text>" => "Store quote following the command" }

      def add_quote(response)
        message = response.matches.flatten.first
        quote_id = redis.incr("last_id")
        
        quote_message = "##{quote_id}: #{message}"
        quote_message += " #{Time.now.strftime(config.date_format)}" if Lita.config.handlers.quote.date_format
        redis.hset("quotes", quote_id, quote_message)

        message.split.uniq.each do |word|
          redis.sadd("words:#{Text::Metaphone.metaphone(word)}", quote_id)
        end
        
        response.reply("Added quote ##{quote_id}")
      end

      route /^qget(?:\s*((?:\d+)|(?:\S.*)))?$/, :get_quote, command: true,
        help: { "qget [id|string]" => "Retrieve a quote by #id or randomly (optionally matching against a string)" }

      route /^getquote(?:\s*((?:\d+)|(?:\S.*)))?$/, :get_quote, command: true,
        help: { "getquote [id|string]" => "Retrieve a quote by #id or randomly (optionally matching against a string)" }

      def get_quote(response)
        search_key = response.matches.flatten.last
        if search_key
          if search_key.match(/\d+/)
            quote = redis.hget("quotes", search_key.to_i)
          else
            metaphone_keys = search_key.split.uniq.map do |word|
              "words:#{Text::Metaphone.metaphone(word)}"                                            
            end
            matching_ids = redis.sinter(metaphone_keys)
            quote = redis.hget("quotes", matching_ids.sample.to_i)
          end
        else
          quotes = redis.hvals("quotes")
          quote = quotes.sample
        end
        if quote
          response.reply(quote)
        else
          response.reply("No quote found")
        end
      end

      route /^qdel\s+(\d+)$/, :del_quote, command: true, restrict_to: ["quote_admins"],
        help: { "qdel <id>" => "Delete quote with given #id (quote_admins only)" }

      route /^delquote\s+(\d+)$/, :del_quote, command: true, restrict_to: ["quote_admins"],
        help: { "delquote <id>" => "Delete quote with given #id (quote_admins only)" }

      def del_quote(response)
        quote_id = response.matches.flatten.last.to_i
        quote = redis.hget("quotes", quote_id.to_i) 
        if redis.hdel("quotes", quote_id) == 1
          quote.split.uniq.each do |word|
            redis.srem("words:#{Text::Metaphone.metaphone(word)}", quote_id.to_i)
          end
          response.reply("Deleted quote ##{quote_id}")
        else
          response.reply("Quote ##{quote_id} does not exist")
        end
      end
    end

    Lita.register_handler(Quote)
  end
end
