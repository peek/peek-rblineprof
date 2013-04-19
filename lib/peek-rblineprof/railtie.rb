require 'peek/rblineprof/controller_helpers'

module Peek
  module Rblineprof
    class Railtie < ::Rails::Engine
      initializer 'peek.rblineprof.include_controller_helpers' do
        ActiveSupport.on_load(:action_controller) do
          include Peek::Rblineprof::ControllerHelpers
        end
      end
    end
  end
end
