class Member::OverviewController < ApplicationController
    before_action :no!

    def no!
        redirect_to '/member'
    end

    def create
        index
    end

    def index

    end

    def show
        redirect_to '/member/overview'
    end
end
