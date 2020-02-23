class PreferencesController < ApplicationController
    def create
        index
    end

    def index
        crud Preference, '全局设置', '项'
    end
end
