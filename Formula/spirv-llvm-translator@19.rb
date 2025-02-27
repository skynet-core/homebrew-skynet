# typed: true

class SpirvLlvmTranslatorAT19 < Formula
  desc "Tool and a library for bi-directional translation between SPIR-V and LLVM IR"
  homepage "https://github.com/KhronosGroup/SPIRV-LLVM-Translator"
  url "https://github.com/KhronosGroup/SPIRV-LLVM-Translator/archive/refs/tags/v19.1.4.tar.gz"
  sha256 "8f15eb0c998ca29ac59dab25be093d41f36d77c215f54ad9402a405495bea183"
  license "Apache-2.0" => { with: "LLVM-exception" }

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "pkgconf" => :build
  depends_on "spirv-headers" => :build
  depends_on :linux
  depends_on "llvm@19"

  def install
    ENV.append "LDFLAGS", "-Wl,-rpath,#{rpath(target: Formula["llvm@19"].opt_lib)}" if OS.linux?
    system "cmake", "-S", ".", "-B", "build",
           "-DBUILD_SHARED_LIBS=ON",
           "-DCMAKE_INSTALL_RPATH=#{rpath}",
           "-DLLVM_BUILD_TOOLS=ON",
           "-DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=#{Formula["spirv-headers"].opt_prefix}",
           *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath / "test.ll").write <<~EOS
      target datalayout = "e-i64:64-v16:16-v24:32-v32:32-v48:64-v96:128-v192:256-v256:256-v512:512-v1024:1024"
      target triple = "spir64-unknown-unknown"

      define spir_kernel void @foo() {
        ret void
      }
    EOS
    system Formula["llvm@19"].opt_bin / "llvm-as", "test.ll"
    system bin / "llvm-spirv", "test.bc"
    assert_path_exists testpath / "test.spv"
  end
end
