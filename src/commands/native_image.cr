module Hokusai::Native::Commands
  @[ACONA::AsCommand("native-image", description: "Generates and packages the native image for a Hokusai-Native project")]
  class NativeImage < ACON::Command
    protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
      directory = input.option("directory") || nil
      config = Hokusai::Native::Config.new
      directory.try do |dir|
        config.set_directory(dir)
      end

      begin
        Hokusai::Native::Builder.new(config).build(workers: 1, filter: ["native-image"])
      rescue ex
        output.puts("<error>Build failed: #{ex.message}</error>")
        raise ex
      end

      ACON::Command::Status::SUCCESS
    end

    def configure : Nil
      self
        .option("directory", "d", :optional, "the directory of the hokusai-native-build installation (default ./hokusai-native-build)")
    end
  end
end
