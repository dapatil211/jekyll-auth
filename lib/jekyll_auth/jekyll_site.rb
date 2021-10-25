# frozen_string_literal: true

class JekyllAuth
  class JekyllSite < Sinatra::Base
    configure :production, :development do
      enable :logging
    end
    register Sinatra::Index
    set :public_folder, File.expand_path(JekyllAuth.destination, Dir.pwd)
    use_static_index "index.html"
    require 'sinatra'
    get '/*:file_name/?' do |path, fname| 
      send_file(
        File.join(settings.public_folder, path, "#{fname}.html")
      )
    end

    post '/update' do
      request.body.rewind
      begin
        data = JSON.parse request.body.read
      rescue JSON::ParserError => e
        logger.info "Malformed json"
        halt 400, 'Not valid json'
      else
        logger.info "Updating"
        if data.is_a?(Hash) and data.key?('pat')
          `./pull_notes.sh #{data['pat']}`
          if $?.success?
            logger.info "Successfully updated"
            [200, 'Updated Internal Website']
          else
            logger.info "Unauthorized to update"
            halt 403, 'Not authorized'
          end
        else
          logger.info "Invalid request style"
          halt 400, 'Not valid request'
        end
      end
    end

    not_found do
      status 404
      four_oh_four = File.expand_path(settings.public_folder + "/404.html", Dir.pwd)
      File.read(four_oh_four) if File.exist?(four_oh_four)
    end
  end
end
