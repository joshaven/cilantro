dependency 'erubis'

module Cilantro
  class Template
    class Erubis < Plain
      # view > ??? Need to track this down to be sure... I think it is a path string to the erb file
      # context > object, probably 'self' from the requesting object
      # locals > Hash, ie: {:name => 'Joshaven', :color => 'silver'} 
      def render(view, context, locals)
        erb_text = render_upstream(view, context, locals)
        # 'context' proxy object for binding
        new_context = Object.new

        # Create instance variables & responder methods for each local passed
        locals.each do |k,v|
          new_context.instance_eval "def #{k};@#{k};end"
          new_context.send(:instance_variable_set, "@#{k}", v)
        end
        
        # If the new_context cannot respond, this passes the method request to the calling context/
        new_context.send(:instance_variable_set, :@context, context)
        new_context.instance_eval("def method_missing(m, *args);@context.send(m, *args);end")

        Erubis::Eruby.new IO.read(path).result new_context.instance_eval("binding")
      end
    end
  end
end
