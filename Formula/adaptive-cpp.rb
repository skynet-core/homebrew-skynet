class AdaptiveCpp < Formula
  desc "Implementation of SYCL and C++ standard parallelism for CPUs and GPUs from all vendors."
  homepage "https://adaptivecpp.github.io/"
  version "1.0"
  license "BSD-2-Clause"
  head "https://github.com/AdaptiveCpp/AdaptiveCpp.git", branch: "develop"
  #currently LLVM 19 support does not implemented in stable
  stable do
    url "https://github.com/AdaptiveCpp/AdaptiveCpp/archive/refs/heads/develop.tar.gz"
    # sha256 "9d81d3a278d846c76c7e34503348e4f45cc532e12ea20eb80e1cdd5b2cc4433f"
    sha256 "ff3d70f52a7ee2db29957e44adc3c59f4f6f6ef05fedd0c0abc02ed18f51c766"
  end

  livecheck do
    url :stable
    regex(/\/develop\.tar\.gz$/i)
    # regex(/\/stable\.tar\.gz$/i)
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on :linux
  depends_on "opencl-icd-loader"
  depends_on "openmp"
  depends_on "boost"
  depends_on "lld"
  depends_on "llvm"
  
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

    ENV.append "CFLAGS", "-I#{Formula["openmp"].opt_include}"
    ENV.append "CXXFLAGS", "-I#{Formula["openmp"].opt_include}"
    ENV.append "LDFLAGS", "-L#{Formula["openmp"].opt_lib} -L#{Formula["opencl-icd-loader"].opt_lib}"

    args = %W[
      -DCMAKE_C_COMPILER=#{Formula["llvm"].opt_bin/"clang"}
      -DCMAKE_CXX_COMPILER=#{Formula["llvm"].opt_bin/"clang++"}
      -DCMAKE_CXX_STANDARD=17
      -DCMAKE_LINKER=#{Formula["lld"].opt_bin/"lld"}
      -DLLVM_DIR=#{Formula["llvm"].opt_lib/"llvm/cmake/llvm"}
      -DBOOST_ROOT=#{Formula["boost"]}
    ]

      system "cmake", "-G", "Ninja", "-S", ".", "-B","build", *(std_cmake_args + args)
      system "cmake", "--build", "build"
      system "cmake", "--build", "build", "--target", "install"

      (buildpath/"build/platforms.cpp").write(platforms_code)
      
      system "#{bin}/acpp", "-O3", "build/platforms.cpp", "-o", "build/platforms"
      ohai "Running the SYCL example to list supported platforms and devices:"
      output = `./build/platforms`
      puts output
      ohai "AdaptiveCpp installation completed"
  end

  test do
    system "#{bin}/acpp", "--version"
  end
end
