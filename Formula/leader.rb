class Leader < Formula
  desc "VIM's leader key for your terminal"
  homepage 'https://dhamidi.github.io/leader'
  url 'https://github.com/dhamidi/leader/archive/v0.3.2.tar.gz'
  sha256 '81341a65531763a7138e1d69d7ca1d9dcfb38a7483b68f7823cc41a00b7c612b'

  depends_on 'go' => :build

  def install
    ENV['GOPATH'] = buildpath
    (buildpath/'src/github.com/dhamidi/leader').install buildpath.children
    ldflags = '-X main.Release=v0.3.2'

    cd 'src/github.com/dhamidi/leader' do
      system 'go', 'get', 'github.com/gobuffalo/packr/...'
      system('find', ENV['GOPATH'])
      system(buildpath / 'bin/packr')
      system 'go', 'get', '.'
      system 'go', 'build', '-o', bin / 'leader', '-ldflags', ldflags, '.'
      man1.install 'assets/leader.1'
    end
  end

  def post_install
    shellrc, shell_init = case File.basename(ENV['SHELL'])
                          when 'bash'
                            ['~/.bashrc', 'eval "$(leader init)"']
                          when 'zsh'
                            ['~/.zshrc', 'eval "$(leader init)"']
                          when 'fish'
                            ['~/.config/fish/config.fish', 'leader init | source']
                          end
    puts "Add the following to your #{shellrc}:"
    puts shell_init
    puts ''
    puts 'To get started, create a file ~/.leaderrc with these contents:'
    puts ''
    puts example_leaderrc
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
