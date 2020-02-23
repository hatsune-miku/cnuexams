class InstitutesController < ApplicationController
    def create
        index
    end

    def index
        return if crud Institute, '学院', '所'

        case params[:intent]
        when 'onekey-set'
            kind = params[:kind]
            mathp = params[:mathp]
            artp = params[:artp]
            generalp = params[:generalp]

            Institute.where(
                'kind = ?', kind == 'math' ? 0 : 1
            ).update mathp: mathp,
                     artp: artp,
                     generalp: generalp
            errorcode 0

        else
            render html: 'else'

        end
    end
end
