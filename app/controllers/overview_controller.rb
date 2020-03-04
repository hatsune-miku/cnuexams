class OverviewController < ApplicationController
    before_action :no!

    def no!
        redirect_to '/'
    end

    def create
        index
    end

    def index

    end

    def show
        redirect_to '/overview'
    end
end
