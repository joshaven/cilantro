puts "loading main controller"

configure do
  set :views, APP_ROOT/'app'/'views'
  set :public, APP_ROOT/'public'
end

error do
  e = request.env['sinatra.error']
  Kernel.puts e.backtrace.join("\n")
  'Application error'
end

helpers do
  # add your helpers here
end

# root page
get '/' do
  haml :index
end
