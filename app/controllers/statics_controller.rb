class StaticsController < ApplicationController
    def index
        create
    end

    def create
        render html: 'this directory stores all static resources.'
    end

    def show
        id = params[:id]
        filename = "public/#{id}"

        if File.exists? "#{filename}.jpg"
            send_file "#{filename}.jpg"

        elsif File.exists? "#{filename}.png"
            send_file "#{filename}.png"

        else
            send_file "#{filename}.jpeg"

        end

    end
end
