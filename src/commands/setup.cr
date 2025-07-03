module Hokusai::Native::Commands
  @[ACONA::AsCommand("setup", description: "Sets up a Hokusai Native project")]
  class Setup < ACON::Command
    include Barista::Behaviors::Software::OS::Information

    @@default_name = "setup"

    protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
      directory = input.argument("directory") || nil
      workers = input.option("workers", Int32?) || memory.cpus.try(&.-(1)) || 1
      jdk_version = input.option("jdk-version", Int32?) || 21
      graalvm_version = input.option("graalvm-version") || "24.0.1"

      config = Hokusai::Native::Config.new

      directory.try do |dir|
        config.set_directory(dir)
      end

      jdk_version.try do |version|
        config.set_jdk_version(version)
      end

      graalvm_version.try do |version|
        config.set_graalvm_version(version)
      end

      begin
        Hokusai::Native::Builder.new(config).build(workers: workers, filter: ["graalvm", "project", "ruby", "gradle-download", "android"])
      rescue ex
        output.puts("<error>Build failed: #{ex.message}</error>")
      end

      ACON::Command::Status::SUCCESS
    end

    def configure : Nil
      self
        .argument("directory", :optional, "the directory to build this project (default ./hokusai-native-build)")
        .option("jdk-version", "j", :optional, "The JDK Platform to target [17, 21, 24] (default: 21)")
        .option("graalvm-version", "g", :optional, "The GraalVM Version to use (default 24.0.1)")
        .option("workers", "w", :optional, "The number of concurrent build workers (default #{memory.cpus.try(&.-(1)) || 1})")
    end
  end
end
