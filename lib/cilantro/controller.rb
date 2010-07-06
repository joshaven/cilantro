########################################################################
# Module: Cilantro::Controller
# Provides Controller methods
#
# To generate rich pages, see: <Cilantro::Templater>
module Cilantro
  module Controller
    # include Sinatra::Helpers

    attr_reader :application
  
    ########################################################################
    # Method: namespace(string)
    # Define namespace for the next routes. The namespace will be prepended to routes.
    # The namespace is also saved for each route and used to find views for that
    # route.
    #
    # Example: 
    # > namespace = '/people'
    # > get 'new' do 
    # >   view :new
    # > end
    # > # GET /people/new
    # > #  -> action is run, view is found in: /views/people/new.haml
    def namespace(new_namespace=nil, name=nil, &block)
      return @namespace ||= '/' if new_namespace.nil? # For use as a getter method

      # Ensure setter has valid input
      unless new_namespace.is_a?(String) || new_namespace.is_a?(Symbol) || new_namespace.is_a?(Hash)
        raise ArgumentError, "Controller namespace (aka scope or path) must be a string, a symbol, or a hash with string values."
      end

      # # Handle hash instance
      if new_namespace.is_a? Hash
        new_namespace.each_pair {|n, ns| block_given? ? namespace(ns,n) { block.call } : namespace(ns,n)}
      else
        # Set namespace variable: ensure it begins, but not ends, with a slash and never has multiple consecutive slashes
        @next_route_name = name if name
        @namespace = ('/' + new_namespace.to_s).gsub(/\/$/,'').gsub(/\/+/,'/')
      end
    end
    # def namespace(new_namespace=nil,name=nil,&block)
    #   if !new_namespace.nil? && !(new_namespace.is_a?(String) || new_namespace.is_a?(Symbol) || new_namespace.is_a?(Hash))
    #     raise ArgumentError, "Controller namespace (aka scope or path) must be a string, a symbol, or a hash with string values."
    #   end
    #   @namespace ||= '/'
    #   if new_namespace.is_a?(Hash)
    #     new_namespace.each do |name,new_namespace|
    #       block_given? ? namespace(new_namespace,name) { block.call } : namespace(new_namespace,name)
    #     end
    #   else
    #     # Here we have just one namespace and *possibly* a name to save for the first route registered with this namespace.
    #     # Sanitize new namespace to NOT end with a slash OR begin with a slash.
    #     @next_route_name = new_namespace if new_namespace.is_a?(Symbol)
    #     new_namespace = new_namespace.to_s.gsub(/(^\/|\/$)/,'') if new_namespace
    #     @next_route_name = name if name
    #     # Join namespace to previous namespace by a slash.
    #     if block_given?
    #       old_namespace = @namespace
    #       @namespace = @namespace.gsub(/\/$/,'')+'/'+new_namespace
    #       yield
    #       @namespace = old_namespace
    #     else
    #       if new_namespace.nil?
    #         @namespace
    #       else
    #         @namespace = @namespace.gsub(/\/$/,'')+'/'+new_namespace
    #       end
    #     end
    #   end
    # end

    alias :scope :namespace
    alias :path :namespace

    def get(path='', opts={}, &bk);    route 'GET',    path, opts, &bk end
    def put(path='', opts={}, &bk);    route 'PUT',    path, opts, &bk end
    def post(path='', opts={}, &bk);   route 'POST',   path, opts, &bk end
    def delete(path='', opts={}, &bk); route 'DELETE', path, opts, &bk end
    def head(path='', opts={}, &bk);   route 'HEAD',   path, opts, &bk end

    # Allows a helper method to be defined in the controller class.
    def helper_method(name, &block)
      application.send(:define_method, name, &block)
    end

    # # accept reads the HTTP_ACCEPT header.
    # Application.send(:define_method, :accepts, Proc.new { @env['HTTP_ACCEPT'].to_s.split(',').map { |a| a.strip.split(';',2)[0] }.reverse })
    # Application.send(:define_method, :required_params, Proc.new { |*parms|
    #   not_present = parms.inject([]) do |a,(k,v)|
    #     a << k unless params.has_key?(k.to_s)
    #     a
    #   end
    #   throw :halt, [400, "Required POST params not present: #{not_present.join(', ')}\n"] unless not_present.empty?
    # })

    ########################################################################
    # Method: error(*errors, &block)
    # Define the proper response for errors.
    #
    # Expected Output: HTTP message body (String).
    #
    # Example: 
    # > error do
    # >   Cilantro.report_error(env['sinatra.error'])   # this could jabber the error to the admin
    # >   return 'Something went wrong!'
    # > end
    def error(*raised, &block)
      application.error(*raised, &block)
    end

    def not_found(&block)
      error 404, &block
    end

    def before(&block)
      application.before(&block)
    end

    # Same as :helper_method except that the name will be prefixed with the controller name.
    #
    # ie: helper :total do ... end 
    #     will become "#{self.name}_total" where self.name is the class name of this controller. 
    def helper(name, &block)
# warn "Defining helper #{self.name.to_s + '_' + name.to_s}"
      application.send(:define_method, self.name.to_s + '_' + name.to_s, &block)
      # helper_method "#{self.name}_#{name}" &block
    end

  private
    def route(method, in_path, opts, &bk)
# TODO: DRY this method up!
      if in_path.is_a?(Hash)
        # here, rts is the collection, path is the key, name is the value
        return in_path.inject([]) do |rts,(path,name)|
          path = path_with_namespace(path)
          # warn "Route: #{method} #{path[0]}"
          # Save the namespace with this route
          application.namespaces["#{method} #{path[0]}"] = [self, namespace]
          # Register the path with Sinatra's routing engine
          rt = application.send(method.downcase, path[0], opts, &bk)
          rt[1].replace(path[1])
          # Link up the name to the compiled route regexp
          application.route_names[name] = [rt[0], rt[1]]
          # puts "\tnamed :#{name}  -- #{rt[0]}"
          rts << rt
        end
      elsif in_path.is_a?(Symbol)
        path = path_with_namespace(in_path)
        # Save the namespace with this route
        application.namespaces["#{method} #{path[0]}"] = [self, namespace]
        # Register the path with Sinatra's routing engine
        rt = application.send(method.downcase, path[0], opts, &bk)
        rt[1].replace(path[1])
        # Link up the name to the compiled route regexp
        application.route_names[in_path] = [rt[0], rt[1]]
        # puts "\tnamed :#{in_path}  -- #{rt[0]}"
        return rt
      else # string
        path = path_with_namespace(in_path)
        # Save the namespace with this route
        application.namespaces["#{method} #{path[0]}"] = [self, namespace]
        # Register the path with Sinatra's routing engine
        rt = application.send(method.downcase, path[0], opts, &bk)
        rt[1].replace(path[1])
        # Link up any awaiting name to the compiled route regexp
        if in_path == '' && @next_route_name
          application.route_names[@next_route_name.to_sym] = [rt[0], rt[1]]
          # puts "\tnamed :#{@next_route_name}  -- #{rt[0]}"
          @next_route_name = nil
        else
          application.route_names[in_path] = [rt[0], rt[1]]
        end
        return rt
      end
    end

    def path_with_namespace(path)
      ns = namespace =~ /\/$/ ? namespace : namespace + '/'
      # warn "Namespace: #{ns.inspect}; Path: #{path.inspect}"
      if path.is_a?(Regexp)
        # Scope should be already sanitized to NOT end with a slash.
        # Path should NOT be sanitized since it's a Regexp.
        # Scope + Path should be joined with a slash IF the path regexp does not begin with a '.'
        scrx, needs = application.send(:compile, ns)
        # warn "Scrx: #{scrx.inspect}, Needs: #{needs.inspect}"
        [Regexp.new(scrx.source.sub(/^\^/,'').sub(/\$$/,'') + path.source.sub(/^\^/,'').sub(/\$$/,'')), needs]
      else
        # Scope should be already sanitized to NOT end with a slash.
        # Path should be sanitized to NOT begin with a slash, and OPTIONALLY end with a slash.
        # Scope + Path should be joined with a slash IF the path string does not begin with a '.'
        # (namespace + (path =~ /^\./ || path == '' ? '' : '/') + path).gsub(/\/\/+/,'/')
        application.send(:compile, ns + path.to_s.gsub(/^\//,''))
      end
    end
  end
end