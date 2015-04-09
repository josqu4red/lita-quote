require 'text'
module Lita
  module Handlers
    class Quote < Handler

      config :date_format
      config :metaphone_exclusions

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
        index_quote(message, quote_id)
        response.reply("Added quote ##{quote_id}")
      end

      route /^qget(?:\s*((?:\d+)|(?:\S.*)))?$/, :get_quote, command: true,
        help: { "qget [id|string]" => "Retrieve a quote by #id or randomly (optionally matching against a string)" }

      route /^getquote(?:\s*((?:\d+)|(?:\S.*)))?$/, :get_quote, command: true,
        help: { "getquote [id|string]" => "Retrieve a quote by #id or randomly (optionally matching against a string)" }

      def get_quote(response)
        search_key = response.matches.flatten.last
        case search_key
        when /^\d+$/
          quote = redis.hget("quotes", search_key.to_i)
        when /^.+$/
          metaphone_keys = map_to_index(search_key)
          matching_ids = redis.sinter(metaphone_keys)
          quote = redis.hget("quotes", matching_ids.sample.to_i)
        else
          quotes = redis.hvals("quotes")
          quote = quotes.sample
        end
        response.reply( quote ? quote : "No quote found")
      end

      route /^qdel\s+(\d+)$/, :del_quote, command: true, restrict_to: ["quote_admins"],
        help: { "qdel <id>" => "Delete quote with given #id (quote_admins only)" }

      route /^delquote\s+(\d+)$/, :del_quote, command: true, restrict_to: ["quote_admins"],
        help: { "delquote <id>" => "Delete quote with given #id (quote_admins only)" }

      def del_quote(response)
        quote_id = response.matches.flatten.last.to_i
        quote = redis.hget("quotes", quote_id.to_i) 
        if redis.hdel("quotes", quote_id) == 1
          map_to_index(quote).each { |i| redis.srem(i, quote_id.to_i) }
          response.reply("Deleted quote ##{quote_id}")
        else
          response.reply("Quote ##{quote_id} does not exist")
        end
      end
    
      route /^reindex$/, :rebuild_index, command:true, restrict_to: ["quote_admins"],
        help: { "reindex" => "Delete and rebuild the quote search index" }
  
      def rebuild_index(response)
        redis.keys("words:*").each { |k| redis.del(k) }
        last_quote = redis.get("last_id").to_i
        (1..last_quote).each { |id| index_quote(redis.hget("quotes", id), id) }
      end
    
      def map_to_index(str)
        str.split.uniq.map do |word|
          if Lita.config.handlers.quote.metaphone_exclusions.any? { |regex| regex.match(word) }
            "words:#{word}"
          else
            "words:#{Text::Metaphone.metaphone(word)}"                                            
          end
        end
      end
      
      def index_quote(str, id)
        map_to_index(str).each { |word| redis.sadd(word, id) }
      end
    end

    Lita.register_handler(Quote)
  end
end
