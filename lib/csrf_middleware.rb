require 'securerandom'

module EksCent
  module Middleware
    class CSRF
      def initialize(app)
        @app = app
      end

      def call(env)
        # 1. Ensure any body reading is rewound
        if env['rack.input']
          begin
            env['rack.input'].rewind 
          rescue
            # some streams are not rewindable
          end
        end

        # 2. Find the session. Try standard and common custom keys
        session = env['rack.session'] || env['session'] || env['eks_cent.session']
        
        if session.nil?
          # If no session found, we attempt to initialize one in rack.session
          # Note: If EksCent::Middleware::Session runs after this (unlikely but possible), 
          # it might overwrite this.
          env['rack.session'] ||= {}
          session = env['rack.session']
        end

        # 3. Ensure token exists in session
        session['csrf_token'] ||= SecureRandom.hex(32)

        req = Rack::Request.new(env)
        
        # 4. Check for POST/PUT/PATCH/DELETE
        if ['POST', 'PUT', 'PATCH', 'DELETE'].include?(req.request_method)
          submitted_token = req.params['csrf_token'] || req.env['HTTP_X_CSRF_TOKEN']
          
          # Log for debugging if needed (via puts, will show in server output)
          # puts "[CSRF] Method: #{req.request_method} | Submitted: #{submitted_token} | Session: #{session['csrf_token']}"
          
          if submitted_token.nil? || submitted_token != session['csrf_token']
            return [403, {'Content-Type' => 'text/plain'}, ['CSRF Token Validation Failed. Please refresh the page and try again.']]
          end
        end

        @app.call(env)
      end
    end
  end
end
