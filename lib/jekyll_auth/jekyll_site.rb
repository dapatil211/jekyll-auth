# frozen_string_literal: true

class JekyllAuth
  class JekyllSite < Sinatra::Base
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
      data = JSON.parse request.body.read
      `./pull_notes.sh #{data['pat']}`
    end

    not_found do
      status 404
      four_oh_four = File.expand_path(settings.public_folder + "/404.html", Dir.pwd)
      File.read(four_oh_four) if File.exist?(four_oh_four)
    end
  end
end
