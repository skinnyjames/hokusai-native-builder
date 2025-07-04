require "barista"
require "file_utils"
require "./config"

module Hokusai
  module Native
    module Task
      getter :config

      def android_home
        # "/Users/skinnyjames/Library/Android/sdk"
        "#{config.directory}/android-sdk"
      end

      def graalvm_base_path
         macos? ? "#{config.directory}/graalvm/Contents/Home" : "#{config.directory}/graalvm"
      end

      def ndk_path
        os = macos? ? "darwin" : "linux"
        # android doesn't release ndk builds for arm...
        ar = "x86_64" #arm? ? "aarch64" : "x86_64"
        "#{android_home}/ndk/#{ndk_version}/toolchains/llvm/prebuilt/#{os}-#{ar}"
      end

      def clang
        "#{ndk_path}/bin/clang"
      end

      def ensure_clang_script
        os = macos? ? "darwin" : "linux"
        ar = "x86_64" #arm? ? "aarch64" : "x86_64"
        str = <<-EOF
        #!/usr/bin/env sh

        #{clang} --target=aarch64-linux-android35 -I#{android_home}/ndk/#{ndk_version}/toolchains/llvm/prebuilt/#{os}-#{ar}/sysroot/usr/include "$@"
        EOF

        mkdir("#{config.directory}/bin", parents: true)

        block do
          File.write("#{config.directory}/bin/clang", str)
        end

        block do
          File.write("#{config.directory}/bin/gcc", str)
        end

        command("chmod 755 #{config.directory}/bin/clang")
        command("chmod 755 #{config.directory}/bin/gcc")
      end


      def ndk_version
        "29.0.13113456"
      end

      def arm?
        case ENV["RUNNER_ARCH"]?
        when .nil?
          false
        when "x64"
          false
        else
          true
        end
      end

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