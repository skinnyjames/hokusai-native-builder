@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::Graalvm < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "graalvm"

  def arm?
    kernel.machine = "x86_64" ? false : true
  end

  def build : Nil
    if macos?
      architecture = arm? ? "aarch64" : "x64"
      os = "macos"
    else 
      architecture = arm? ? "aarch64" : "x64"
      os = "linux"
    end

    case config.jdk_version
    when JDKVersion::JDK17
      fetch("graalvm", "https://download.oracle.com/graalvm/17/latest/graalvm-jdk-17_#{os}-#{architecture}_bin.tar.gz")
    when JDKVersion::JDK21
      fetch("graalvm", "https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_#{os}-#{architecture}_bin.tar.gz")
    when JDKVersion::JDK24
      fetch("graalvm", "https://download.oracle.com/graalvm/24/latest/graalvm-jdk-24_#{os}-#{architecture}_bin.tar.gz")
    end
  end
end