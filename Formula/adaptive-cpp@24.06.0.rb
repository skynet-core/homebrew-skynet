class AdaptiveCppAT24060 < Formula
  desc "SYCL and C++ standard parallelism for CPUs and GPUs from all vendors"
  homepage "https://adaptivecpp.github.io/"
  url "https://github.com/AdaptiveCpp/AdaptiveCpp/archive/refs/tags/v24.06.0.tar.gz"
  sha256 "cfa117722fd50295de8b9e1d374a0de0aa2407a47439907972e8e3d9795aa285"
  license "BSD-2-Clause"

  livecheck do
    url :stable
    regex(%r{/v24\.([.\d]+)tar\.gz$/}i)
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "boost@1.86"
  depends_on :linux
  depends_on "llvm@18"
  depends_on "opencl-icd-loader"
  depends_on "openmp@18"

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

    ENV.append "CFLAGS", "-I#{Formula["openmp@18"].opt_include}"
    ENV.append "CXXFLAGS", "-I#{Formula["openmp@18"].opt_include}"
    ENV.append "LDFLAGS", "-L#{Formula["openmp@18"].opt_lib} -L#{Formula["opencl-icd-loader"].opt_lib}"

    args = %W[
      -DCMAKE_C_COMPILER=#{Formula["llvm@18"].opt_bin/"clang"}
      -DCMAKE_CXX_COMPILER=#{Formula["llvm@18"].opt_bin/"clang++"}
      -DCMAKE_CXX_STANDARD=17
      -DCMAKE_LINKER=#{Formula["llvm@18"].opt_bin/"lld"}
      -DLLVM_DIR=#{Formula["llvm@18"].opt_lib/"llvm/cmake/llvm"}
      -DBOOST_ROOT=#{Formula["boost@1.86"]}
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
