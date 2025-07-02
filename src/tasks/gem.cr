@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::Gem < Barista::Task
  include_behavior Software

  nametag "gem"

  getter :gem_command, :config

  @gem_command : String?

  def initialize(@config : Hokusai::Native::Config, **args)
    if command = args["gem_command"]?
      @gem_command = command
    end

    super()
  end

  def build : Nil
    raise "need gem command" if gem_command.nil?

    command("#{gem} #{gem_command}", env: env)
  end

  def gem
    "#{config.directory}/truffleruby/bin/gem"
  end

  def env
    {
      "JAVA_HOME" => "#{config.directory}/graalvm/Contents/Home",
      "GRAALVM_HOME" => "#{config.directory}/graalvm/Contents/Home"
    }
  end
end