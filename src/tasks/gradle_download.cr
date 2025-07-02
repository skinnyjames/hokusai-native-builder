@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::GradleDownload < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "gradle-download"

  def build : Nil
    fetch("gradle", "https://file.skinnyjames.net/gradle.tar.gz")
  end
end