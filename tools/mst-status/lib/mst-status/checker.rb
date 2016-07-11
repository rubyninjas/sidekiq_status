require 'json'

module MST
  class Status
    class Checker
      class << self
     
        @@modules = {}
        @@module_classes = {}

        def register_module_class alias_, class_
          @@module_classes[alias_] = class_
          module_config = @@config["modules"][alias_]
          @@modules[alias_] = @@module_classes[alias_].new(module_config) if module_config
        end

        def load_configuration config_path
          if File.exists? config_path
            @@config = JSON.parse(File.read(config_path))
            @@config["modules"].each do |module_name, module_config|
              @@modules[module_name] = @@module_classes[module_name].new(module_config) if @@module_classes[module_name]
            end
          end
        end

        def load_default_configuration
          load_configuration File.join(__dir__, '..', '..', 'config.default.json')
        end

        def get_status
          failed_module = @@modules.detect { |k, m| m.status == :Fail }
          create_http_response(failed_module.nil? ? :OK : :Fail)
        end

        def get_module_status module_name
          module_ = @@modules[module_name.to_s]
          create_http_response( module_.respond_to?(:status) ? module_.status : :Fail)
        end

        def get_module_app_status module_name, app
          module_ = @@modules[module_name.to_s]
          create_http_response( module_.respond_to?(:app_status) ? module_.app_status(app) : :Fail)
        end

        def get_extended_status
          res = @@modules.inject({}) do |c, (module_name, module_inst)|
            c[module_name] = module_inst.extended_status
            c
          end
          create_http_response_with_body  JSON.pretty_generate(res) 
        end

        private

        def create_http_response app_status
          create_http_response_with_body  JSON.pretty_generate({ :status => app_status })   
        end

        def create_http_response_with_body body
          [200, {
            'Content-Type' => content_type,
            'Content-Length' => Rack::Utils.bytesize(body).to_s
            }, [body]]
        end

        def content_type
          'application/json;charset=utf-8'
        end
      end
    end
  end
end
