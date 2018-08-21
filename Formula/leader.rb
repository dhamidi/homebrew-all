class Leader < Formula
  desc "VIM's leader key for your terminal"
  homepage 'https://dhamidi.github.io/leader'
  url 'https://github.com/dhamidi/leader/archive/v0.2.0.tar.gz'
  sha256 'd8d0cddcf37a011b65deb818dceb0dda5f7823deca876b8bb2dbff9b836d31f5'

  depends_on 'go' => :build

  def install
    ENV['GOPATH'] = buildpath
    (buildpath/'src/github.com/dhamidi/leader').install buildpath.children
    ldflags = '-X main.Release=v0.2.0'

    cd 'src/github.com/dhamidi/leader' do
      system 'go', 'get', 'github.com/gobuffalo/packr/...'
      system('find', ENV['GOPATH'])
      system(buildpath / 'bin/packr')
      system 'go', 'get', '.'
      system 'go', 'build', '-o', bin / 'leader', '-ldflags', ldflags, '.'
      man1.install 'assets/leader.1'
    end

    install_shell_specific_configuration_files
    install_leaderrc
  end

  def user_home_dir
    osx = "/Users/#{ENV['USER']}"
    linux = "/home/#{ENV['USER']}"
    [osx, linux].find(&File.method(:exist?))
  end

  def install_leaderrc
    dest = "#{user_home_dir}/.leaderrc"
    return if File.exist?(dest)

    File.write(dest, example_leaderrc)
  end

  def install_shell_specific_configuration_files
    home = user_home_dir
    append_if_exists "#{home}/.zshrc", 'eval "$(leader init)"'
    append_if_exists "#{home}/.bashrc", 'eval "$(leader init)"'
    append_if_exists "#{home}/.config/fish/config.fish", 'leader init | source'
  end

  def append_if_exists(dest, line)
    return unless File.exist?(dest)
    File.open(dest, 'a') { |f| f.puts line }
  end

  def test
    File.write('.leaderrc', <<~JSON)
      {
        "keys": {
          "o": "echo ok"
        }
      }
JSON
    assert_match('ok', shell_output('leader @o'))
  end

  def example_leaderrc
    <<~JSON
      {
        "keys": {
          "h": {
            "name": "help",
            "keys": {
              "l": "leader help"
            }
          },
          "g": {
            "name": "git",
            "loopingKeys": [
              "s"
            ],
            "keys": {
              "p": "git push",
              "P": "git pull",
              "s": "git status"
            }
          }
        }
      }
JSON
  end
end
