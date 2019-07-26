class AppveyorHostAgent < Formula
  desc "Appveyor Host Agent. Continuous Integration solution for Windows and Linux and Mac"
  homepage "https://www.appveyor.com"
  url "https://appveyordownloads.blob.core.windows.net/appveyor/7.0.2324/appveyor-host-agent-7.0.2324-macos-x64.tar.gz"
  version "7.0.2324"
  sha256 "a936475406d64e695843de02db99125968d3dd5b96d509d2afb762b50f080a7d"

  def install
    # copy all files
    cp_r ".", prefix.to_s

    # tune config file
    unless ENV.key?("HOMEBREW_APPEYOR_URL")
      opoo "HOMEBREW_APPEYOR_URL variable not set. Will use default value 'https://ci.appveyor.com'"
      ENV["HOMEBREW_APPEYOR_URL"] = "https://ci.appveyor.com"
    end
    inreplace "appsettings.json" do |appsettings|
      appsettings.gsub! /\[APPVEYOR_URL\]/, ENV["HOMEBREW_APPEYOR_URL"]
      appsettings.gsub! /\"DataDir\":.*/, "\"DataDir\": \"#{var}/appveyor/host-agent\","
    end

    if ENV.key?("HOMEBREW_HOST_AUTH_TKN")
      inreplace "appsettings.json", /\[HOST_AUTH_TOKEN\]/, ENV["HOMEBREW_HOST_AUTH_TKN"]
    end
    (etc/"opt/appveyor/host-agent").install "appsettings.json"
  end

  def post_install
    # Make sure runtime directories exist
    (var/"appveyor/host-agent").mkpath
  end

  def no_token_caveat; <<~EOS_TKN
    Edit #{etc}/opt/appveyor/host-agent/appsettings.json:
      replace HOST_AUTH_TOKEN with correct Host Auth Token.
  EOS_TKN
  end

  def caveats
    <<~EOS
      Configuration file is #{etc}/opt/appveyor/host-agent/appsettings.json
      Database will be stored in #{var}/appveyor/host-agent/
    EOS
    no_token_caveat unless ENV.key?("HOMEBREW_HOST_AUTH_TKN")
  end


  plist_options :startup => false

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
        <dict>
          <key>KeepAlive</key>
          <false/>
          <key>Label</key>
          <string>#{plist_name}</string>
          <key>Program</key>
          <string>#{prefix}/appveyor-host-agent</string>
          <key>ProgramArguments</key>
          <array>
          </array>
          <key>RunAtLoad</key>
          <true/>
          <key>WorkingDirectory</key>
          <string>#{var}/appveyor/host-agent/</string>
          <key>StandardErrorPath</key>
          <string>#{var}/appveyor/host-agent/host-agent.stderr.log</string>
          <key>StandardOutPath</key>
          <string>#{var}/appveyor/host-agent/host-agent.stdout.log</string>
        </dict>
      </plist>
    EOS
  end

  test do
    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! For Homebrew/homebrew-core
    # this will need to be a test that verifies the functionality of the
    # software. Run the test with `brew test appveyor-server-macos-x`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
    system "false"
  end
end