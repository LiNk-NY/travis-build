require 'travis/build/script/addons/deploy'
require 'yaml'

module Travis
  module Build
    class Script
      module Addons
        class EngineYard < Deploy
          private
            def tools
              `gem install engineyard`
            end

            def deploy
              write('~/.eyrc', { 'api_token' => config[:api_key] }.to_yaml)
              ey 'web disable' if config[:maintenance_page]
              ey 'deploy --ref $TRAVIS_COMMIT' << migrate
              ey 'web enable' if config[:maintenance_page]
            end

            def migrate
              case config[:migrate]
              when nil   then ''
              when true  then ' --migrate'
              when false then ' --no-migrate'
              else            ' --migrate %p' % config[:migrate]
              end
            end

            def ey(cmd)
              `ey #{cmd} #{ey_options}`
            end

            def ey_options
              @ey_options ||= [:app, :account, :environment].map do |key|
                "--#{key} #{config[key]}" if config[key]
              end.compact.join(" ")
            end
        end
      end
    end
  end
end
