@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::Graalvm < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "graalvm"

  def build : Nil
    architecture = arch? ? "aarch64" : "x64"

    case config.jdk_version
    when JDKVersion::JDK17
      fetch("graalvm", "https://download.oracle.com/graalvm/17/latest/graalvm-jdk-17_linux-#{architecture}_bin.tar.gz")
    when JDKVersion::JDK21
      fetch("graalvm", "https://download.oracle.com/graalvm/21/latest/graalvm-jdk-21_linux-#{architecture}_bin.tar.gz")
    when JDKVersion::JDK24
      fetch("graalvm", "https://download.oracle.com/graalvm/24/latest/graalvm-jdk-24_linux-#{architecture}_bin.tar.gz")
    end
  end
end