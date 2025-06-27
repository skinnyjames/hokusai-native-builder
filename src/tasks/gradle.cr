@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::Gradle < Barista::Task
  include_behavior Software

  nametag "gradle"

  getter :gradle_command, :config

  @gradle_command : String?

  def initialize(@config : Hokusai::Native::Config, **args)
    if command = args["gradle_command"]?
      @gradle_command = command
    end
  
    super()
  end

  def build : Nil
    command("#{gradle} #{gradle_command}", env: env, chdir: project_dir)
  end

  def ensure_ruby
  end

  def project_dir
    "#{config.directory}/project"
  end

  def gradle
    "#{config.directory}/project/gradlew"
  end

  def env
    {
      "JAVA_HOME" => "#{config.directory}/graalvm",
      "GRAALVM_HOME" => "#{config.directory}/graalvm"
    }
  end
end