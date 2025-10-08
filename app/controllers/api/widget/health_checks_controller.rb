module Api
  module Widget
    class HealthChecksController < ApplicationController
      allow_unauthenticated_access
      skip_before_action :verify_authenticity_token

      def show
        # Check application health
        check_database_connection
        check_redis_connection
        
        render json: {
          type: "text-with-progress",
          refresh: "",
          link: "",
          title: "Campfire Healthcheck",
          text: "Healthy",
          progressLabel: "200 OK",
          progress: 1
        }, status: :ok
      rescue => e
        status_code = determine_status_code(e)
        
        render json: {
          type: "text-with-progress",
          refresh: "",
          link: "",
          title: "Campfire Healthcheck",
          text: "Unhealthy",
          progressLabel: "#{status_code} Error",
          progress: 0
        }, status: status_code
      end

      private

      def check_database_connection
        ActiveRecord::Base.connection.execute("SELECT 1")
      end

      def check_redis_connection
        Redis.new(url: ENV.fetch("REDIS_URL", "redis://localhost:6379")).ping
      end

      def determine_status_code(exception)
        case exception
        when ActiveRecord::ConnectionNotEstablished, Redis::BaseConnectionError
          503 # Service Unavailable
        else
          500 # Internal Server Error
        end
      end
    end
  end
end

