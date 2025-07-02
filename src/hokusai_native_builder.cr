require "barista"
require "file_utils"
require "./config"

module Hokusai
  module Native
    module Task
      getter :config

      def initialize(@config : Hokusai::Native::Config, **args)
        super()
      end

      def fetch(target, location : String, **opts)
        begin
          fetcher = Barista::Behaviors::Software::Fetchers::Net.new(location, **opts)
          fetcher.execute(config.directory, target)
        rescue ex : Barista::Behaviors::Software::Fetchers::RetryExceeded
          on_error.call("Failed to fetch: #{ex}")
          raise ex
        end
      end
    end

    class Builder < Barista::Project
      include_behavior Software

      getter :config

      def initialize(@config : Hokusai::Native::Config)
      end

      def build(workers : Int32, filter : Array(String)? = nil, **args)
        FileUtils.mkdir_p(config.directory)

        colors = Barista::ColorIterator.new

        Log.setup_from_env

        tasks.each do |task_klass|
          logger = Barista::RichLogger.new(colors.next, task_klass.name)

          task = task_klass.new(config, **args)

          task.on_output do |str|
            logger.info { str }
          end
    
          task.on_error do |str|
            logger.error { str }
          end
        end

        orchestration = Barista::Orchestrator(Barista::Task).new(registry, workers: workers, filter: filter)
        
        orchestration.on_task_start do |task|
          Barista::Log.debug(task) { "Starting Build" }
        end
        
        orchestration.on_task_failed do |task, ex|
          Barista::Log.error(task) { "build failed: #{ex}" }
        end

        orchestration.on_task_succeed do |task|
          Barista::Log.debug(task) { "build succeeded" }
        end

        orchestration.on_unblocked do |info|
          str = <<-EOH
          Unblocked #{info.unblocked.join(", ")}
          Building #{info.building.join(", ")}
          Active Sequences #{info.active_sequences.map {|k,v| "{ #{k}, #{v} }"}.join(", ")}
          EOH
          Barista::Log.debug(name) { str }
        end
  
        orchestration.execute
      end
    end
  end
end

require "./tasks/*"
require "./commands/*"

console = ACON::Application.new("hokusai-native-builder")
console.add(Hokusai::Native::Commands::Setup.new)
console.add(Hokusai::Native::Commands::Gem.new)
console.add(Hokusai::Native::Commands::Gradle.new)
console.add(Hokusai::Native::Commands::NativeImage.new)

console.run