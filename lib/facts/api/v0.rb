module Facts
  module Api
    class V0 < Grape::API
      default_format :json
      error_format :json

      version 'v0', :using => :path

      get :facts do
        "woot woot!"
      end

      resource :facts do
        get :latest do
          { message: "woot woot!" }
        end
      end
    end
  end
end
