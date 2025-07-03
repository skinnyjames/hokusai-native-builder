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

  def libpath
    "#{config.directory}/project/build/native/nativeCompile/hokusai-native.so"
  end

  def build : Nil
    command("ls #{android_home}/ndk/#{ndk_version}/toolchains/llvm/prebuilt/")

    ensure_clang_script

    # run gradle native build
    command("gradle nativeCompile --debug", env: env, chdir: "#{config.directory}/project")

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
      "HOKUSAI_NATIVE_CLANG" => "#{config.directory}/bin/clang",
      "ANDROID_HOME" => android_home,
      "PATH" => "#{config.directory}/bin:#{config.directory}/gradle/bin:#{ENV["PATH"]}",
      "HOKUSAI_RUBY_HOME" => "#{config.directory}/truffleruby",
      "JAVA_HOME" => macos? ? "#{config.directory}/graalvm/Contents/Home" : "#{config.directory}/graalvm",
      "GRAALVM_HOME" => macos? ? "#{config.directory}/graalvm/Contents/Home" : "#{config.directory}/graalvm"
    }
  end
end
