module Hokusai::Native::Commands
  @[ACONA::AsCommand("gem", description: "Gem tools for Hokusai-Native project")]
  class Gem < ACON::Command
    protected def execute(input : ACON::Input::Interface, output : ACON::Output::Interface) : ACON::Command::Status
      directory = input.option("directory") || nil
      command = input.argument("gem-command") || "version"
      config = Hokusai::Native::Config.new
      directory.try do |dir|
        config.set_directory(dir)
      end

      begin
        Hokusai::Native::Builder.new(config).build(workers: 1, filter: ["gem"], gem_command: command)
      rescue ex
        output.puts("<error>Build failed: #{ex.message}</error>")
        raise ex
      end

      ACON::Command::Status::SUCCESS
    end

    def configure : Nil
      self
        .argument("gem-command", :required, "the gem command to run (default version)")
        .option("directory", "d", :optional, "the directory of the hokusai-native-build installation (default ./hokusai-native-build)")
    end
  end
end
