require 'sinatra/base'
class JekyllAuth
    class BadAuthentication < Sinatra::Base
        enable :raise_errors
        disable :show_exceptions
        set :public_folder, File.expand_path(JekyllAuth.destination, Dir.pwd)

        helpers do
            def unauthorized_template
            @unauthenticated_template ||= File.read(File.join(settings.public_folder, "/403.html"))
            end
        end

        get '/unauthenticated' do
            status 403
            unauthorized_template
        end
    end
end