# frozen_string_literal: true

class JekyllAuth
  class AuthSite < Sinatra::Base
    configure :production do
      require "rack-ssl-enforcer"
      use Rack::SslEnforcer if JekyllAuth.ssl?
    end

    use Rack::Session::Cookie,       :http_only => true,
                                     :secret    => ENV["SESSION_SECRET"] || SecureRandom.hex

    require "jekyll_auth/unauthenticated"
    set :github_options, {:scopes => "read:org", :failure_app => JekyllAuth::BadAuthentication}

    ENV["WARDEN_GITHUB_VERIFIER_SECRET"] ||= SecureRandom.hex
    register Sinatra::Auth::Github

    use Rack::Logger

    include JekyllAuth::Helpers

    before do
      for lev in 0..(JekyllAuth.num_levels - 1)
        if matches_level?(lev)
          logger.info "Authentication strategy: #{authentication_strategy(lev)} for level #{lev}"
          case authentication_strategy(lev)
          when :team
            github_team_authenticate! ENV["GITHUB_TEAM_ID_#{lev}"]
          when :teams
            github_teams_authenticate! ENV["GITHUB_TEAM_IDS_#{lev}"].split(",")
          when :org
            github_organization_authenticate! ENV["GITHUB_ORG_NAME_#{lev}"]
          else
            raise JekyllAuth::ConfigError
          end
          break
        end
      end
    end
    get "/logout" do
      logout!
      redirect "/"
    end
  end
end
