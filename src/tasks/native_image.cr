@[Barista::BelongsTo(Hokusai::Native::Builder)]
class Hokusai::Native::Tasks::NativeImage < Barista::Task
  include_behavior Software
  include Hokusai::Native::Task

  nametag "native-image"

  def ensure_standalone_libssl
    raise "Need to run setup - openssl.so not found" unless File.exists?(openssl_path)
  end

  def ext
    macos? ? "bundle" : "so"
  end

  def openssl_path
    "#{config.directory}/truffleruby/src/main/c/openssl/openssl.#{ext}"
  end

  def target_openssl_path
    "#{config.directory}/project/build/native/nativeCompile/resources/ruby/ruby-home/lib/mri"
  end

  def build : Nil
    # run gradle native build
    command("gradle wrapper", env: env, chdir: "#{config.directory}/project")
    command("./gradlew wrapper --gradle-version 8.8", env: env, chdir: "#{config.directory}/project")
    command("./gradlew nativeCompile --debug", env: env, chdir: "#{config.directory}/project")
    
    # rename library to "libhokusai-native"

    # copy openssl.so
    copy(openssl_path, target_openssl_path)

    mkdir("#{config.directory}/project/build/native/nativeCompile/truffle", parents: true)
    # sync truffle installation
    sync("#{config.directory}/truffleruby", "#{config.directory}/project/build/native/nativeCompile/truffle")
    # package contents
    command("tar -czvf #{config.directory}/package.tar.gz #{config.directory}/project/build/native/nativeCompile")
  end

  def env
    {
      "HOKUSAI_RUBY_HOME" => "#{config.directory}/truffleruby",
      "JAVA_HOME" => macos? ? "#{config.directory}/graalvm/Contents/Home" : "#{config.directory}/graalvm",
      "GRAALVM_HOME" => macos? ? "#{config.directory}/graalvm/Contents/Home" : "#{config.directory}/graalvm"
    }
  end
end
