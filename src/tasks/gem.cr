@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::Gem < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "gem"

  getter :gem_command, :config

  @gem_command : String?

  def initialize(@config : Hokusai::Native::Config, **args)
    if command = args["gem_command"]?
      @gem_command = command
    end

    super(config)
  end

  def build : Nil
    ensure_clang_script

    command("which gcc", env: env)

    raise "need gem command" if gem_command.nil?

    command("ls #{config.directory}")
    command("#{gem} #{gem_command}", env: env)
  end

  def gem
    "#{config.directory}/truffleruby/bin/gem"
  end

  def env
    {
      "PATH" => "#{config.directory}/bin:#{ENV["PATH"]}",
      "JAVA_HOME" => "#{config.directory}/graalvm/Contents/Home",
      "GRAALVM_HOME" => "#{config.directory}/graalvm/Contents/Home"
    }
  end
end