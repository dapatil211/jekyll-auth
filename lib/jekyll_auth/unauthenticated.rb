require 'sinatra/base'
class JekyllAuth
    class BadAuthentication < Sinatra::Base
        enable :raise_errors
        disable :show_exceptions

        helpers do
            def unauthorized_template
            @unauthenticated_template ||= File.read(File.join(File.dirname(__FILE__), "401.html"))
            end
        end

        get '/unauthenticated' do
            status 403
            unauthorized_template
        end
    end
end