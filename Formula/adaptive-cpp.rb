class AdaptiveCpp < Formula
  desc "SYCL and C++ standard parallelism for CPUs and GPUs from all vendors"
  homepage "https://adaptivecpp.github.io/"
  url "https://github.com/AdaptiveCpp/AdaptiveCpp/archive/bd84cff8efa8851c16270af9f2e6c353715b01cb.zip"
  version "develop"
  sha256 "93a4aaf0766fd720ced5ebc0564fa8d77b880776ff380c1f5deb5e404e2cb168"
  license "BSD-2-Clause"
  head "https://github.com/AdaptiveCpp/AdaptiveCpp.git", branch: "develop"
  # Currently LLVM 19 support does not implemented in stable

  livecheck do
    url :stable
    regex(%r{/develop\.tar\.gz$/}i)
  end

  depends_on "cmake"
  depends_on "ninja"
  depends_on "boost"
  depends_on :linux
  depends_on "llvm@19"
  depends_on "opencl-icd-loader"
  depends_on "openmp@19"

  def install
    platforms_code = <<~EOS
      #include <iostream>
      #include <sycl/sycl.hpp>
      int main() {
        auto platforms = sycl::platform::get_platforms();
        for (const auto &platform : platforms) {
          std::cout << "Platform: " << platform.get_info<sycl::info::platform::name>() << std::endl;
          auto devices = platform.get_devices();
          for (const auto &device : devices) {
            std::cout << "\\tDevice: " << device.get_info<sycl::info::device::name>() << std::endl;
          }
        }
      return 0;
      }
    EOS

    ENV.append "CFLAGS", "-I#{Formula["openmp@19"].opt_include}"
    ENV.append "CXXFLAGS", "-I#{Formula["openmp@19"].opt_include}"
    ENV.append "LDFLAGS", "-L#{Formula["openmp@19"].opt_lib} -L#{Formula["opencl-icd-loader"].opt_lib}"

    args = %W[
      -DCMAKE_C_COMPILER=#{Formula["llvm@19"].opt_bin/"clang"}
      -DCMAKE_CXX_COMPILER=#{Formula["llvm@19"].opt_bin/"clang++"}
      -DCMAKE_CXX_STANDARD=17
      -DCMAKE_LINKER=#{Formula["llvm@19"].opt_bin/"llvm-link"}
      -DLLVM_DIR=#{Formula["llvm@19"].opt_lib/"llvm/cmake/llvm"}
      -DBOOST_ROOT=#{Formula["boost"]}
    ]

    system "cmake", "-G", "Ninja", "-S", ".", "-B", "build", *(std_cmake_args + args)
    system "cmake", "--build", "build"
    system "cmake", "--build", "build", "--target", "install"

    (buildpath/"build/platforms.cpp").write(platforms_code)

    system "#{bin}/acpp", "-O3", "build/platforms.cpp", "-o", "build/platforms"
    ohai "Running the SYCL example to list supported platforms and devices:"
    puts `./build/platforms`
    ohai "AdaptiveCpp installation completed"
  end

  test do
    system "#{bin}/acpp", "--version"
  end
end
